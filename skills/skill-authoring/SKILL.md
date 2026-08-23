---
name: skill-authoring
description: Create, review, repair, test, and debug Agent Skills and SKILL.md packages. ALWAYS use this skill for skill structure, frontmatter, activation, trigger collisions, supporting resources, scripts, validation, or portability across agent hosts. Do not author or modify a SKILL.md without applying this workflow.
---

# Skill Authoring

Create portable, discoverable, narrowly routed, concise, safe, and testable skills.

Default to the Agent Skills standard. Add host-specific behavior only when the target host is explicitly requested.

## Workflow

### 1. Define the routing contract

Identify:

- **Capability** — the specialized work the skill performs.
- **Positive triggers** — natural requests that should activate it.
- **Implicit triggers** — requests that need it without naming its domain.
- **Negative boundaries** — nearby requests that must not activate it.
- **Bypass action** — what the agent might incorrectly do instead.
- **Invocation requirement** — automatic, manual, or both.
- **Target hosts** — only when host-specific behavior is required.

Inspect neighboring installed skills when available. Narrow overlapping descriptions by intent, technology, file type, lifecycle phase, or directory scope.

Ask the user only when an unresolved decision materially changes the skill. Prefer the host's structured user-input tool when available:

- Claude Code: `AskUserQuestion`
- oh-my-pi: `ask`
- pi.dev: `ask_user` when an ask-user extension is installed

Otherwise, ask one concise question in chat. Do not require these tool names in portable frontmatter.

### 2. Use the portable package layout

```text
<skill-name>/
├── SKILL.md
├── references/    # Optional documentation and examples
├── scripts/       # Optional executable helpers
├── assets/        # Optional templates and static data
└── evals/         # Optional activation and output tests
```

Apply these rules:

- Create only directories the skill actually needs.
- Put detailed documentation and examples in `references/`.
- Put reusable templates, schemas, sample data, and static resources in `assets/`.
- Put executable helpers in `scripts/`.
- Keep each skill directly below the configured skills root for broad host compatibility.
- Reference bundled files with paths relative to the skill root.
- Keep referenced resources one level deep where practical.
- Do not use host-specific path variables in a portable skill.

### 3. Write portable frontmatter

Use this default:

```yaml
---
name: <directory-name>
description: <capability>. ALWAYS use this skill when <natural user intents and triggers>. Do not <likely bypass action> directly; apply this skill first.
---
```

Rules:

- `name` must match the parent directory.
- Use 1–64 lowercase letters, numbers, and hyphens.
- Do not use leading, trailing, or consecutive hyphens.
- Keep `description` at or below 1,024 characters.
- Describe both what the skill does and when to use it.
- Put the highest-value capability and trigger first.
- Describe user intent rather than internal implementation.
- Include important natural phrasing, synonyms, and implicit intents.
- Use directive routing only when the domain is narrow and unambiguous.
- Do not let multiple skills claim the same broad triggers.
- Do not add undocumented fields such as `keywords`.

Portable optional fields are:

- `license`
- `compatibility`
- `metadata`
- `allowed-tools`

Treat `allowed-tools` as experimental and omit it unless the target hosts support it and the skill genuinely needs pre-approved tools.

Do not add host-specific fields to a universal skill, including:

- `argument-hint`
- `arguments`
- `when_to_use`
- `disable-model-invocation`
- `user-invocable`
- `paths`
- `context`
- `agent`
- `model`
- `effort`
- `background`
- `hooks`
- `disallowed-tools`

Add such fields only when creating a deliberately host-specific variant and after verifying the current host documentation.

### 4. Write executable instructions

Structure the body around:

1. Objective.
2. Inputs and source-of-truth order.
3. Ordered workflow.
4. Decision points and stop conditions.
5. Validation.
6. Final output contract.

Use imperative language. State what to do rather than explaining the history or rationale behind every rule.

Use `MUST`, `NEVER`, and `ONLY` only where ambiguity would cause incorrect or unsafe behavior.

Do not:

