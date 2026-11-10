---
name: nestjs-testing
description: >-
  Design and repair NestJS-specific test evidence and integration harnesses.
  Use for runtime DTO metadata, DI tokens/scopes/lifecycle, configured HTTP
  behavior, persistence/transaction/race claims, worker state, or safe test
  infrastructure isolation. Exclude pure TypeScript unit-test design, merely
  running an existing command, production implementation without test work,
  and broad code review without an explicit review request.
---

# NestJS Testing

## Objective and source order

Prove the claimed Nest behavior with the smallest honest boundary. A test's name
or runner project does not establish what its doubles and setup actually exercise.

1. Read repository instructions, requested behavior, nearest tests and fixtures.
2. Inspect installed Nest/runner/ORM versions, test transforms and decorator
   metadata support, environment loading, setup/teardown, and package commands.
3. Trace actual application bootstrap, adapter, module graph, migration path and
   worker lifecycle for the mechanism being tested. Preserve project tooling.
4. Consult [Nest testing](https://docs.nestjs.com/fundamentals/testing) for installed-
   version APIs. Its override examples permit doubles; they do not make a mocked
   service evidence of a real application/database path.
5. Before database, Redis, queue, email, migration or integration-harness changes,
   read [Stateful harness safety](references/stateful-harness.md).

## Choose the proof boundary

State the observable claim and a plausible broken implementation it must reject.
Select only the rows needed; neither all layers nor a new coverage target is required.

| Claim | Minimum useful evidence |
| --- | --- |
| Pure policy or mapping | Direct behavioral unit test; narrow honest doubles allowed |
| Runtime DTO metadata or pipe binding | Request through the configured Nest application |
| Token visibility, alias identity, scoped lifetime | Real relevant module graph and appropriate resolution context |
| Startup/shutdown resource behavior | Initialize and close the relevant real module/application |
| Guards, status/error mapping, serialization | Request through production-equivalent HTTP setup and adapter |
| Query, constraint, rollback | Relevant real database and production persistence path |
| Race or stale state | Independent transactions/contexts with controlled overlap |
| Queue delivery, recovery, late publication | Real owned worker/storage path and durable observable state |

## Build evidence without changing the claim

1. **Keep the mechanism real.** For a full integration claim, retain the owned
   controller/auth/policy/service/repository/storage path. Substitute only external
   systems there, preferably via local protocol fixtures that retain production
   encoding and decoding. For unit or deliberately narrower tests, doubles are
   valid; label excluded coverage instead of calling that full integration.
2. **Exercise the actual graph.** Import the relevant production module instead of
   rebuilding a convenient graph. Apply overrides to the runtime token actually
   consumed, before compilation. Do not auto-mock the graph whose wiring is the
   claim. Use smoke checks for basic registration; add lasting behavior tests for
   meaningful alias identity, selection or resource-ownership risks, not existence
   and forwarding assertions that merely pad coverage.
3. **Respect Nest resolution phases.** `get()` retrieves static providers; use
   supported `resolve()`/context APIs for scoped ones. Test same-context sharing
   and distinct-context isolation according to the intended scope, including
   request registration when needed. Compile alone does not prove lifecycle hooks
   or an initialized HTTP adapter. Initialize and close the appropriate context;
   do not infer request-scoped hook behavior from singleton lifecycle tests.
4. **Preserve transport parity.** Reuse actual application creation/setup, or extract
   shared setup when necessary rather than copy a subset. Include the production
   adapter, global pipes/guards/filters/interceptors, middleware order, parser
   limits, prefix/versioning and relevant security configuration. Await adapter
   readiness where required; listen only if the scenario needs a real URL/stream.
   Send requests through that adapter, not direct controller methods.
5. **Prove permissions and output.** Keep authentication/authorization real when
   claiming those guarantees. Arrange legitimate actors with existing helpers;
   do not replace the tested guard with unconditional allow. Assert relevant
   allowed/denied and cross-tenant cases, precise status/error contracts, safe
   fields, and absence of forbidden persisted effects.
6. **Prove durable outcomes.** Use real constraints, migrations, transaction paths
   and worker machinery for those claims. A repository spy proves neither SQL nor
   commit/rollback. A directly invoked job handler proves its behavior, not queue
   delivery or recovery. Read committed state in fresh persistence contexts.
7. **Synchronize deliberately.** Coordinate race contenders with controlled barriers,
   not sleeps; independent contexts must actually overlap at the threatened
   invariant. Use bounded polling only for genuinely eventual external/worker
   transitions, with useful final-state diagnostics. Do not retry a failed request
   until it passes or use global fake timers around real sockets.
8. **Own teardown.** Track acquired resources immediately and clean up on partial
   setup failure too. Quiesce owned work before removing fixtures, close connections
   and application resources, and restore environment/spies/timers. Preserve
   cleanup failures while still attempting remaining independent cleanup.

## Validation, stops and output

- Derive focused commands from repository scripts/configuration; do not invent
  commands or silently install a runner. When authorized, run the affected target
  first and expand only for a remaining concrete shared-path risk or required gate.
- Treat ambiguous storage targets, missing infrastructure or absent production
  setup as blockers to the affected claim. Do not silently fall back to in-memory
  storage, bypassed security, schema synchronization or skipped integration.
- Investigate unexpected errors, unhandled requests/rejections and leaked handles;
  do not weaken assertions, suppress failures or add retries to manufacture a pass.
- Update affected test/harness instructions when behavior changes. Report tests
  changed, behavior proved, real versus substituted boundaries, exact executed
  commands/results, and unverified claims or setup blockers. If execution is
  delegated, provide the relevant commands without claiming they passed.
- Stop once the requested evidence is covered. Do not turn a test task into a
  broad code review, unrelated cleanup, framework migration or infrastructure project.
