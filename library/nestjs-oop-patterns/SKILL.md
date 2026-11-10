---
name: nestjs-oop-patterns
description: >-
  Design NestJS application behavior around invariants and substitutable
  capabilities. Use when modeling state transitions, adding genuinely
  interchangeable algorithms or external adapters, deciding between a function,
  switch, strategy or domain factory, or replacing harmful inheritance and
  speculative abstractions. Do not activate for routine CRUD, module/token wiring
  alone, generic style review, or every new endpoint or service.
---

# NestJS OOP Patterns

## Objective and sources

Protect a concrete invariant or behavior contract with the smallest useful model.
OOP is an option for cohesive state or behavior, not a requirement for CRUD.

1. Read repository instructions, accepted behavior, and affected business contracts.
2. Trace current callers, state owners, external boundaries, and tests before
   choosing a pattern. Identify which behavior actually varies today or in the task.
3. Preserve local error, cancellation, construction, and persistence conventions.
   Use language/framework documentation for mechanics, not as architecture policy.
4. Read [Invariant and adapter reasoning](references/invariants-and-adapters.md)
   when changing state ownership, replacing an implementation, or normalizing an
   external protocol; it gives worked failure cases rather than a class template.

## Workflow

1. **Name what must remain true.** State the invariant, accepted inputs, output,
   failure outcome, side effects, and operation owner. For an extraction, identify
   the independently changing concern, not a desired file length or pattern name.
2. **Choose the simplest shape.** Keep a pure calculation as a function and a small
   closed decision as an exhaustive switch. Retain a concrete local service when
   there is no meaningful variation. Do not manufacture an interface for mocking.
3. **Define the behavioral seam.** For real alternatives, write the consumer-owned
   capability in business terms, including cancellation, completion, unknown data,
   and errors. Do not mirror an SDK's entire API or force unrelated capabilities
   onto implementations that would normally throw “unsupported.”
4. **Implement without changing unrelated guarantees.** Keep creation, operation
   selection, and deployment configuration distinct. Keep dependency construction
   at composition boundaries; container registration and scopes are separate work.
5. **Migrate affected callers and evidence.** Remove obsolete wrappers and branches;
   preserve the same observable behavior unless the requirement changes it. State
   how the next known variant would be added, including configuration and tests.

## Choose a pattern only for a concrete pressure

| Pressure | Smallest useful design | Stop condition |
| --- | --- | --- |
| Local deterministic validation or mapping | Pure function | No state or dependencies need a class. |
| Small, closed set of domain states | Exhaustive switch/discriminated union | A registry would hide exhaustiveness without independent algorithms. |
| Substantial interchangeable algorithms | Strategy capability plus actual implementations | Do not add hypothetical implementations or plugin discovery. |
| Creation has meaningful valid combinations | Constructor or named domain factory | Inject a factory only when creation needs collaborators. |
| Vendor protocol differs from application needs | Adapter that normalizes data, failures, cancellation | A wrapper that only renames SDK methods earns no boundary. |
| Behavior must compose around one capability | Explicit collaborator/decorator with ordering and error semantics | Do not confuse this pattern with TypeScript/Nest annotations. |
| Reused utility code or cohesive CRUD | Function or existing service | No base controller/service or universal repository just for reuse. |

A registry selects an existing strategy; a domain factory creates a new valid
object. Neither implies a per-operation container factory. Deployment-wide adapter
selection can remain one explicit configuration decision rather than a registry.

## Protect invariants where state is owned

- Put meaningful transitions behind intention-revealing operations. Validate before
  mutation so a rejected operation leaves state unchanged. Check creation, update,
  and rehydration paths; persistence hydration may bypass ordinary constructors.
- Keep constructors synchronous and free of I/O, subscriptions, or overridable
  method calls. Ordinary domain values can be created with `new`; they do not need
  framework decorators or service status.
- Prevent mutation through collection/object aliases where it would break the
  invariant. TypeScript `readonly` is not deep or runtime immutability; do not copy
  everything by default when ownership already prevents mutation.
- Keep operation/entity state with that operation/entity. Do not share mutable
  current-user, tenant, or transaction fields across unrelated operations.
- An in-memory entity check does not protect a cross-request database invariant.
  Preserve the existing persistence/transaction guarantee rather than claiming the
  object model alone solves concurrent writes.
- Keep DTOs and read models as data when they have no meaningful state behavior.
  Prefer composition; inherit only for genuine substitutability, not shared helpers.

## Require behavioral substitution, not just matching method names

For every interchangeable implementation, preserve supported inputs, postconditions,
nullability, error categories, side-effect semantics, and cancellation behavior.
Do not strengthen preconditions or weaken success guarantees in a new variant.
A matching TypeScript signature does not establish any of these properties.

At an external boundary, normalize SDK events, status/completion reasons, absent
metadata, and sanitized failures into the owned capability. Propagate cancellation
through the external call; define what happens to late callbacks and partial output.
Do not silently convert missing measurements to zero or truncated output to success.
Preserve the project's explicit retry/fallback policy rather than adding one as a
pattern demonstration.

Separate provider-protocol success from business acceptance. An adapter can validate
and normalize a response without deciding whether the business may accept, persist,
or publish it. Keep domain-output checks and current authorization/state decisions
with their business owner, including when results arrive after a delay.

## Validation and output

When execution is authorized, use existing repository commands and focused tests.
Exercise invalid construction, transition boundaries, aliasing, and failure-without-
mutation where changed. For multiple implementations, reuse behavioral contract
cases for cancellation, partial/malformed output, failures, and completion; retain
adapter-specific protocol cases. Test public behavior rather than private methods.

Stop if the proposed abstraction protects no named invariant, meaningful variation,
or independent boundary; keep the direct implementation. If a required contract is
unresolved, identify the missing business decision rather than inventing behavior.

Report the chosen seam or reason no pattern was needed, preserved guarantees,
next-variant steps when relevant, affected contracts/docs/tests, exercised checks,
and exact deferred checks or blockers. Do not present recommendations as changes.

## Mechanics, not architectural mandates

- [Nest custom providers](https://docs.nestjs.com/fundamentals/custom-providers): construction and composition mechanisms, not a requirement for classes at every boundary.
- [TypeScript readonly properties](https://www.typescriptlang.org/docs/handbook/2/objects.html#readonly-properties): compile-time restrictions and aliasing limits.