- Repeat the frontmatter description in the body.
- Add generic advice unrelated to execution.
- Invent commands, paths, APIs, credentials, or project conventions.
- Hide important requirements only inside examples.
- Overfit rules to one named file, symbol, or component.
- Put large reference material directly in `SKILL.md`.

Keep `SKILL.md` below 500 lines. Explicitly state when an agent should read each reference or use each asset.

### 5. Bundle scripts safely

Scripts are helpers, not independently activated capabilities. The skill activates first; the agent runs a script only when `SKILL.md` explicitly instructs it to do so.

For every bundled script:

- State its purpose and the exact condition for running it.
- Document its inputs, outputs, prerequisites, and side effects.
- Provide an exact command using a relative path and explicit interpreter:

```bash
python3 scripts/validate.py <path>
bash scripts/check.sh <path>
node scripts/generate.mjs <path>
```

- Prefer non-interactive scripts. Collect required user decisions before execution and pass them as arguments.
- Make the script self-contained or document and pin its dependencies.
- Do not hide package installation, network access, authentication, or external writes.
- Validate arguments and reject ambiguous input instead of guessing.
- Provide concise `--help` output and actionable error messages.
- Send machine-readable data to stdout and diagnostics to stderr when appropriate.
- Use meaningful exit codes.
- Make retryable operations idempotent where practical.
- Provide `--dry-run`, `--confirm`, or `--force` safeguards for destructive or stateful actions.
- Never expose credentials or secret values in output.

Do not run a script merely because it exists. Run it only at the workflow step that names it and only after its prerequisites are satisfied.

### 6. Validate the package

After creating or editing a skill, run the standard validator when available:

```bash
skills-ref validate <skill-directory>
```

Otherwise verify manually:

- YAML frontmatter parses correctly.
- `name` matches the directory.
- `name` and `description` satisfy standard limits.
- Only portable fields are present unless a host-specific variant was requested.
- Every referenced file exists.
- Every script command and prerequisite is documented.
- No empty or unused supporting directories remain.
- The body defines validation and output requirements.

Fix validation failures and repeat until validation passes.

### 7. Test routing and output

Test activation separately from workflow quality.

For activation tests, include realistic:

- direct requests;
- natural phrasing;
- synonym phrasing;
- implicit intent;
- boundary and edge cases;
- near-misses sharing similar keywords;
- requests belonging to another skill.

Start with a compact test set. When activation reliability matters, expand toward 8–10 should-trigger and 8–10 should-not-trigger cases.

For output testing:

- Start with 2–3 representative cases.
- Include expected outputs and at least one edge case.
- Compare the result with and without the skill, or against the previous version.
- Run tests in fresh sessions.
- Test each intended host and model when practical.
- Use the host's skill evaluator when one is available.

### 8. Diagnose activation failures

Check in this order:

1. Confirm the file is named exactly `SKILL.md`.
2. Confirm the skill is in a directory scanned by the host.
3. Confirm the host supports the directory depth being used.
4. Validate frontmatter and YAML delimiters.
5. Confirm the skill appears in the host's available-skills listing.
6. Try explicit invocation to separate discovery problems from workflow problems:
   - Claude Code: `/skill-name`
   - pi.dev: `/skill:skill-name`
   - oh-my-pi: `/skill:skill-name`
7. Confirm the description contains language users naturally use.
8. Check for duplicate names and trigger collisions.
9. Test in a fresh session in case discovery is cached.
10. Narrow or strengthen the description before adding host-specific hooks.

If a skill must be manual-only, use the target host's supported invocation-control mechanism. The portable Agent Skills format does not provide a universal manual-only field.

## Output requirements

When creating or updating a skill:

- Write the actual files when filesystem access is available.
- Preserve valid existing behavior unless redesign was requested.
- Report the resulting path.
- Summarize the routing contract in one sentence.
- Report validation performed and its result.
- Provide representative should-trigger and should-not-trigger tests.
- Identify remaining trigger-collision, portability, dependency, or permission risks.
