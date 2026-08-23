---
name: code-style
description: Defines consistent source-code formatting and visual grouping, including readable wrapping and blank-line separation between adjacent statement blocks. ALWAYS invoke this skill before writing or modifying source code, formatting code, cleaning up spacing or layout, or reviewing code style. Do not apply formatting conventions ad hoc or run an automatic formatter—use this skill first. Do not invoke for prose-only work or behavioral analysis that does not change code.
---

# Code Style

Make code mechanically consistent and visually segmented without changing behavior. Apply these rules directly; do not run or configure an automatic formatter.

## Source-of-truth order

1. Preserve valid syntax and behavior.
2. Follow explicit user requirements.
3. Follow repository instructions and established project-specific rules.
4. Apply this skill for every choice not decided above.

Generated, vendored, minified, snapshot, and lock files keep their required format unless the task explicitly targets them.

## Workflow

1. Read relevant repository instructions, style configuration, and nearby code.
2. Identify language constraints and project-specific exceptions before editing.
3. Limit formatting to lines touched by the task unless broader reformatting is requested.
4. Apply layout, whitespace, punctuation, wrapping, and block-separation rules below.
5. Re-read the changed region. Confirm formatting caused no semantic change.
6. Run the narrow syntax, compile, or behavior check appropriate to the changed code. Never use a formatting command as validation.

## File naming and module boundaries

- Follow filename conventions required or established by the language,
  ecosystem, framework, build tooling, and repository. Language-specific
  standards take precedence over a universal casing rule.
- Choose a descriptive filename that lets a reader predict the file's primary
  content. When a file has one exported declaration, prefer a filename that
  closely matches that export's name in the idiomatic filename casing. This is
  a recommendation, not a hard rule.
- Prefer one export per source file when that creates a clearer name and module
  boundary. Multiple exports are valid when they form one cohesive concept or
  splitting them would harm locality.
- Keep any number of non-exported helpers, types, constants, and implementation
  details with the exported code they support. Do not split file-private code
  merely to satisfy the one-export preference.
- For a file with multiple exports, name the shared concept rather than one
  arbitrary member. Avoid vague names such as `utils`, `helpers`, `common`, or
  `misc` unless the surrounding scope makes the responsibility precise.
- Preserve tool- or framework-required filenames and established test,
  platform, generated-file, and entry-point patterns. Apply these preferences
  to new files and intentional reorganizations; do not rename unrelated files.

## Layout

- Use spaces, not tabs, unless syntax or an explicit project rule requires tabs.
- Use two spaces for each indentation level unless the project specifies another width.
- Indent continuation lines one level beyond their owning construct. Add more alignment only when it remains stable after names change.
- Keep one statement per line. Do not compress compound statements or bodies onto one line.
- Keep lines at or below 80 columns when practical. Break at syntactic boundaries rather than splitting identifiers, commands, URLs, or indivisible strings.
- Use LF line endings, remove trailing whitespace, and end text files with one newline.
- Never align neighboring assignments, properties, or comments with columns of padding. Normal indentation survives later edits better.
- Use exactly one blank line where separation is required. Do not stack multiple blank lines.

## Whitespace and punctuation

- Put one space around binary, assignment, comparison, logical, and ternary operators.
- Put one space after commas and no space before commas or semicolons.
- Do not add spaces immediately inside parentheses or square brackets.
- Put spaces inside object-like braces when the language permits: `{ key: value }`. Empty braces remain `{}`.
- Put one space between a control-flow keyword and its opening parenthesis: `if (condition)`.
- Do not put a space between a function name and a call parenthesis: `run(value)`.
- Terminate statements with semicolons in languages where semicolons are conventional and legal. Never add them to languages where they are invalid or non-idiomatic.
- Prefer double-quoted strings when either quote style is equivalent. Use the form that avoids escaping when content contains one quote style.
- Add trailing commas to multiline collections, arguments, parameters, imports, exports, and similar lists when the language supports them.
- Keep parentheses around a single arrow-function parameter when that syntax exists.

## Braces and compound statements

