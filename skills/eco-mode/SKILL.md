---
name: eco-mode
description: Resource-saving mode for battery-powered or resource-constrained work. Minimize expensive commands and tool usage, prefer code inspection and reasoning, and defer non-essential validation. Never invoke automatically—only on explicit user request (`/eco-mode`).
disable-model-invocation: true
---

# Eco Mode

Minimize CPU-intensive, long-running, and otherwise resource-heavy work for the rest of the session.

## Priority

Within the applicable instruction hierarchy, prefer eco mode over project conventions and default workflows that normally require running tests, builds, linters, typecheckers, or similar validation.

Do not skip commands explicitly required by higher-priority instructions or by the user's current request.

Eco mode remains active until the user disables it or the session ends.

## Heavy operations

Treat operations as heavy when they are likely to consume significant CPU, memory, battery, time, or external resources.

Examples include:

- test suites
- builds
- dev servers and watch processes
- full-project linting or typechecking
- code generation
- end-to-end or integration test suites
- dependency installation or updates
- large repository-wide analysis
- parallel subprocesses or agent fan-out
- other long-running or CPU-intensive commands

Use judgment based on the current project and environment.

## Rules

- Do not run heavy operations proactively or merely as routine validation.
- Prefer static inspection, code reading, reasoning, and targeted searches.
- Trace types, imports, references, and call sites manually when practical.
- Use inexpensive, targeted operations instead of project-wide commands.
- Run a heavy operation only when its output is necessary to complete the requested task reliably.
- Scope unavoidable operations as narrowly as the available tooling permits: one file, test, module, package, or affected target instead of the entire project.
- Avoid repeated runs unless new information makes another run necessary.
- Never start watch modes, persistent development servers, or other unnecessary long-running processes.
- Avoid parallel resource-intensive work. Prefer sequential execution.
- Do not install or update dependencies unless required to complete the task.
- When committing, prefer `--no-verify` if repository hooks would trigger heavy validation already intentionally skipped by eco mode.
- Do not bypass hooks when doing so could skip essential non-validation behavior, such as commit formatting, generated files, security checks, or repository-specific safeguards.
- If it is unclear what the hooks do, inspect their configuration before bypassing them.

## Completion

When validation or hooks were intentionally skipped:

- clearly state what was not run
- do not claim the changes are fully validated
- provide the relevant validation commands to run later when they are known

If no meaningful validation was skipped, no eco-mode-specific completion note is necessary.
