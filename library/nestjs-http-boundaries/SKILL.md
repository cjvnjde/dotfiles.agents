---
name: nestjs-http-boundaries
description: >-
  Implement safe NestJS HTTP input, authorization, and response boundaries.
  Use when changing DTO runtime validation, request coercion, PATCH semantics,
  tenant/resource access, response serialization, error mapping, or bootstrap
  middleware parity. Exclude generic TypeScript style, service decomposition,
  database concurrency design, and test-harness-only work.
---

# NestJS HTTP Boundaries

## Objective and source order

Preserve the public contract from untrusted request through authorized operation
and safe response, without changing the project's framework or security stack.

1. Read repository instructions and the affected endpoint's accepted contract.
2. Inspect nearby controllers, DTOs/schemas, guards, owner access methods, response
   mapping, exception filters, and callers of the same operation outside HTTP.
3. Read actual bootstrap/setup, adapter and middleware order, package versions,
   decorator/compiler settings, and relevant request tests. Existing runtime
   configuration outranks a tutorial; do not infer it from a DTO annotation.
   Inspect each relevant field's validation metadata and actual access policy;
   never assume protected fields are undecorated or every cross-tenant actor is
   forbidden. Derive assertions from those facts; state what cannot be inspected.
4. For version-sensitive behavior consult [Nest validation](https://docs.nestjs.com/application/validation)
   and [serialization](https://docs.nestjs.com/application/serialization).
   Check APIs against installed versions; current docs may describe newer features.

## Workflow

1. **State the boundary contract.** Identify the actor, client-selected resource
   or tenant, accepted fields, missing/null behavior, permitted effects, response
   fields, and expected error/status contract before editing.
2. **Retain runtime validation.** With reflection-based `ValidationPipe`, use
   concrete decorated DTO classes and value imports. Interfaces, generic type
   arguments and type-only imports cannot supply the required runtime metadata.
   With schema validation, bind the actual schema to the existing runtime pipe;
   an inferred type alone validates nothing. Do not switch validation libraries.
3. **Decide unknown-field behavior.** For class-validator DTOs, `whitelist` strips
   fields without validation decorators; `whitelist` plus `forbidNonWhitelisted`
   rejects them. Type annotations and documentation decorators are not validation
   decorators. Preserve intentional stripping versus rejection, including nested
   objects. Neither choice authorizes a field or a caller.
4. **Validate values, not just shapes.** Inspect nested-object construction and
   nested validation separately; with class-based validation, ensure nested values
   become the expected instances and receive nested rules. Check array elements
   and collection bounds as well as the container. Parse IDs, booleans, dates and
   pagination through the project's supported pipes/schema transformations, then
   enforce semantic limits. Do not equate conversion with validity or use JavaScript
   truthiness to parse a string boolean.
5. **Define updates precisely.** Distinguish absent, null, empty and explicit values
   through validation, transformation and mapping. `@IsOptional()` skips validation
   for both null and undefined; this can be correct when omission means unchanged
   and null means clear. Still validate non-null values, including empty strings.
   If omission is allowed but null is forbidden, skip only undefined and let the
   field validators reject null. Conversely, skipping only undefined before
   `@IsString()` would reject an intentionally nullable field: choose optionality
   and value validators together from the contract, not one universal recipe.
   Inspect mapped-type helpers and skip options too. DTO defaults or coercion must
   not turn an omitted PATCH field into an unintended write.
6. **Allowlist writes.** Map accepted values into the operation's command explicitly;
   never spread an incoming body into an entity or persistence update. Select only
   caller-writable fields, keeping server-owned identity, tenant, role and state
   separate. Keep transport decorators and request objects out of reusable policy.
7. **Authorize the operation.** Take identity from authenticated state. Treat a
   client tenant selector as a request requiring membership/permission checks, not
   proof of authority. Enforce resource/tenant predicates at the owning operation
   or query, including internal and background entrypoints. A route guard or valid
   object ID alone does not establish ownership. Preserve privacy-safe not-found
   versus forbidden behavior and existing authority rechecks for delayed results.
8. **Shape output deliberately.** Return an explicit safe projection or the existing
   serializer's allowlisted output, not arbitrary entities/provider objects. A
   return type does not remove runtime fields. For class serialization, inspect
   interceptor registration, actual instances versus plain objects, nested wrappers
   and configured conversion/exposure options; decorators alone do not guarantee
   exclusion. Check raw response/stream paths separately where serialization is
   bypassed. Keep secrets and internal diagnostics out of success and error bodies.
9. **Translate known failures once.** Keep domain failures independent of HTTP and
   map them through established filters/boundaries. Preserve expected conflict,
   denial and absence contracts; do not turn unexpected errors into HTTP 400 or
   empty success. Preserve causes internally without leaking sensitive payloads.
10. **Preserve the deployed pipeline.** Reuse shared setup rather than a second
    bootstrap. Retain adapter, prefixes/versioning, global pipes/guards/filters/
    interceptors, proxy trust, credentialed-origin rules, parser limits, rate limits,
    private-cache policy and auth middleware ordering where configured. Check which
    routes bypass that pipeline; do not install a replacement security framework.

## Worked decision: partial profile update

For a contract where omission keeps a display name and null is forbidden, `{}`
must leave the stored name unchanged and `{"displayName": null}` must fail before
writing. An optional helper that skips null plus a body spread would violate both
validation intent and write ownership. Validate supplied values, preserve omission
in the mapped command, and ignore or reject `tenantId` according to the established
unknown-field contract; never use it to grant tenant access.

## Validation, stops and output

- Choose request-level checks for changed coercion, nested/unknown fields, PATCH
  omission/null, denied/cross-tenant access, error mapping and safe output. Assert
  forbidden writes and disclosures are absent. Direct controller calls do not
  prove pipes, guards, middleware or serialization; use the configured adapter.
- When execution is authorized, use focused repository checks and behavior tests.
  Otherwise hand off the exact relevant checks; do not claim unexecuted evidence.
- Stop for a materially unresolved contract after inspecting available sources;
  identify the precise missing decision rather than guessing permissions or null
  semantics. Do not expand into service redesign or concurrency infrastructure.
- Update affected API contracts/docs and callers for intentional behavior changes.
  Report changed input/output semantics, authorization placement, pipeline parity,
  checks actually exercised, and remaining limitations. Stop when those claims are
  covered; guidance-only work must not be described as implemented behavior.
