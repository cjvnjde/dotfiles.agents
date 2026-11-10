---
name: skill-authoring
description: Create, review, repair, test, and debug Agent Skills and SKILL.md packages. ALWAYS use for authoring skills, fixing discovery or activation, refining triggers, checking specification compliance or host portability, and packaging skill resources and scripts. Do not author or modify SKILL.md directly; apply this workflow first. Exclude ordinary Markdown/YAML edits, general agent configuration, and executing an existing skill's task without changing the package.
---

# Skill Authoring

Create portable, discoverable, narrowly routed, concise, safe, and testable skills.

Default to the Agent Skills standard. Add host-specific behavior only for an
explicitly requested target or an installation requirement of the current host;
keep that adaptation separate from the portable instructions.

## Inputs and sources of truth

1. Read the user's requirements, the existing skill, applicable project
   instructions, and relevant bundled resources. Preserve valid behavior unless
   redesign was requested. Use real tasks, corrections, and project artifacts
   to ground the workflow.
2. Use the [Agent Skills specification](https://agentskills.io/specification)
   as the authority for package format and standard frontmatter. Consult it
   when creating a package, reviewing compliance, or changing structural rules.
3. Use the target host's current official documentation and installed version
   for discovery paths, invocation, permissions, supported fields, and tools.
   A host extension does not become part of the portable standard.
4. Use the official [authoring guidance](https://agentskills.io/skill-creation/best-practices)
   for instruction design. Use the [activation article](https://medium.com/@ivan.seleznov1/why-claude-code-skills-dont-activate-and-how-to-fix-it-86f679409af1)
   as empirical guidance for description experiments, not a specification or
   a guarantee of activation across hosts, models, or neighboring skills.

Distinguish **format requirements**, **authoring recommendations**, and
**host-specific behavior**. If a source cannot be checked, state what remains
unverified; do not invent current capabilities or claim current compliance.
Use the host's management workflow for installation, updates, and publication.
This skill governs package contents and their validation, not authorization.

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
- **Success criteria** — observable outputs or behavior that demonstrate value.

Inspect neighboring installed skills when available. Narrow overlapping
descriptions by intent, technology, file type, lifecycle phase, or directory
scope. Do not rewrite other skills without authorization. Compose with a host's
mandatory skill-management workflow instead of competing with it.

Ask only when an unresolved decision materially changes the skill and cannot
be resolved from the request or existing context. Prefer an available structured
user-input tool. Host-specific examples, subject to installed capabilities:

- Claude Code: `AskUserQuestion`.
- oh-my-pi: `ask`.
- pi.dev: `ask_user` when an extension providing that tool is installed.

Otherwise, ask one concise question in chat. Do not put these tool names in
portable frontmatter or make optional tools prerequisites for authoring.

### 2. Use the portable package layout

```text
<skill-name>/
├── SKILL.md      # Required: YAML frontmatter followed by Markdown
├── references/   # Optional documentation and examples
├── scripts/      # Optional executable helpers
├── assets/       # Optional templates and static data
└── evals/        # Optional local convention for tests
```

Only `SKILL.md` is required. The standard permits additional files and
directories; it does not prescribe an `evals/` schema or host installation root.

Apply these authoring defaults:

- Create only directories the skill needs.
- Put detailed documentation and examples in `references/`.
- Put reusable templates, schemas, sample data, and static resources in `assets/`.
- Put executable helpers in `scripts/`.
- Keep each authored package directly below the configured skills root for
  broad host compatibility. Verify the host's actual scan depth and settings.
- Keep bundled paths relative to the skill root; avoid machine-specific paths
  and host-specific path variables in the portable core.
- Link supporting resources directly from `SKILL.md` and say when to load them.
  Avoid chains where one reference must be read to discover another. Nested
  asset directories are allowed when useful.
- Keep host UI metadata and adapters outside the portable frontmatter.
- Preserve host-managed storage identifiers. If the host renames installed
  directories, validate name matching in the authored/exported portable package
  and report the installation-specific mapping separately.

### 3. Write portable frontmatter

Start with a scoped description:

```yaml
---
name: skill-name
description: >-
  Perform the specialized capability. Use when the user requests the relevant
  task, including natural synonyms and implicit intents. Exclude adjacent work
  that belongs to another skill.
---
```

For a narrow, unambiguous domain, strengthen it with directive routing:

```yaml
description: >-
  Perform the specialized capability. ALWAYS use this skill when the request
  matches these specific intents. Do not perform the likely bypass action
  directly; apply this skill first.
```

Replace every placeholder with concrete task language. Treat directive wording
as a hypothesis to test, not enforcement, permission, or guaranteed activation.

#### Standard field contract

| Field | Requirement |
| --- | --- |
| `name` | Required string, 1–64 characters; lowercase alphanumeric characters and hyphens; no leading, trailing, or consecutive hyphens; matches the containing portable package directory. |
| `description` | Required nonempty string, 1–1,024 characters; states the capability and when to use it. |
| `license` | Optional string naming the license or referring to a bundled license file. |
| `compatibility` | Optional string, 1–500 characters when present; states actual environment requirements. Omit when unnecessary. |
| `metadata` | Optional mapping of string keys to string values. Use reasonably distinctive keys. |
| `allowed-tools` | Optional, experimental, space-separated string of tool permissions. Support and semantics vary by host. |

For new portable names, default to ASCII matching
`^[a-z0-9]+(?:-[a-z0-9]+)*$`, with the separate 64-character limit. This is a
compatibility policy: the current specification/reference implementation also
permits lowercase Unicode alphanumerics. Check intended hosts before using them.

Check the parsed YAML values, not their source layout. Use a YAML block scalar
or appropriate quoting when descriptions contain YAML-significant punctuation.
Quote numeric or boolean-looking metadata values, such as `version: "1.0"`.
Reject duplicate keys as an authoring safeguard; some YAML parsers hide them.

For descriptions:

- Put the highest-value capability and trigger first.
- Describe user intent rather than internal implementation.
- Include useful natural phrasing, synonyms, and implicit intents.
- Keep critical routing information in frontmatter; the body is read after
  selection and cannot reliably repair a missing trigger.
- Include a concise negative boundary when adjacent skills could collide.
- Do not let multiple skills claim the same broad triggers.

Do not invent top-level fields such as `keywords`. Custom descriptive data may
go under `metadata`, but do not assume it affects routing or changes host behavior.
Omit `allowed-tools` unless the intended hosts support its syntax and the task
needs it. It does not override runtime permissions or user authorization.

Do not put host extensions in universal frontmatter, including `argument-hint`,
`arguments`, `when_to_use`, `disable-model-invocation`, `user-invocable`, `paths`,
`context`, `agent`, `model`, `effort`, `background`, `hooks`, `disallowed-tools`,
or `hide`. This is not an exhaustive list. Use an extension only for an explicit
host adaptation after checking that host's current documentation.

### 4. Write executable instructions

Structure the body around:

1. Objective.
2. Inputs and source-of-truth order.
3. Ordered workflow.
4. Decision points and stop conditions.
5. Validation.
6. Final output contract.

Use imperative language and concrete actions. Match detail to task fragility:
give exact sequences for sensitive operations and room for judgment elsewhere.
Use `MUST`, `NEVER`, and `ONLY` where ambiguity would cause incorrect or unsafe
behavior. State an actionable fallback when a required capability is missing.

Do not:

- Repeat the frontmatter description in the body.
- Add generic advice unrelated to execution.
- Invent commands, paths, APIs, credentials, or project conventions.
- Hide important requirements only inside examples.
- Overfit rules to one named file, symbol, or component.
- Put large reference material directly in `SKILL.md`.

Design for progressive disclosure: concise metadata for selection, the core
workflow on activation, and supporting resources only when needed. Target fewer
than 500 lines for `SKILL.md` and fewer than 5,000 tokens for its instructions.
These are authoring recommendations, not Markdown syntax constraints; the
specification does not mandate particular body headings.

Explicitly state when to read each reference or use each asset. Keep references
focused and provide navigation for long ones. Avoid duplicating rules across
the body and references. Prefer a small working example over generic exposition.

### 5. Bundle scripts safely

Scripts are helpers, not independently activated skills. Run a bundled script
only at the workflow step that names it and after its prerequisites are met.

For every script in the target package:

- State its purpose and the exact condition for running it.
- Document inputs, outputs, prerequisites, working directory, and side effects.
- Provide an exact command with a relative path and explicit interpreter.
  Example command forms, only for scripts that actually exist in that package:

  ```bash
  python3 scripts/validate.py <path>
  bash scripts/check.sh <path>
  node scripts/generate.mjs <path>
  ```

- Resolve the skill root from the host-provided location. Set the command's
  working directory to that root or resolve the helper to an absolute path at
  runtime; do not assume the user's project directory is the skill directory.
- Resolve project/input paths before changing working directory so a relative
  input does not silently point somewhere else.
- Prefer non-interactive execution. Collect required decisions first and pass
  them as arguments; preserve authorization already given.
- Make the helper self-contained or document and pin its dependencies.
- Disclose package installation, network access, authentication, and external writes.
- Validate arguments and reject ambiguous input instead of guessing.
- Provide concise `--help` output, actionable errors, and meaningful exit codes.
- Send machine-readable results to stdout and diagnostics to stderr when appropriate.
- Make retries idempotent where practical.
- Provide appropriate dry-run or explicit execution safeguards for destructive
  actions; do not require fresh confirmation for every harmless state change.
- Never expose credentials or secret values in output.

Inspect new or changed helpers before executing them. Test relevant normal,
invalid-input, and failure cases in a disposable environment when feasible.
Do not execute a helper merely because it exists or install dependencies silently.
Read the official [script guidance](https://agentskills.io/skill-creation/using-scripts)
when adding nontrivial executable helpers.

### 6. Validate the package

After creating or editing a skill, run the official reference validator when
available, using the actual package path:

```bash
skills-ref validate <skill-directory>
```

Use the [reference implementation](https://github.com/agentskills/agentskills/tree/main/skills-ref)
to confirm the command and supported checks. Also run a required host validator
when applicable. Record which tools and versions were used when available.
If a validator is unavailable, perform the checks manually and state that limit.
Do not install tooling silently or weaken a valid package to satisfy a stale
validator; identify any mismatch with the current specification.

Whether or not a validator passes, verify:

- YAML parses to a mapping without duplicate keys; delimiters are correct.
- Required strings, name/directory matching, and character limits are correct.
- Optional field types and limits match the standard field contract above.
- Only standard fields are present unless a host adaptation was requested.
- Every actual bundled reference resolves, including referenced license files.
- Every script invocation, prerequisite, and side effect is documented.
- Changed helpers pass the relevant checks, or execution is explicitly unverified.
- No placeholders, empty directories, or unused supporting files remain.
- The body defines validation, stop conditions, and output requirements.
- The package is self-contained apart from its declared dependencies.

Fix failures and rerun the affected checks. Do not equate frontmatter validation
with complete conformance: reference tools may omit checks or lag the spec.
Passing them proves neither host discovery nor activation, script safety, or
workflow quality.

### 7. Test routing and output

Separate **discovery**, **activation**, and **workflow/output quality**.

For activation, include realistic:

- Direct requests and explicit invocations.
- Natural phrasing and synonyms.
- Implicit intent.
- Boundary and edge cases.
- Near-misses sharing similar keywords.
- Requests belonging to another skill.

Include both should-trigger and should-not-trigger cases. Use explicit invocation
to check availability, but assess automatic selection with prompts that do not
name or command use of the skill. Start small; when routing reliability matters,
expand toward 8–10 cases in each group. Store reusable cases in `evals/` only if
useful; the standard does not require an evaluation format.

Define observable activation evidence for each host: a dedicated skill tool,
instruction injection, or reading the selected `SKILL.md` may be the mechanism.
Do not universally count a file read as failure. Check subsequent adherence
separately; an activation event alone is not proof of a successful workflow.

For output testing:

- Start with 2–3 representative tasks, including an edge case.
- Define expected artifacts and observable acceptance criteria before execution.
- Compare with the previous version or a no-skill baseline on equivalent inputs.
- Use fresh sessions with representative neighboring skills and available tools.
- Test intended hosts/models when available; repeat uncertain routing cases.
- Inspect outputs and execution traces. Record missed and unwanted activations.
- Use a host evaluator if available, after verifying its actual interface.
- Keep expected answers out of the agent-under-test's prompt. Include holdout
  cases when repeatedly tuning descriptions to avoid fitting only the test set.

Do not change hooks, global instructions, permissions, or tool availability just
to obtain a better activation score. Label deliberately restricted experiments
and distinguish them from realistic runs. Report executed checks separately
from proposed cases; never invent test results.

### 8. Diagnose activation failures

Check in this order:

1. Confirm the file is named exactly `SKILL.md`.
2. Confirm its directory is scanned by the host and discovery is enabled.
3. Confirm the host supports the directory depth being used.
4. Validate YAML delimiters, frontmatter, and package naming.
5. Confirm the skill appears in the available-skills listing and its description
   reaches the model; account for disabled/manual-only settings or listing limits.
6. Try explicit invocation to separate discovery from automatic routing problems.
   Current examples, subject to installed version/configuration:
   - Claude Code: `/skill-name`.
   - pi.dev: `/skill:skill-name`.
   - oh-my-pi: `/skill:skill-name`.
7. Confirm the description uses language users naturally use.
8. Check duplicate names, shadowing, and collisions with neighboring skills.
9. Use the host's documented reload mechanism or a fresh session if cached.
10. Narrow or strengthen the description and retest positive and negative cases
    before considering host-specific hooks.

Once loading is confirmed, debug instruction adherence, tool availability,
permissions, dependencies, and output criteria separately from activation.

For manual-only behavior, use the requested host's documented invocation control.
There is no universal manual-only field in the portable standard. Do not assume
hiding a user command also prevents automatic invocation.

Consult these primary sources only when that host matters:

- [Claude Code skills](https://code.claude.com/docs/en/skills).
- [Claude Code tools](https://code.claude.com/docs/en/tools-reference).
- [pi.dev skills](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md).
- [oh-my-pi skills](https://omp.sh/docs/skills) and [tools](https://omp.sh/docs/tools).
- [pi-ask-user extension](https://github.com/edlsh/pi-ask-user), when using its `ask_user` tool.

## Output requirements

When creating or updating a skill:

- Write actual files when authorized filesystem access is available; otherwise
  provide the complete content and state that it was not saved.
- Preserve valid existing behavior unless redesign was requested.
- Report the resulting package path or host-provided skill location.
- Summarize changes and the routing contract concisely.
- Report format/package checks and their results separately from host tests.
- Provide representative should-trigger and should-not-trigger cases.
- State which hosts/models were actually tested and what remains unverified.
- Identify material remaining collision, portability, dependency, or permission
  issues. Do not invent risks or add unnecessary approval steps.
