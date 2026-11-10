# Selection and ownership cases

## Deployment choice is not operation dispatch

Suppose an application exports documents through one configured remote processor.
A validated configuration selects one adapter at startup. Bind its capability token
with `useFactory`, explicitly injecting the configuration owner. A small exhaustive
switch returning the selected adapter is sufficient; invalid configuration fails
startup without silently selecting a default processor.

The factory may construct a plain adapter with `new` when it supplies all required
inputs. This is deliberate composition, not business code manually reconstructing
an injected service. If the adapter needs a ready connection, await readiness in the
factory and assign cleanup to one owner. Returning a third-party client does not
magically turn its `close()` method into a Nest lifecycle hook.

Do not create a strategy registry just because two deployment options exist. Do
not move operation-specific inputs into singleton initialization. Creating a new
business document with valid fields is a separate domain-construction decision.

## A registry earns its place through per-operation variation

Now suppose each export operation requests a format, and independent renderers
have substantive algorithms or SDK behavior. Compose those existing renderers
into a collection provider through explicit `inject` entries in argument order.
Inject that collection into a narrow registry, not the Nest container itself.

Define these outcomes before implementation:

| Event | Required decision |
| --- | --- |
| Two renderers claim the same format | Fail registry construction; never let map insertion order silently decide. |
| A request names an unsupported format | Return/throw the project's explicit unsupported-format outcome; no default renderer. |
| A supported format is disallowed for this actor | Reject through business authorization; lookup alone grants no permission. |
| Another format is added | Add implementation, explicit registration, supported-input contract, and relevant tests. |

A typical composition consists of renderer class providers, one factory returning
an array of those injected instances, and the registry. Registering the collection
token repeatedly does not aggregate values; `multi: true` is not a Nest provider
option. Keep the registry's map private so callers cannot overwrite dispatch rules.
Freeze or copy only where caller aliasing would otherwise violate ownership.

A tiny closed set of trivial render functions may need only a switch. A registry
is not automatically more extensible than a deliberate composition edit.

## Aliases express intentional runtime identity

Suppose `DocumentTransport` is already registered and a consumer needs a capability
token `TRANSPORT`. The conceptual registration is:

```ts
providers: [
  DocumentTransport,
  { provide: TRANSPORT, useExisting: DocumentTransport },
],
exports: [TRANSPORT],
```

The snippet shows module metadata, not a standalone module; use the project's
actual runtime token and class imports. With singleton scope, both names resolve
to the same object. This binding is an intentional public capability, not an obsolete
compatibility alias. Replacing it with `useClass: DocumentTransport` creates a
separate registration and may duplicate connection pools, timers, or caches.
If no caller needs the concrete class token, one `useClass` binding may suffice.
For scoped providers, verify identity within the intended resolution context rather
than extrapolating singleton behavior.

## Reusable integration configuration

Use a static module for application-local composition. Introduce a dynamic module
when its importers need a configuration API; follow the package's existing naming
and registration semantics. Consider `ConfigurableModuleBuilder` only when repeated
sync/async options plumbing is the actual problem.

For async options, make the configuration dependencies visible through the dynamic
module's imports and use the documented factory/class/existing-provider form.
Reusing an existing options provider is different from constructing another one.
Validate required values at the configuration boundary, keep secrets out of error
messages, and avoid environment reads scattered through business operations.
Repeated dynamic-module registration may intentionally create different configured
resources; determine whether that is wanted before trying to deduplicate them.
