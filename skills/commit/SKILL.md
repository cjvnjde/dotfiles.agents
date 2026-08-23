---
name: commit
argument-hint: "[optional commit intent]"
description: Creates focused Git commits with Conventional Commits 1.0.0 messages. ALWAYS invoke this skill when the user asks to commit changes, create a commit, or prepare and execute a Git commit. Do not stage or commit directly—use this skill first. Do not invoke for history review or commit-message explanation without a requested commit.
---

# Commit

Create focused commits without disturbing unrelated work.

## Workflow

1. Inspect repository instructions, status, staged and unstaged diffs, and recent commit subjects. Stop if there is nothing to commit.
2. Include only requested or task-related changes. Preserve unrelated working-tree and index changes; stop if mixed changes cannot be separated safely.
3. Stage selected paths and compose the message from the staged diff.
4. Commit once. Never amend, push, discard changes, or bypass hooks unless explicitly requested.
5. Verify the created commit and remaining status.

## Message

Use:

```text
<type>: <description>
<type>(<scope>): <description>
<type>!: <description>
<type>(<scope>)!: <description>

[optional body]

[optional footer(s)]
```

Choose the type from the staged change:

- `feat`: add a feature.
- `fix`: correct a bug.
- `build`: change the build system or dependencies.
- `chore`: perform maintenance not covered by another type.
- `ci`: change CI configuration or scripts.
- `docs`: change documentation only.
- `style`: change formatting without affecting behavior.
- `refactor`: restructure code without adding a feature or fixing a bug.
- `perf`: improve performance.
- `test`: add or correct tests.
- `revert`: revert an earlier commit.

Repository-defined types remain valid because the specification permits additional types. Mark breaking changes with `!` or a `BREAKING CHANGE: <description>` footer. Keep the description concise, add body or footers only when useful, and never add attribution or generated-by trailers.

## Output

Report the commit hash and subject, plus any uncommitted changes or failed hooks.
