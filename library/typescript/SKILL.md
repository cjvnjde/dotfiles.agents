---
name: typescript
description: Write or review TypeScript and TSX with inference-first, minimal, safe types. Use for implementation, type design, runtime boundary validation, type errors, and TypeScript compiler configuration; combine it with code-style and relevant framework guidance. Do not use for JavaScript or framework work without a TypeScript-specific concern.
---

# TypeScript

Use the smallest type design that makes valid behavior clear and invalid states difficult to represent.

## Start with project constraints

- Read the relevant `tsconfig`, lint and formatting rules, nearby code, and applicable framework guidance before editing.
- Follow established module, naming, file-layout, runtime, and framework conventions. When no filename convention exists, prefer lowercase kebab-case while preserving framework-reserved names. Do not introduce unrelated style changes.
- Implement the smallest coherent change, then run already-configured focused formatting, typecheck, lint, and tests when relevant. Do not add or reconfigure tooling merely to validate the change.

## Use JavaScript syntax deliberately

- Define top-level named functions with function declarations.
- Use `const` arrow functions for nested helpers and inline callbacks. Use a nested `function` only when generator or dynamic `this` or `arguments` semantics require it.
- Use `const` by default, `let` only for necessary reassignment, and never `var`.

## Prefer inference

Do not annotate what TypeScript already infers correctly. Usually omit types for initialized variables, obvious return values, contextually typed callbacks, and inferable generic arguments.

Add an explicit type when it communicates information inference cannot, such as an untyped parameter, empty collection, delayed initialization, recursive definition, intentional widening, or stable public contract.

Before adding an assertion or annotation, improve the source of inference when practical. Use `satisfies` to check a value without replacing its inferred type and `as const` when literal or readonly inference is intentional.

Prefer `type` for ordinary aliases and object shapes. Use `interface` for class-oriented contracts, intentional declaration merging, and library augmentation.

## Keep one source of truth

Derive types from authoritative values, functions, schemas, and existing types with `typeof`, `keyof`, indexed access, `ReturnType`, `Parameters`, `Awaited`, and built-in utility types. Do not manually duplicate a shape that can be derived.

Represent finite categories according to runtime needs: use a literal union when type-only, an `as const` tuple when runtime iteration is needed, and an `as const` object for named runtime constants. Use an enum only for project conventions or interoperability.

## Protect type boundaries

- Treat unvalidated runtime data from APIs, storage, JSON, environment, and untyped third parties as `unknown`. Validate or narrow it once at the boundary, then expose a trusted internal type.
- Prefer narrowing, validation, and better modeling over assertions and non-null assertions. Do not use double assertions as a normal escape hatch.
- Prefer `unknown` to `any`. Permit a narrowly contained, documented `any`, assertion, or suppression only when broken external declarations or an explicit migration make it unavoidable; expose a safe typed result.
- Use `@ts-expect-error`, with a reason, for an intentional line-scoped compiler exception. Do not add `@ts-ignore` or `@ts-nocheck` outside an explicit migration.
- Use lowercase primitive types and precise object shapes; avoid boxed primitives and `{}` as a catch-all. Express non-mutation with `readonly` when it is part of the contract.
- Use `property?: T` only when omission is meaningful; use `property: T | undefined` when the key is required but its value may be absent.
- Use branded or opaque types when confusing interchangeable primitives poses real risk; otherwise encode units or formats in names such as `timeoutMs`.
- Keep public contracts as narrow as current requirements allow. After boundary validation, do not scatter checks for states the types exclude.

## Model states explicitly

Use discriminated unions for mutually exclusive states instead of unrelated optional fields. Narrow through control flow and use a `never` exhaustiveness check when missing a variant would be unsafe.

## Handle errors and asynchronous work explicitly

- Treat caught values as `unknown` and narrow them before use. Preserve the original error through the project's established mechanism, using `cause` when supported.
- Await every promise unless it is intentionally detached with explicit rejection handling. Do not use asynchronous callbacks with APIs, such as `forEach`, that ignore returned promises.
- Run independent operations concurrently and dependent operations sequentially. Keep cancellation and cleanup explicit, and use either callback- or promise-based completion per contract, not both.

## Use meaningful generics

Use a generic only when it preserves a meaningful type relationship or parameterizes a reusable container or contract. Avoid parameters that add no information, speculative flexibility, and explicit generic arguments that inference can supply. Use the fewest parameters necessary.

## Keep reusable boundaries explicit

- Extract reusable domain or platform logic only when it has an independently useful contract. Keep framework-local component, state, reactivity, and lifecycle behavior in the framework layer.
- Pass ordinary values and explicit dependencies into reusable code instead of framework setters, stores, or lifecycle hooks; adapt results at the framework boundary. Let platform-facing modules use the real platform API rather than a speculative wrapper.
- Return caller-controlled cleanup or a handle for registered listeners and owned resources. Prefer functions and composition for stateless behavior; introduce a class or manager only when shared identity, mutable state, or lifecycle is essential.

Report changed public contracts and ownership or cleanup behavior when relevant, plus the focused checks run and any checks not run.
