# Persistence and asynchronous ownership

Use this procedure for state-changing operations, transaction/context changes,
concurrent updates, idempotency, or delayed results. It is stack-neutral except
for the explicitly marked MikroORM section. Preserve the installed ORM's real
semantics; a transaction, identity map, authorization check, and lock solve
separate problems.

## Map the invariant before choosing a mechanism

1. Name the rows/resources and the capability owning each write. Enumerate all
   relevant writers: HTTP, jobs, maintenance, callbacks and other processes.
2. Identify which reads/checks/writes must be atomic, including authority or
   membership checks when concurrent revocation matters. Preserve existing lock
   order across every participating path; do not simplify one writer in isolation.
3. Identify the outer transaction owner and how participating collaborators
   receive its client/session/context. Do not fork, independently commit, or use
   a global client inside that unit of work when atomicity depends on joining it.
4. Identify the database-enforced invariant and public conflict behavior. A
   read-check-write inside an ordinary transaction is not by itself proof against
   races; inspect isolation, constraints, conditional writes and locks.

| Invariant | Smallest applicable mechanism to inspect |
| --- | --- |
| A key must be unique within a tenant | Tenant-qualified database uniqueness; translate the actual violation |
| A stale edit must not overwrite a newer edit | Atomic version-conditioned write or ORM optimistic lock; check affected-row/conflict result |
| Several related records must change together | One transaction spanning every participating write |
| A multi-row decision must serialize with other writers | Appropriate database locking/isolation and a consistent lock protocol |
| A replay must not create a second outcome | Scoped idempotency identity, request equivalence, persisted outcome and database serialization |

Choose from the actual invariant, not a universal lock decorator. A process-local
mutex, a prior `exists()` call, or a non-atomic expected-version comparison does
not protect concurrent replicas. Do not add automatic retries or alter public
conflict semantics merely because an ORM example retries a transaction.

## Keep unit-of-work state isolated

- Establish a distinct identity map/context per request, job or independent unit
  of work when the ORM requires it. A contextual manager does not imply every
  Nest service must be request-scoped. Context isolation is not a tenant filter.
- Pass authenticated actor/tenant and operation state explicitly or through the
  repository's verified context facility. Never retain request entities or the
  current transaction in mutable singleton state.
- Keep tenant/ownership predicates in the owner operation or query. HTTP guards
  alone cannot protect a background or internal caller. Recheck current authority
  and versions when a long-running operation publishes a delayed result.
- After rollback, do not treat cached/managed objects as committed database
  truth. Follow the ORM's recovery rules and begin a fresh unit of work as needed.

### MikroORM-specific checks

Load this subsection only in a MikroORM project and confirm its installed major.

- A contextual `EntityManager`/request context isolates identity maps. Top-level
  jobs need their own context or fork; do not enable `allowGlobalContext` to hide
  a missing context. Independent concurrent transactions must not share managed
  entity instances through a parent identity map.
- For simple tracked writes, `flush()` can provide the implicit transaction.
  Read-check-write, locks, or mixed raw queries may need an explicit transaction.
  `flush()` within an existing transaction is not an independent outer commit.
- Use the owning transaction's callback manager in participating collaborators,
  or verify that the configured contextual manager actually joins it. Do not
  replace it with an unrelated fork. Inspect nested propagation rather than
  assuming a nested transaction or decorator independently commits.
- Rollback does not rewind in-memory object state. Start subsequent work with a
  fresh manager and reload required state; do not return a stale entity as a
  successful persisted result.
- Check runtime entity registration and migration CLI discovery separately.
  Preserve the repository's explicit migration/build workflow; do not add startup
  schema synchronization to make a feature or test pass.

Consult the installed-version [identity map documentation](https://mikro-orm.io/docs/identity-map)
and [transactions documentation](https://mikro-orm.io/docs/transactions) before
changing context, propagation or recovery. These are ORM mechanisms, not a
requirement to introduce MikroORM into another project.

## Separate commits from remote effects

- Keep business transactions short; do not wait for a vendor/AI/network operation
  while holding database locks. State which durable transition authorizes each
  external effect and what happens if either side fails.
- An effect invoked after the owning commit cannot roll back that commit and
  may never happen if the process crashes first. Do not call this durable delivery.
  Use an existing durable mechanism when the requirement needs it; an outbox is
  appropriate only when atomic state-plus-publication intent is actually needed.
- Define duplicate-delivery semantics and idempotent consumption where promised.
  Do not claim a database transaction or queue guarantees exactly-once remote
  effects. Never retry a non-idempotent external write by default.
- For background/cancellable work, name the owner of start, cancellation, durable
  state, resumption and shutdown. Pass stable IDs/inputs, not request-owned ORM
  entities. Give execution its own unit of work and prevent stale/cancelled or
  unauthorized results from being published.
- Keep vendor protocol/output validation in an adapter; business acceptance and
  persistence stay with the feature owner. Preserve existing limits, approval
  gates, cancellation and failure contracts. Do not add silent fallback providers.

## Worked decision: competing confirmation

Two requests confirm the same tenant-owned draft, with one expected version and
one idempotency identity. First inspect all confirmation and revocation writers.
Keep authority/version checks and the intended state change under the established
transaction and database serialization protocol. Pass its transaction context to
any extracted collaborator. A detached persistence fork would break the atomic
boundary even if both functions individually use transactions.

Define same-request replay versus changed-payload conflict before changing the
implementation. Persist the winning outcome and identity atomically; invoke
remote work only according to the accepted commit/delivery contract. A new
repository, queue, retry loop or inheritance hierarchy is not the fix by itself.

## Evidence to hand to verification

Use the production database engine for engine-specific constraints/locking.
Exercise successful commit, relevant intermediate-write rollback, stale versions,
replay/conflict and cross-tenant non-effects. For races, use independent database
contexts/connections and controlled interleavings; sequential mocks are not proof.
Read final committed state through a fresh context. Test cancelled/late publication
only when that lifecycle is part of the changed contract.

Before any destructive test setup, establish the effective target and ownership;
missing isolated infrastructure blocks that claim. Report the invariant, actual
mechanism, transaction/effect owner, observed outcome and remaining limits.