- Always use braces for control-flow bodies when the language supports braces, including single-statement bodies.
- Put an opening brace on the same line as its declaration or control header, preceded by one space.
- Put a closing brace on its own line, aligned with the construct that opened it.
- Keep continuation clauses attached: `} else {`, `} catch (error) {`, and `} finally {` form one compound statement.
- Keep `while` attached to the closing brace of a `do` body where that syntax requires it.
- Do not insert blank padding immediately after an opening brace or immediately before its closing brace.
- Keep decorators, annotations, labels, doc comments, and leading explanatory comments attached to the declaration or statement they describe.

## Line wrapping

- Keep a construct on one line while it remains readable and within the line-width target.
- When a comma-separated construct wraps, place each item on its own line, indent one level, include a trailing comma when legal, and put the closing delimiter on its own line.
- Break long boolean or arithmetic expressions before an operator so continuation is obvious.
- Break fluent call chains one operation per line when they no longer fit clearly on one line.
- Keep short signatures on one line. For multiline signatures, place one parameter per line and keep return-type or body syntax aligned with project convention.
- Do not manually preserve unstable horizontal alignment after wrapping.

## Statement-block separation

Treat code as visual units at each indentation level:

- A **compound block** is a control-flow construct, function, method, class, type, module, namespace, or another declaration or expression with a multiline body.
- A **simple group** is one or more adjacent declarations or statements that perform one cohesive step.
- An `if`/`else if`/`else` chain and a `try`/`catch`/`finally` chain each count as one compound block.

Apply these rules:

1. At the same indentation level, put one blank line between adjacent visual units when either unit is a compound block.
2. Put one blank line between a compound block and a preceding or following simple group at the same indentation level.
3. Keep simple statements together when they form one cohesive step. Separate different phases or concerns with one blank line.
4. Treat a `return` statement as its own simple group. When another statement at the same indentation level precedes it, put one blank line before `return`. Do not add blank padding when `return` is the first statement in a block.
5. Indentation already separates a parent block from its direct nested child. Do not add a blank line merely because a nested block is the first or last statement in its parent.
6. Sibling blocks inside the same parent share an indentation level, so separate them with one blank line.
7. Keep continuation clauses attached to their originating block. Never place a blank line before `else`, `catch`, `finally`, or the closing `while` of a `do` statement.
8. Do not put a blank line between a comment, decorator, annotation, or label and the construct it belongs to.
9. Do not add blank lines inside an empty block. Empty vertical space must separate meaningful units, not pad braces.

### Same-level blocks need a blank line

```js
const value = readValue();

if (value === 2) {
  handleValue(value);
}

const result = summarize(value);
```

### Nesting supplies separation

```js
if (outerCondition) {
  if (innerCondition) {
    handleCondition();
  }
} else {
  handleFallback();
}
```

No blank line is needed between the outer opening brace and nested `if`: indentation expresses their relationship. `else` stays attached because it continues the outer `if`.

### Siblings inside a parent need a blank line

```js
if (outerCondition) {
  if (firstCondition) {
    handleFirst();
  }

  if (secondCondition) {
    handleSecond();
  }

  finish();
}
```

The nested `if` statements and `finish()` are separate same-level units, so blank lines separate them.

### Return starts a new visual unit

```js
const width = bounds.right - bounds.left;
const height = bounds.bottom - bounds.top;
const area = width * height;

return area;
```

Declarations stay together because they calculate one result. Blank line marks transition to returning that result.

## Comments

- Prefer code structure and names over comments that restate syntax.
- Put explanatory comments on their own line immediately above the code they govern.
- Start prose comments with one space after the comment marker.
- Wrap prose comments to the same line-width target when practical.
- Preserve directives, licenses, generated markers, and examples whose exact spacing is significant.
- Never use decorative comment bars as substitutes for blank-line grouping.

## Review checklist

- Syntax and behavior unchanged by formatting.
- Indentation reflects scope.
- Same-level statements preceding `return` are separated from it by one blank line.
- Nested parent-child blocks rely on indentation rather than extra padding.
- Continuation clauses remain attached.
- Wrapped constructs use stable indentation and legal trailing commas.
- No tabs, trailing whitespace, stacked blank lines, or unrelated reformatting.
- No formatting tool was run or configured.
