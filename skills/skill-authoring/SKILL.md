---
name: skill-authoring
argument-hint: "[skill request, skill name, or path]"
description: Creates and fixes Claude Code and Agent Skills. ALWAYS invoke this skill for SKILL.md authoring, review, testing, debugging, or activation issues. Do not handle them directly.
---

# Skill Authoring

Create or revise Claude Code skills that are discoverable, narrowly routed, concise, safe, and testable.

## Core rules

- Follow the current Claude Code `SKILL.md` schema. Do not add undocumented routing fields such as `keywords`.
- Treat `description` as the primary auto-activation contract.
- Put the most important trigger first because skill-listing descriptions can be truncated.
- Use directive routing: explicitly require invocation and block the action Claude would otherwise perform directly.
- Keep trigger domains distinct from other installed skills. Do not make every skill claim broad terms such as `code`, `debug`, `files`, or `project`.
- Keep the skill body operational and concise. State what to do, not a long explanation of why. Keep `SKILL.md` below 500 lines and split large material into supporting files.
- Prefer fixing the description over adding prompt hooks. Use hooks only when deterministic enforcement is genuinely required.
- Do not rely on `CLAUDE.md` to compensate for an ambiguous skill description.
- Write descriptions in third person while retaining explicit directive routing.
- Prefer stable rules over version- or date-specific instructions that will become stale.

## Workflow

### 1. Determine the contract

From the request and repository, identify:

1. **Capability** — the specialized work this skill performs.
2. **Positive triggers** — phrases, concepts, file types, tools, and user intents that should activate it.
3. **Implicit triggers** — natural requests that need the skill without naming it.
4. **Negative boundaries** — nearby requests that must not activate it.
5. **Bypass action** — what Claude is likely to do directly instead of invoking the skill.
6. **Invocation mode** — automatic, manual, or both.
7. **Execution context** — inline or `context: fork`.
8. **Required permissions** — tools that need pre-approval or must be unavailable.

Inspect existing `.claude/skills/` directories when available. Compare names and descriptions before selecting triggers.

### 2. Choose frontmatter deliberately

Use only fields required by the workflow.

```yaml
---
name: <kebab-case-name>
argument-hint: "[optional arguments]"
description: <domain and capability>. ALWAYS invoke this skill when the user asks about <specific natural triggers>. Do not <likely bypass action> directly — use this skill first.
---
```

Apply these rules:

- `name`: short, specific, lowercase kebab-case; maximum 64 characters; only lowercase letters, numbers, and hyphens; the name must not contain the reserved words `claude` or `anthropic`.
- `description`: explain both what the skill does and when it must run.
- Start with the highest-value trigger and capability.
- Include explicit terms, common synonyms, and important implicit intents.
- Use `ALWAYS invoke this skill` for requests inside the skill's domain.
- End with a negative constraint that blocks the most probable bypass path.
- Keep `description` below 1,024 characters for Agent Skills compatibility and keep `description` plus `when_to_use` below Claude Code's listing limit. Prefer one strong description over duplicated trigger prose.
- Add `when_to_use` only when compact examples materially clarify routing.
- Use `disable-model-invocation: true` for destructive, expensive, deployment, publishing, or intentionally manual workflows.
- Use `user-invocable: false` only for background knowledge that should not appear in the slash menu.
- Use `paths` when activation must be limited to particular files or directories.
- Use `context: fork` for isolated research or large workflows that should not pollute the main context.
- Add `agent`, `model`, `effort`, or `background` only when the request justifies them.
- Remember that `allowed-tools` pre-approves tools for the invocation turn; it does not restrict all other tools.
- Use `disallowed-tools` when a tool must be unavailable while the skill is active.

### 3. Write executable instructions

Structure the body around actions:

1. State the objective.
2. Define inputs and source-of-truth order.
3. Provide ordered execution steps.
4. Define decision points and stop conditions.
5. Specify validation checks.
6. Define the final output contract.

Use imperative language. Match instruction freedom to task fragility: use heuristics for flexible tasks, parameterized patterns for moderately constrained tasks, and exact commands with validation for fragile operations. Make important constraints explicit with `MUST`, `NEVER`, or `ONLY` when ambiguity would cause incorrect behavior.

Do not:

- Repeat the frontmatter description throughout the body.
- Add generic advice unrelated to execution.
- Invent project commands, paths, APIs, tools, or credentials.
- Hide critical instructions in examples.
- Put large reference material directly in `SKILL.md`.

For substantial material, create supporting files such as:

```text
<skill-name>/
├── SKILL.md
├── references/
├── examples/
├── templates/
└── scripts/
```

Reference supporting resources explicitly and load them only when needed. Keep references one level deep from `SKILL.md`; add a table of contents to reference files longer than about 100 lines. Use `${CLAUDE_SKILL_DIR}` for portable paths to bundled files and `${CLAUDE_PROJECT_DIR}` for the active project.

### 4. Prevent trigger collisions

Before finalizing, compare the proposed description with existing skills.

- Narrow overlapping nouns with intent, technology, file type, lifecycle phase, or directory scope.
- Do not let two skills both claim the same general request.
- Where overlap is intentional, state the selection boundary in each description.
- Prefer one orchestrating skill over several skills with indistinguishable triggers.

### 5. Build activation tests

Create a compact test matrix containing:

- At least 5 **should-trigger** prompts:
  - direct name or exact term;
  - common natural phrasing;
  - synonym phrasing;
  - implicit intent;
  - a realistic edge case.
- At least 3 **should-not-trigger** prompts:
  - an adjacent domain;
  - a superficially similar keyword with different intent;
  - a request belonging to another skill.

Evaluate activation and output quality separately. A skill invoking successfully does not prove its workflow is correct.

Run tests in fresh sessions so authoring context does not mask routing defects. Test every model the skill is expected to support. When available, use the official `skill-creator` evaluator for should-trigger and should-not-trigger comparisons.

### 6. Diagnose activation failures

Check in this order:

1. Confirm the skill is located at `<scope>/.claude/skills/<name>/SKILL.md`.
2. Validate YAML frontmatter and delimiters.
3. Confirm the skill is listed by asking what skills are available.
4. Ensure `disable-model-invocation` and skill visibility settings do not hide it.
5. Verify the description contains words users naturally use.
6. Move critical triggers earlier and shorten low-value prose.
7. Remove trigger overlap with other skills.
8. Test with a direct `/skill-name` invocation to separate discovery from workflow errors.
9. Use `/doctor`, `/context`, and `--debug` to inspect listing budget or parsing problems.
10. Add hooks only after description, visibility, placement, and collision problems are ruled out.

When a skill triggers too often, narrow the description or make it manual. Do not weaken a precise description merely to reduce activation frequency.

## Output requirements

When creating or updating a skill:

- Write the actual `SKILL.md` file when filesystem access is available.
- Preserve valid existing behavior unless the user asks for a redesign.
- Report the resulting path.
- Summarize the activation contract in one sentence.
- List the strongest should-trigger and should-not-trigger tests.
- Identify any remaining trigger collision or permission risk.
