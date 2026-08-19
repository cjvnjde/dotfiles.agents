---
name: typescript
description: TypeScript expert for inference-first, minimal, fully typed code. ALWAYS invoke before creating, editing, reviewing, or refactoring TypeScript or TSX files, or changing TypeScript-specific types and configuration. Do not modify TypeScript directly—use this skill first.
---

# TypeScript

Write minimal, strongly typed TypeScript. Let TypeScript infer as much as possible while preserving meaningful contracts and making invalid states difficult to represent.

## Workflow

1. Read the relevant TypeScript configuration, lint rules, and nearby code before editing.
2. Identify the authoritative values, schemas, functions, and types from which other types can be derived.
3. Implement the smallest change that preserves or improves type safety.
4. Remove redundant annotations, assertions, generic arguments, and duplicated shapes introduced or exposed by the change.
5. Run the project's focused type-check, tests, lint, and formatter when available.

## Inference first

**Do not write a type when TypeScript can infer the intended type correctly.**

Avoid redundant:

- Variable annotations when the initializer determines the type.
- Return types when the implementation clearly determines them.
- Explicit generic arguments inferable from arguments.
- Callback parameter types when contextually typed.
- Type assertions when the value already has the required type.
- Named types that merely duplicate an existing inferred shape.

```ts
const count = 0;
const names = users.map((user) => user.name);
const cache = new Map([["key", 1]]);
```

Add explicit types when they provide information inference cannot:

- Function parameters without contextual typing.
- Empty collections or delayed initialization.
- Recursive definitions when inference is insufficient.
- Intentionally widened types.
- Stable external or public contracts where the declared shape is intentional.

```ts
const users: User[] = [];
let config: Config | undefined;

const parseUser = (input: string): User => {
  // ...
};
```

Before adding an annotation or assertion, improve inference if possible.

## Make the compiler do the work

Prefer:

- `as const` when literals must remain narrow.
- `satisfies` when a value should be checked against a type without replacing its inferred type.
- Narrowing over assertions.
- Discriminated unions over objects with combinations of optional fields.
- Exhaustive handling using `never`.
- Derived types over duplicated shapes.

```ts
const STATUS = {
  ACTIVE: "active",
  DISABLED: "disabled",
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS];
```

Use one source of truth. Derive types with `typeof`, `keyof`, indexed access types, `ReturnType`, `Parameters`, `Awaited`, built-in utility types, and mapped or conditional types when genuinely needed.

```ts
type User = Awaited<ReturnType<typeof getUser>>;
type UserId = User["id"];
type GetUserOptions = Parameters<typeof getUser>[0];
```

Do not manually reproduce a type that can be derived from an existing value, function, schema, constant, or other authoritative type.

## Type safety

- **Do not use `any`.** Use a real type or `unknown`.
- Narrow `unknown` before using it.
- Avoid non-null assertions. Narrow or model nullability correctly.
- Avoid type assertions. Prefer narrowing, validation, `satisfies`, or better inference.
- Never use double assertions such as `as unknown as Type` to bypass the type system.
- Do not use `@ts-ignore` or `@ts-nocheck` to silence errors.
- Use `@ts-expect-error` only when intentionally testing or documenting a compiler error.
- Use primitive types (`string`, `number`, `boolean`) instead of boxed types (`String`, `Number`, `Boolean`).

Treat assertions as escape hatches, not normal typing tools. If an external API forces an assertion, keep it narrow and explain why the compiler cannot prove the fact.

## Generics

Use generics only when they preserve a meaningful relationship between types.

```ts
const getProperty = <T, K extends keyof T>(value: T, key: K) => {
  return value[key];
};
```

Avoid generic parameters that appear only once or do not affect the resulting type relationship. Let TypeScript infer generic arguments whenever possible, and use the fewest type parameters necessary.

```ts
const result = mapValue(value, transform);
```

Do not write explicit generic arguments unless inference cannot determine the intended types.

## Model states precisely

Represent valid states directly with discriminated unions:

```ts
type Result<T> =
  | { status: "success"; data: T }
  | { status: "error"; error: Error };
```

Do not model mutually exclusive states as one object with unrelated optional fields.

Use exhaustive handling when all variants must be covered:

```ts
const handleResult = (result: Result<User>) => {
  switch (result.status) {
    case "success":
      return result.data;

    case "error":
      throw result.error;

    default: {
      const exhaustive: never = result;
      return exhaustive;
    }
  }
};
```

## Constants and literal unions

Prefer literal unions or const objects over `enum` for new APIs unless the project or an interoperability boundary requires an enum.

```ts
const DIRECTION = {
  ASC: "asc",
  DESC: "desc",
} as const;

type Direction = (typeof DIRECTION)[keyof typeof DIRECTION];
```

Use `satisfies` when a value must conform to another contract while retaining its precise inferred type. Use `as const` only when narrow or readonly literal inference is useful; do not add it mechanically.

## Boundaries

Treat data from APIs, storage, parsed input, environment variables, and third parties as untrusted:

1. Receive unknown data as `unknown`.
2. Validate or narrow it.
3. Convert it into a trusted internal type.
4. Trust that type afterward.

Do not scatter defensive checks throughout internal code for states the type system already makes impossible.

## Code quality

- Prefer simple concrete code over premature abstractions.
- Do not widen types speculatively.
- Do not create helper types merely to make code appear more strongly typed.
- Avoid duplicate representations of the same concept.
- Prefer immutable or readonly inputs when mutation is unnecessary.
- Keep functions and types focused on one responsibility.
- Use descriptive names; avoid unnecessary abbreviations.
- Always use braces for control structures.

Keep expression-bodied arrows for one simple expression. Use a block for multiple logical steps.

## Project compatibility

Follow the host project's formatter, lint rules, module conventions, naming, file organization, runtime, and framework conventions. Do not introduce unrelated style changes while editing TypeScript.
