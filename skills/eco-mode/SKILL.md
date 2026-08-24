---
name: eco-mode
description: Conserves battery and constrained resources by minimizing expensive commands, preferring inspection, and deferring non-essential validation. Invoke only when the user explicitly enables eco mode; never activate it automatically.
disable-model-invocation: true
---

# Eco Mode

Minimize CPU, battery, time, and external-resource use while active. Treat it as active for the current conversation until the user disables it, but do not claim that every host can persist this state across compaction, subagents, or new sessions.

Higher-priority instructions and validation explicitly required by the user still apply.

## Rules

- Prefer code reading, reasoning, and targeted searches over routine execution.
- Treat full test suites, builds, development servers, watch processes, project-wide linting or typechecking, code generation, integration or end-to-end suites, dependency operations, large analyses, and resource-heavy parallel local work as expensive.
- Run an expensive operation only when its result is necessary for reliable completion.
- Scope unavoidable commands to the smallest affected file, test, module, package, or target.
- Avoid repeated runs and persistent processes.
- Do not install or update dependencies unless required by the task.
- When committing, use `--no-verify` only if inspected hooks perform validation intentionally skipped under eco mode.
- Never bypass hooks that perform generation, commit formatting, security or policy checks, repository safeguards, or other essential non-validation work. If hook behavior is unclear, inspect its configuration first.

## Completion

When validation or hooks were skipped:

- State exactly what was not run.
- Do not claim full validation.
- Provide the relevant commands to run later when known.

If nothing meaningful was skipped, add no eco-specific note.
