# Stateful harness safety

Read before changing or executing Nest integration setup that touches persistent
services. Apply these steps to the repository's actual engine, ORM, queue and
runner; they are not instructions to adopt a particular stack.

## 1. Establish effective targets before mutation

Trace configuration from the command through environment loaders, inherited shell
variables, defaults and service profiles to each effective database, Redis/queue,
SMTP/inbox and external-provider target. A test-named environment file is not proof
that it wins precedence, nor that a loopback service belongs to this test run.

Inspect required key names and test templates without printing secrets. Check
ownership and exclusivity before migrations, truncation, queue pause/drain, limiter
resets or teardown. If the target cannot be established as safe, stop that setup
and report the missing evidence. Do not rewrite local environment files or use
live credentials to make tests run. Report intentional process-local overrides
without exposing values that identify credentials or private service targets.

Use existing lifecycle helpers and committed migrations where production uses
migrations; schema synchronization or a test-only schema copy cannot prove the
migration path. A missing service, migration privilege or test setting is a setup
blocker, not permission to substitute a different engine or skip coverage silently.
Destructive migration tests need a verifiably owned disposable database and
failure-safe close/drop, not a convenient shared development database.

## 2. Identify what is actually isolated

| Apparent isolation | What it does not establish |
| --- | --- |
| Runner file/JavaScript isolation | Separate databases, Redis keys, queues, limiter state or inboxes |
| Unique database rows | Exclusive global queue pause/drain or shared key resets |
| Serial files in one runner | Safety against another runner process or developer using the same services |
| Transaction around the test's entity manager | Rollback of HTTP requests or workers using other connections |
| Fresh application instance | Fresh database, cache, queue or email history |
| ORM identity-map object | Current committed state after another request/transaction or rollback |

Keep established serialization unless independently owned databases, namespaces,
queues and lifecycle controls justify parallel runs. Do not add concurrent tests
against shared state merely because the runner can schedule them.

For persistence assertions, create a fresh ORM unit of work/context or use the
repository's supported fresh-read mechanism. Give concurrent contenders separate
contexts and transactions; never share managed entities as their source of truth.
After rollback, discard stale context state. Check intermediate-write rollback
from outside the failed transaction, and verify participating writes actually use
its connection/transaction rather than independently committing.

## 3. Control scenarios and external effects

Allocate scenario-owned user/resource IDs, job keys and recipients. Track ownership
as resources are acquired, including setup that fails midway. Scope assertions to
those identifiers rather than global row/message counts. Arrange ordinary state
through supported operations; explicit direct persistence setup is appropriate
for otherwise inaccessible fault states, not impossible authority that bypasses
the tested security contract.

For email, inspect only the unique recipient and tracked message IDs. An old link
must not satisfy a later send. A shared inbox is neither empty nor safe to purge:
never delete the whole inbox, broadly delete search results, or release messages
to a real relay. Remove only scenario-owned messages if cleanup requires it.

Prefer local external protocol fixtures that reject unexpected dispatches. If an
SDK-boundary double is necessary, state the encoding/network/protocol coverage
excluded. Do not intercept application/auth traffic along with vendor traffic.
A deterministic SMTP/HTTP fixture proves neither live deliverability nor vendor
availability. Do not use real personal data or paid live calls by default.

For races, locate the contested read/write or state transition first. Hold one
contender at an existing controllable boundary, start the other, release both in
the required order, and assert winner/conflict plus final committed state. Avoid
production-only hooks added merely for a test. Simultaneously starting promises
without proving overlap may never exercise the race.

For background claims, distinguish direct handler invocation, queue scheduling,
worker delivery and restart/recovery. Assert only the path actually exercised.
Check cancellation or authority loss prevents late writes/publication where that
is promised. Do not upgrade idempotent processing to a claim of globally exactly-
once external delivery.

## 4. Release resources without affecting neighbors

1. Stop or quiesce test-owned workers, streams and producers; await their known
   transitions so cleanup cannot race with new fixture writes.
2. Remove only tracked jobs/messages/rows in dependency-safe order. Broad shared
   inbox purge, Redis flush, table truncation and queue obliteration are not fixture
   cleanup. Destructive resets require proven exclusive disposable ownership.
3. Close owned event/queue/network clients, application and persistence resources
   in their required ownership order. Use failure-safe hooks/finally blocks that
   attempt later independent releases even if an earlier release fails.
4. Restore configuration, spies, environment and timers. Report cleanup failures,
   not just assertion results. Never stop unrelated services or kill another
   process because a test port is occupied.

## Worked evidence correction

A test starts a transaction on its fixture entity manager, sends an HTTP update,
then rolls back the fixture transaction. The HTTP request used its own connection
and committed; a passing response does not imply cleanup succeeded. Use owned
fixtures with explicit cleanup or an isolated disposable database, and assert the
HTTP effect from a fresh context. If the test also invokes a handler directly,
report handler/persistence proof separately from untested queue delivery.

## Reporting limits

Record effective-target ownership without secrets, shared resources and required
serialization, cleanup guarantees, and the real versus substituted path. If the
harness lacks automatic ownership guards or comprehensive cleanup, state that
limit rather than describing intended isolation as already implemented.
