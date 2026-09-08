---
name: code-style
description: Apply language-neutral source-code structure, readability, naming, mutation, and layout conventions. ALWAYS use this skill when creating, editing, refactoring, or formatting source code, or when the user explicitly requests a style or readability review; combine it with language and framework guidance. Do not use for prose-only work, behavior-only review, or generated, vendored, minified, snapshot, or lock files unless explicitly targeted.
---

# Code Style

Write cohesive, direct, readable code without changing behavior or overriding project conventions.

## Source-of-truth order

1. Preserve valid syntax and intended behavior.
2. Follow explicit user requirements.
3. Follow repository instructions, configured tools, nearby code, and language or framework conventions.
4. Apply these defaults only where the sources above do not decide.

Limit style changes to the task's affected code unless broader cleanup is requested. Update generated artifacts, snapshots, and lockfiles through project tooling rather than editing them directly.

## Structure and data flow

- Keep functions cohesive and at one level of abstraction. Do not split cohesive logic merely to shorten it.
- Make inputs, outputs, dependencies, and side effects apparent. Keep I/O and global state access at explicit boundaries.
- Avoid reassigning parameters or mutating caller-owned data. Local mutation is acceptable when isolated and clearer; keep mutable state narrowly scoped.
- Keep return, error, and side-effect behavior consistent within a contract. Avoid positional boolean mode parameters when separate operations or descriptive options are clearer.
- Always use braces for control-flow bodies when the language supports them. Prefer guard clauses when they reduce nesting without obscuring control flow.
- Prefer direct control flow and named intermediate values over dense expressions, implicit coercion, hidden fallthrough, or callbacks with surprising side effects.

## Modules and names

- Prefer one primary exported runtime operation per file when it forms an independently useful boundary. Keep private helpers and companion types or constants beside it; keep cohesive operations together when they share invariants, lifecycle, or ordering.
- Organize modules around cohesive responsibilities, keep dependency direction clear, and avoid circular or bidirectional relationships. Do not create forwarding files or barrels solely to enforce one export.
- Prefer simple concrete code and small readable duplication to speculative abstractions.
- Use precise domain language and established naming conventions. Avoid unexplained abbreviations, vague names, and catch-all modules when a specific concept exists.

## Layout and comments

- Separate distinct logical phases, and a non-initial final `return`, with a blank line when local conventions and formatting tools permit.
- Prefer names and structure over comments that restate code. Keep comments for non-obvious constraints, make each `TODO` identify a concrete unfinished action, and remove dead code instead of commenting it out.
- Run the configured formatter or linter only as appropriate for affected files. Do not add or reconfigure tooling solely to enforce these defaults.

Report the focused formatting, lint, syntax, type, or behavior checks run and any intentional exceptions.
