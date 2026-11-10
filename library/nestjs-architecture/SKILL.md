---
name: nestjs-architecture
description: >-
  Design and refactor NestJS feature ownership, service responsibilities, module
  boundaries, and persistence workflows. Use when adding a business capability,
  splitting a catch-all service, coordinating features, removing dependency
  cycles, or changing transaction ownership, tenant isolation, concurrency,
  idempotency, or background-result publication. Apply before introducing new
  layers or bypassing another feature's owner. Exclude DI-resolution-only fixes,
  DTO/HTTP-only changes, class-pattern selection alone, generic style, and test
  harness work.
---

# NestJS Architecture

Keep a business change inside its responsible capability. Default to a flat
feature and a cohesive concrete service, not a miniature framework.

## Establish the constraints

1. Read repository instructions and accepted behavior/design documentation, then
   inspect the affected feature, callers, and one comparable feature. Treat
   existing exceptions as facts to understand, not automatic new-code policy.
2. Check package scripts, installed Nest/ORM versions, compiler/runtime module
   settings, HTTP adapter, entity discovery, and configured entrypoints relevant
   to the change. Preserve the existing stack; do not copy a tutorial's setup.
3. For state writes, transaction/context changes, races, or delayed effects, read
   [Persistence and asynchronous ownership](references/persistence.md).
4. Use project-specific instructions first, then verified framework mechanics,
   then these design defaults. Check version-matched primary documentation when
   an API or transaction behavior is uncertain; do not silently upgrade packages.

## Ordered workflow

1. **Name the operation.** State actor/tenant, permitted inputs, observable result,
   invariant, failure contract, state changes, and external effects. For a race,
   name the competing operations and the interleaving that breaks the invariant.
2. **Trace ownership.** Locate the entrypoint, application coordinator, policies,
   persistence/read owner, and external adapter that actually exist. Roles need
   not be different classes or folders. Inspect references before changing an
   exported symbol; include jobs and internal callers, not only controllers.
3. **Choose the smallest seam.** Extend an existing cohesive owner. Extract only
   a concern with independent rules, dependencies, lifecycle, or real variation.
   Keep direct ORM use for simple established CRUD; do not add a repository just
   to forward ORM calls or make a mock convenient.
4. **Define the dependency and safety contract.** Identify the owner's exported
   capability, authorized context, transaction owner, response projection, and
   error/effect ordering. Preserve the same guarantees through an extraction.
5. **Implement a vertical change.** Update affected entrypoints, operations,
   adapters, contracts, registration and callers together. Remove obsolete
   forwarding paths; do not leave a second route around the responsible owner.
6. **Prove the changed behavior.** Select evidence from the risk, as below. Update
   affected accepted documentation, public contracts and configuration examples.
   Do not turn a design-only request into an application migration.

## Assign responsibility

| Owner | Responsibility | Keep out |
| --- | --- | --- |
| Controller, consumer, job handler | Transport parsing, authenticated context, command/response or acknowledgment mapping | Reusable business rules and vendor workflows |
| Application operation | Use-case coordination, resource authorization, transaction and effect ordering | Unrelated search, projection, maintenance and protocol algorithms |
| Entity, value or policy | Meaningful invariant, state transition or decision | Network I/O and framework dependencies in an explicitly independent domain |
| Query/repository/store | Substantive queries, persistence mapping and projections within its capability | Bypassing the owner's write/authorization rules |
| Integration adapter | External protocol, client lifecycle, validation and error translation | Deciding or persisting unrelated business outcomes |
| Nest module | Composition, provider ownership and deliberate public exports | Business policy during registration |

Use ordinary records and pure functions when no stateful invariant or dependency
needs a class. A persistence entity is not automatically a rich domain model or
a public response type. A small projection does not need a mapper class.

## Keep boundaries usable

- Organize by business capability, not application-wide controller/service
  buckets. Add `application`, `domain`, or `infrastructure` directories only when
  real complexity and repository conventions justify them. Preserve configured
  bootstrap, migration, build and worker paths when moving code.
- Cross-feature operations use an intentionally exported owner API. Centralized
  entities do not make their writes globally owned. Do not query another
  feature's internals to avoid its authorization or business constraints.
- Put a workflow coordinating two features above them; do not make their
  internal services mutually dependent. Extract genuinely shared policy before
  using `forwardRef()`. A remaining cycle needs a concrete reason, not a global
  module, service locator, or barrel that hides it.
- Register a provider once with its owner, export the intended capability, and
  import that Nest module at consumers. A TypeScript import does not establish
  container visibility. Detailed binding/scope repairs are a DI concern.
- Keep internal DTOs, errors, tokens and mappers local until their meaning and
  ownership are actually shared. Browser-consumable contracts must not import
  Nest, backend implementation, ORM entities, or vendor SDK types.
- Specify absence, failure, ordering, pagination and side effects when part of
  the contract. Prefer purpose-named operations over a universal action/payload
  API. Keep tenant/user/transaction state out of mutable singleton fields.

## Decisions and stop conditions

Do not mandate interfaces per service, generic CRUD bases, use-case classes per
method, CQRS, queues, outboxes, event sourcing, microservices, or a new ORM. A
proposed abstraction must protect a present boundary, invariant or variation.
If a request requires a materially different public contract or ownership model,
explain the conflict and resolve that decision before changing it. Missing
infrastructure is a verification limit, not permission to substitute fake proof.

## Validation and output

Use existing focused checks. Exercise the real configured endpoint/job for its
changed contract; use the actual database for rollback, constraints and races.
For changed composition, smoke the real feature module rather than a separately
recreated provider graph. Add durable tests for plausible observable regressions,
not class existence, forwarding, or wiring-only coverage. Do not run every suite
for a local design change or invent repository commands.

Report the chosen owner and dependency direction, why an extraction is needed,
preserved safety properties, affected callers/contracts, exercised evidence and
unverified limits. For guidance-only work, label proposed changes as proposals.

Consult [Nest modules](https://docs.nestjs.com/modules) for visibility and
[circular dependencies](https://docs.nestjs.com/fundamentals/circular-dependency)
for framework mechanics; neither prescribes a mandatory application architecture.
