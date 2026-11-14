# Personal Agent Configuration

Keep the global agent context small. Store project skills here as an opt-in library, not as globally installed instructions.

## Layout

```text
agents/
├── AGENTS.md                  # Optional shared global instructions
├── setup.sh
├── skills/                    # Installed globally
│   ├── dotfiles/
│   ├── eco-mode/
│   └── skill-authoring/
└── library/                   # Install selected packages into projects
    ├── code-style/
    ├── codereview/
    ├── commit/
    ├── debugging/
    ├── licence/
    ├── nestjs-architecture/
    ├── nestjs-http-boundaries/
    ├── nestjs-oop-patterns/
    ├── nestjs-providers-and-di/
    ├── nestjs-testing/
    ├── testing/
    └── typescript/
```

Each skill directory contains `SKILL.md` and any supporting files. Keep packages directly under `skills/` or `library/`.

Skill-owned instructions, references, templates, data, and helpers must be bundled
inside each package and referenced relative to its root. Do not depend on files
elsewhere on the author's system or symlinks escaping the package; verify packages
work when copied alone. Runtime project inputs and documented tools remain external.

- `AGENTS.md` (optional): only project-independent instructions. Do not add a library inventory or instructions to scan the library on every task.
- `skills/`: deliberately small global set. `dotfiles` routes project skill setup and refresh requests to the library through the `skills` CLI; library packages remain project-local. `eco-mode` is an explicitly enabled, project-neutral resource policy; `skill-authoring` supports creating and maintaining skills. Global availability does not mean automatic activation.
- `library/`: reusable project-level packages. Add new skills here by default. Setup neither installs nor links this directory into agent discovery paths.

Skills commonly expose names and descriptions before their full bodies are loaded. Keeping the library outside installed skill directories avoids that discovery overhead and irrelevant activation. Do not globally install the entire library or link it wholesale into a project.

### NestJS library packages

Choose by the task, not merely because a project uses Nest. These packages are
independently usable and complement the existing language, style, testing and
review skills; installing the entire set is not required.

| Package | Use for |
| --- | --- |
| [nestjs-architecture](library/nestjs-architecture/SKILL.md) | Feature ownership, service decomposition, cross-feature workflows, transactions, tenant isolation and concurrent/delayed effects |
| [nestjs-http-boundaries](library/nestjs-http-boundaries/SKILL.md) | Runtime DTO/schema validation, PATCH semantics, resource authorization, safe responses and HTTP pipeline parity |
| [nestjs-oop-patterns](library/nestjs-oop-patterns/SKILL.md) | Invariants, substantive variation, behavioral substitution and choosing a simpler alternative to a pattern |
| [nestjs-providers-and-di](library/nestjs-providers-and-di/SKILL.md) | Runtime tokens, module visibility, binding identity, registries, scopes and resource lifecycles |
| [nestjs-testing](library/nestjs-testing/SKILL.md) | Nest-specific proof boundaries, real HTTP/database/worker evidence and safe stateful fixture isolation |

Detailed persistence, composition, invariant/adapter and harness guidance is loaded
from each package's references only when relevant. Framework mechanics are separate
from design defaults: preserve the target project's stack and accepted contracts,
without importing a fixed ORM, test runner, folder tree, retry policy or coverage
target. Generic TypeScript styling and broad code review remain in their existing
skills.

## Install global configuration

Enable `agents` in `.modules`, then run:

```bash
bash setup.sh
```

Or run this module directly:

```bash
bash agents/setup.sh enable
```

The module uses the latest [`skills`](https://github.com/vercel-labs/skills) CLI non-interactively. With the current global set, its installation command is equivalent to:

```bash
npx --yes skills@latest add ./agents/skills \
  --global \
  --skill dotfiles eco-mode skill-authoring \
  --agent universal \
  --yes
```

Setup derives the explicit skill names from immediate packages in `agents/skills/`; it does not use a wildcard or pass the whole module as the source. Adding packages to `library/` does not change global installation.

The CLI installs global skills for the universal target under `~/.agents/skills/`. Re-running setup refreshes only global skills. The module records installed names under `$XDG_STATE_HOME/dotfiles/agents-skills` (or `~/.local/state/dotfiles/agents-skills`). Previously recorded skills that are no longer in `skills/`, including those moved into `library/`, are removed from global installation on the next enable. Unrecorded CLI installs are not inferred or removed by name.

When `agents/AGENTS.md` exists, setup links it to the universal instruction location, `~/.agents/AGENTS.md`. If it is absent, setup skips instruction linking and still installs global skills, leaving existing instruction files untouched. If the destination already exists, the shared setup helper backs it up before creating the managed link.

Node.js and `npx` are required. The setup script supports macOS's bundled Bash 3.2; no Bash upgrade is required. Unrelated skill names remain untouched; an existing skill with the same name is managed by the `skills` CLI.

## Adopt skills in a project

Once global setup has installed the `dotfiles` skill, ask the agent:

```text
Set up the skills this project needs from my dotfiles library. Install only the
relevant skills into this project with npx skills, not globally. Explain the selections.
```

The routing skill locates the local checkout from known configuration or the managed global instruction link, with `~/dotfiles/agents/` as a checked fallback. It does not assume its installed copy is inside dotfiles.

Selection workflow:

1. Inspect the project's instructions, stack, tooling, existing skills, and requested work before selecting anything.
2. List library package names and inspect their frontmatter descriptions first. Read full bodies and supporting files only for plausible candidates; do not load every skill into context.
3. Select the smallest useful set based on concrete project needs. Broadly applicable does not mean required: do not install style, testing, review, or commit policies merely because this is a code repository. Selecting none is valid.
4. Read selected packages in full. Check referenced skills and host-specific requirements; include another package only when the selected workflow actually needs it. Project instructions and existing conventions take precedence over library defaults.
5. Determine the intended agent and its supported project-local skills directory. Inspect existing same-name skills and preserve local customizations; ask before overwriting conflicting content. Do not target every agent or silently introduce a second skills layout.
6. Run the latest `skills` CLI from the target project with the verified local library path, explicit skill names, the intended agent, and `--copy`. Never use `--global`, `--all`, or wildcards for library adoption. Do not manually copy packages or link them back to dotfiles.
7. Check complete installed packages and referenced resources, then use `skills list` to confirm the intended agent's project-local skills. Report destination paths, generated lockfiles, a short reason for each selection, adaptations, and any unverified live-host activation.

For example, run this from a target project after selecting `debugging` and `testing` for Codex, replacing the source path with your checkout:

```bash
npx --yes skills@latest add /path/to/dotfiles/agents/library \
  --skill debugging testing \
  --agent codex \
  --copy \
  --yes
```

Project copies are owned by the project and may be versioned with it. Library edits and global setup do not update those copies. To refresh local-path installs, compare changes with project adaptations and rerun the same `add` command for the selected names; do not rely on remote update tracking. Updating the dotfiles checkout itself is a separate action governed by its repository instructions. Remove project skills when they no longer serve the project.

## Remove global configuration

```bash
bash agents/setup.sh disable
```

The module removes only managed global instruction links and asks the `skills` CLI to remove only the skill names recorded during installation. It also cleans up legacy direct skill symlinks from older versions of this setup. Files in dotfiles, project-local copies, backups, unrelated instructions, and unrelated installed skills remain untouched.
