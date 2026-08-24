---
name: typescript
description: Write or review TypeScript and TSX with inference-first, minimal, safe types. Use for TypeScript-specific implementation, type design, boundary validation, and type errors; combine it with relevant framework and repository guidance.
---

# TypeScript

Use the smallest type design that makes valid behavior clear and invalid states difficult to represent.

## Start with project constraints

- Read the relevant `tsconfig`, lint and formatting rules, nearby code, and applicable framework guidance before editing.
- Follow established module, naming, file-layout, runtime, and framework conventions. Do not introduce unrelated style changes.
- Implement the smallest coherent change, then run already-configured focused formatting, typecheck, lint, and tests when relevant. Do not add or reconfigure tooling merely to validate the change.

## Prefer inference

Do not annotate what TypeScript already infers correctly. Usually omit types for initialized variables, obvious return values, contextually typed callbacks, and inferable generic arguments.

Add an explicit type when it communicates information inference cannot, such as an untyped parameter, empty collection, delayed initialization, recursive definition, intentional widening, or stable public contract.

Before adding an assertion or annotation, improve the source of inference when practical. Use `satisfies` to check a value without replacing its inferred type and `as const` when literal or readonly inference is intentional.

Prefer `type` for ordinary aliases and object shapes. Use `interface` for class-oriented contracts, intentional declaration merging, and library augmentation.

## Keep one source of truth

Derive types from authoritative values, functions, schemas, and existing types with `typeof`, `keyof`, indexed access, `ReturnType`, `Parameters`, `Awaited`, and built-in utility types. Do not manually duplicate a shape that can be derived.

Represent finite categorical values according to their runtime needs: use a literal union when type-only, a const tuple when runtime iteration is needed, and an `as const` object when named runtime constants are useful. Use an enum only for project conventions or interoperability.

```ts
const STATUS = {
  ACTIVE: "active",
  DISABLED: "disabled",
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS];
```

## Protect type boundaries

- Receive API, storage, parsed input, environment, and third-party data as `unknown`; validate or narrow it once, then convert it to a trusted internal type.
- Prefer narrowing, validation, and better modeling over assertions or non-null assertions.
- Prefer `unknown` to `any`. Permit a narrowly contained, documented `any`, assertion, or suppression only when broken external declarations or an explicit migration make it unavoidable; expose a safe typed result. Do not use double assertions as a normal escape hatch.
- Use `@ts-expect-error` only when intentionally testing or documenting a compiler error.
- Use primitive types such as `string` and `number`, not boxed types such as `String` and `Number`.
- Do not scatter checks through trusted internal code for states the type system already excludes.

## Model states explicitly

Use discriminated unions for mutually exclusive states instead of unrelated optional fields. Handle variants exhaustively when missing a case would be unsafe.

```ts
type Result<T> =
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

const unwrap = <T>(result: Result<T>) => {
  switch (result.status) {
    case "success": {
      return result.data;
    }

    case "error": {
      throw result.error;
    }

    default: {
      const exhaustive: never = result;
      return exhaustive;
    }
  }
};
```

## Use meaningful generics

Use a generic only when it preserves a meaningful type relationship or parameterizes a reusable container or contract. Avoid parameters that add no information, speculative flexibility, and explicit generic arguments that inference can supply. Use the fewest parameters necessary.

## Keep reusable boundaries explicit

- Extract reusable domain or platform logic only when it has an independently useful contract. Keep framework-local component, state, reactivity, and lifecycle behavior in the framework layer.
- Pass ordinary values and explicit dependencies into reusable code instead of framework setters, stores, or lifecycle hooks. Adapt results at the framework boundary.
- Let explicitly platform-facing modules depend on the real platform API; do not introduce speculative abstractions.
- Expose small, independently useful public operations when doing so preserves invariants and ordering. Keep cohesive operations together when splitting would expose invalid intermediate states.
- When a public operation registers listeners or owns a resource, return caller-controlled cleanup or a handle and make ownership explicit.
- Prefer functions for stateless operations. Introduce a class or manager only when shared identity, mutable state, or lifecycle is essential.

## Keep implementation direct

- Prefer simple concrete code over premature abstractions, widened types, or helper types that add no information.
- Keep companion types and constants beside the runtime value they describe. Avoid catch-all modules, forwarding wrappers, and barrels created only to look modular.
- Follow repository filename conventions. When none exist, prefer lowercase kebab-case while preserving framework-reserved filenames.

Report changed public contracts and ownership or cleanup behavior when relevant, plus the focused checks run and any checks not run.
