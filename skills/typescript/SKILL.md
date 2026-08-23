---
name: typescript
description: TypeScript expert for inference-first, minimal, fully typed, modular code with framework-independent reusable boundaries. ALWAYS invoke before creating, editing, reviewing, or refactoring TypeScript or TSX files, or changing TypeScript-specific types and configuration. Use it alongside applicable framework-specific guidance. Do not begin TypeScript work before applying this skill. Do not invoke for prose-only architecture guidance that does not involve TypeScript work.
---

# TypeScript

Write minimal, strongly typed, modular TypeScript. Let TypeScript infer as much as possible while preserving meaningful contracts, making invalid states difficult to represent, and keeping reusable logic independent of consumer frameworks.

## Workflow

1. Read the relevant TypeScript configuration, lint rules, nearby code, and applicable framework guidance before editing.
2. Identify the authoritative values, schemas, functions, and types from which other types can be derived.
3. Before implementation, identify reusable logic, platform and framework boundaries, resource ownership, and the smallest independently useful operations.
4. Implement the smallest change that preserves or improves type safety.
5. Remove redundant annotations, assertions, generic arguments, and duplicated shapes introduced or exposed by the change.
6. Run the project's focused type-check, tests, lint, and formatter when available.

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

## Type aliases and interfaces

- Prefer `type` for type definitions, including object shapes.
- Use `interface` only for class-oriented contracts intended to be implemented by classes or extended by related interfaces.
- Types merely consumed by a class, such as constructor options, unions, callbacks, and derived types, still use `type`.

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
const RESULT_STATUS = {
  SUCCESS: "success",
  ERROR: "error",
} as const;

type Result<T> =
  | { status: typeof RESULT_STATUS.SUCCESS; data: T }
  | { status: typeof RESULT_STATUS.ERROR; error: Error };
```

Do not model mutually exclusive states as one object with unrelated optional fields.

Use exhaustive handling when all variants must be covered:

```ts
const handleResult = (result: Result<User>) => {
  switch (result.status) {
    case RESULT_STATUS.SUCCESS:
      return result.data;

    case RESULT_STATUS.ERROR:
      throw result.error;

    default: {
      const exhaustive: never = result;
      return exhaustive;
    }
  }
};
```

## Constants and literal unions

Represent finite categorical string or numeric values, such as statuses, event types, modes, and directions, with a named `as const` object. Use the object as the single runtime source of truth instead of inline literals or `enum`, unless the project or an interoperability boundary requires an enum.

```ts
const DIRECTION = {
  ASC: "asc",
  DESC: "desc",
} as const;

