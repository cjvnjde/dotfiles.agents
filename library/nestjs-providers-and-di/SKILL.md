---
name: nestjs-providers-and-di
description: >-
  Design and diagnose NestJS container composition: custom providers, runtime
  tokens, module visibility, strategy registration, scopes, asynchronous readiness,
  and resource cleanup. Use when fixing dependency-resolution errors, duplicated
  service instances, configurable integration wiring, or provider lifetime bugs.
  Do not activate for every service edit, pure domain modeling, routine HTTP
  changes, or generic TypeScript refactoring without a container concern.
---

# NestJS Providers and DI

## Objective and sources

Make the dependency graph explicit and give each resource one construction and
cleanup owner. Prefer an ordinary class provider until the actual binding differs.

1. Read repository instructions and accepted configuration/lifecycle behavior.
2. Inspect installed Nest versions, compiler/decorator settings, affected module
   metadata, constructor imports, factories, bootstrap, and relevant tests.
3. Trace the requested token through registration, owner exports, consumer imports,
   and scope. Follow working local conventions before adapting upstream examples.
4. Consult the official sources below for mechanics; check installed-major support
   before applying current APIs. Do not upgrade dependencies to fit an example.

## Workflow

1. **Name the decision time.** Startup configuration chooses a deployment binding;
   per-operation selection chooses an existing strategy; domain creation makes a
   new valid value/entity. A singleton `useFactory` is not a per-call factory.
2. **Choose one binding.** Use the table below; keep business execution out of
   provider construction and declare every factory dependency explicitly.
3. **Wire the owner once.** Export only the public token consumers require and
   import its owner module. Do not register the same service again to fix visibility.
4. **Account for lifetime.** Identify contextual data, async readiness, resource
   cleanup, and callers that outlive an HTTP request before changing scope.
5. **Change all affected consumers and tests.** Preserve intentional runtime aliases;
   remove obsolete registrations and forwarding paths, not useful token bindings.

| Need | Binding | Failure to prevent |
| --- | --- | --- |
| Stable local collaborator | Class provider | An interface/token for every service adds no capability. |
| Token backed by an implementation | `useClass` | Registering the concrete class separately can create a second instance. |
| Another token for an existing registration | `useExisting` | Replacing an alias with `useClass` changes identity; singleton aliases share the target instance. |
| Derived options, construction, async readiness | `useFactory` | Match `inject` order to factory parameters; types alone do not inject arguments. |
| Existing value, constant options, test double | `useValue` | Mutable objects can leak state across consumers or tests. |

### Runtime identity and visibility

- Types/interfaces are erased: pair them with an explicit `@Inject(TOKEN)` and a
  runtime token. Define each symbol once; equal descriptions do not make two
  `Symbol(...)` calls equal. Keep tokens in dependency-light files, not module files.
- Classes and abstract classes used as tokens must remain runtime values. Keep
  value imports for decorator-metadata injection; use type-only imports for erased
  contracts with explicit tokens. Inspect the actual compiler pipeline if metadata
  is absent rather than applying unrelated TypeScript settings.
- Prefer constructor injection. Let Nest construct injected services; ordinary
  values and deliberately factory-owned adapters/clients may use `new`. A factory
  may supply all adapter inputs explicitly; adapters need not each be Nest classes.
- Do not replace explicit dependencies with application-level `ModuleRef` lookups,
  discovery, or a global registry. Reserve those mechanisms for a concrete
  infrastructure requirement with visible ownership and lifecycle.

### Selection and configurable modules

Inject one configured implementation when the choice is deployment-wide. For real
per-operation variation, assemble candidates explicitly, reject duplicate keys
when constructing the registry, and reject unknown keys on lookup. Nest does not
provide Angular's `multi: true`; repeated ordinary bindings do not form an array.
Registry membership is not authorization to use a strategy.

Read [Selection and ownership cases](references/selection-and-ownership.md) when
choosing a registry, configuring a reusable integration, or resolving duplicate
instances. Use a dynamic module only when importers actually need configuration;
`register`, `forRoot`, and `forFeature` are conventions, not enforced semantics.

### State, readiness, and cleanup

- Default to singleton scope for stateless services and shared clients. Never put
  the current user, tenant, transaction, or operation in mutable singleton fields.
  Singleton identity is local to an application context/process, not a distributed lock.
- Pass operation context explicitly or use the established isolated context
  mechanism. A contextual ORM manager or async-local store does not itself require
  request-scoped Nest services. Background jobs need their own context boundary.
- Request scope propagates to dependent consumers; transient means a dedicated
  instance per injecting consumer, not per method call. Check installed-version
  restrictions for gateways, schedulers, and authentication integrations.
- Use an async provider when dependents must receive a ready resource: Nest awaits
  its promise before constructing those dependents. Never hide unawaited I/O in a
  constructor. On failed initialization, release resources already acquired.
- Give resource owners bounded cleanup, including timers/subscriptions and active
  work. Implement appropriate lifecycle hooks; enable shutdown hooks for process
  signals and explicitly close test applications. Request-scoped classes do not
  receive application lifecycle hooks; use operation-owned cleanup for them.

## Diagnose before adding `forwardRef`

1. Use the reported module, constructor index, and token to locate the failing edge.
   Check `providers` versus `imports`, missing exports/imports, duplicate registration,
   factory argument order, self-injection, and mismatched token identity first.
2. For `Object`/undefined metadata, check erased imports and circular file/barrel
   imports. For an unresolved core `ModuleRef`, inspect duplicate `@nestjs/core`
   copies. Use `NEST_DEBUG` resolution logs when the graph remains unclear.
3. Only for a genuine mutual dependency, separate shared policy or introduce a
   cohesive coordinator. Use `forwardRef` for a documented remaining constraint,
   with the required provider/module sides; never rely on constructor order.

## Validation and output

When execution is authorized, use repository commands and a focused Nest testing
module with realistic imports to resolve changed public tokens and prove singleton
alias identity. For changed lifetimes, initialize the app, exercise readiness/failure
and cleanup, then close it; compilation alone does not run initialization hooks.
Cover duplicate/unknown registry keys and concurrent context isolation when changed.
Stop when the requested graph and lifecycle behavior are established; do not add a
plugin framework or change scope to mask a missing token.

Report binding and owner choices, scope/readiness/cleanup changes, affected public
configuration/docs/tests, checks actually run, and exact deferred checks or blockers.

## Official mechanics

- [Custom providers](https://docs.nestjs.com/fundamentals/custom-providers) and [dynamic modules](https://docs.nestjs.com/fundamentals/dynamic-modules)
- [Injection scopes](https://docs.nestjs.com/fundamentals/injection-scopes) and [async providers](https://docs.nestjs.com/fundamentals/async-providers)
- [Lifecycle events](https://docs.nestjs.com/fundamentals/lifecycle-events)
- [Dependency errors](https://docs.nestjs.com/faq/common-errors) and [circular dependencies](https://docs.nestjs.com/fundamentals/circular-dependency)