type Direction = (typeof DIRECTION)[keyof typeof DIRECTION];
```

Derive a union from the object's values when a type is needed. Reference the object properties in discriminated unions, switch cases, comparisons, object creation, and function calls. Never repeat a categorical literal after its const object exists.

Use `satisfies` when a value must conform to another contract while retaining its precise inferred type. Use `as const` for categorical value objects. Otherwise, use it only when narrow or readonly literal inference is useful; do not add it mechanically.

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

### Local functions

Use `const` arrow functions for functions declared inside another function,
including named local helpers and callbacks. Declare each local arrow before its
first use because it is not hoisted.

```ts
const handleMessage = (message: Message) => {
  processMessage(message);
};
```

Keep a nested function declaration only when an arrow cannot express the
required semantics, such as a generator or intentional dynamic `this` or
`arguments`, or when an established project convention requires it. This rule
does not apply to object or class methods or require moving a local helper to
module scope.

## Module and API design

Design modules around cohesive capabilities. Callers should be able to use each
public operation independently and compose operations into their own workflows.

### Boundaries and dependencies

- Keep reusable domain logic and platform integrations independent of UI
  frameworks unless the abstraction's explicit purpose is framework
  integration. Framework adapters may be reusable within their framework.
- Keep framework-local component behavior cohesive unless it has a meaningful
  independent contract. Do not extract code merely to call it
  framework-independent.
- Do not pass framework setters, stores, lifecycle hooks, or framework-owned
  state containers into otherwise reusable logic. Pass ordinary state values as
  explicit inputs, return results or expose subscriptions, and let the
  framework-facing layer translate them into its own state.
- Pass required dependencies and resources explicitly. Prefer returned values
  and handles over hidden mutable singletons, implicit initialization, and
  module-level consumer registration.
- Depending directly on a real platform API is appropriate when the module
  represents that platform integration. Framework independence does not
  require speculative abstractions over the actual runtime boundary.

### Operations and lifecycle

- Start a public API with the smallest complete operations consumers need. Each
  exported function should perform one coherent action and require only the
  dependencies or resources needed for that action.
- Separate resource acquisition, current-state queries, commands, and
  subscriptions in the callable API when those capabilities exist. This does
  not require separate files or require every API to have every category.
- An operation may require an explicitly acquired resource. A query may perform
  I/O but should not start a subscription or perform unrelated domain
  mutations; a command should not register a consumer; acquisition should not
  start unrelated long-lived behavior.
- Every subscription must expose caller-controlled cleanup using the project's
  established convention, such as an unsubscribe function, disposable handle,
  or abort controller. When setup is asynchronous, resolve to the cleanup
  capability. Cleanup must release the registrations created by that call and
  should be safe to use more than once when practical.
- When acquisition creates an owned resource, make ownership clear and expose
  an explicit way to close, dispose of, or release it.
- Prefer functions for stateless operations. Introduce a class, manager,
  service, or controller only when shared identity, mutable state, or lifecycle
  is essential to the abstraction.

### Composition and function size

- Keep workflow orchestration in the consuming application or another clear
  composition root. A convenience orchestrator may compose the same public
  primitives and add policy or defaults, but it must not be the only way to use
  them.
- An orchestrator that acquires resources or starts subscriptions must preserve
  caller control by returning the aggregate result, handle, or cleanup it
  creates.
- Split functions by responsibility, not by line count. Keep a transaction or
  state transition atomic when exposing its steps would permit invalid
  intermediate states, violate ordering, or weaken consistency.
- Use private helpers to organize a cohesive implementation when useful; they
  do not need to become public operations. Avoid forwarding wrappers and
  one-function files created only to appear modular.

Prefer independently composable primitives:

```ts
const resource = await openResource(options);
const state = getState(resource);
const unsubscribe = onStateChange(resource, listener);
```

Avoid making unrelated behavior available only through one controlling entry
point:

```ts
startResource({
  setState,
  onEvent,
});
```

### Design check

Before finishing a new or changed module API:

1. Verify each public operation can be called without initializing unrelated
   capabilities.
2. Confirm reusable modules do not import a consumer framework; keep intentional
   framework dependencies in clearly named framework-facing code.
3. Match every listener, registration, and owned resource with caller-accessible
   cleanup.
4. Confirm smaller public operations do not expose invalid intermediate states
   or break required ordering.

## File naming and exports

- Follow repository lint rules and the host framework's required filenames
  first. TypeScript has no universal filename casing standard; do not introduce
  a second convention beside an established one.
- When the project is unconstrained, use lowercase `kebab-case` for `.ts` and
  `.tsx` filenames. This is the broad modern ecosystem default. Preserve
  `PascalCase` component filenames or `snake_case` modules where the repository
  already uses those conventions.
- Make a filename closely match its primary public operation after converting
  the identifier to the chosen file case: `UserProfile` becomes
  `user-profile.tsx`, `createSession` becomes `create-session.ts`, and a public
  object named `userSchema` belongs in `user-schema.ts`.
- Organize files around one cohesive public concept, usually represented by one
  primary exported runtime operation. Prefer this boundary when the operation
  is independently useful.
- Keep multiple public operations together when they form one cohesive
  capability, share invariants or lifecycle, or are safer and clearer when
  maintained together.
- Split public operations when they are independently meaningful and usable,
  own distinct responsibilities, can change independently, and do not depend
  on shared private state or strict ordering.
- Keep companion exported types or constants beside the runtime value they
  describe. They expose the same public concept and do not violate this
  preference.
- Keep non-exported helpers, local types, constants, and implementation details
  in the file that uses them. Never extract them merely to reduce declaration
  or export count.
- Split by responsibility and independent usability, not by line count or
  export count. Never add forwarding wrappers, artificial files, or barrels
  solely to enforce one export per file.
- Name a multi-export file after its narrow shared theme, such as
  `date-formatters.ts`; avoid generic catch-alls such as `utils.ts`,
  `helpers.ts`, `common.ts`, or `types.ts` when a domain-specific name is
  available.
- Keep framework-reserved names such as `page.tsx`, `layout.tsx`, `route.ts`,
  and `index.ts` exact. Match companion files to their source using the
  project's suffix pattern, such as `.test.ts`, `.spec.ts`, or `.d.ts`.

## Project compatibility

Follow the host project's formatter, lint rules, module conventions, naming, file organization, runtime, and framework conventions. Do not introduce unrelated style changes while editing TypeScript.

## Output

When applicable, report changed public contracts and module boundaries and
where framework-specific composition lives. Always report the focused checks
run. For lifecycle APIs, state who owns each resource and how callers release
it.
