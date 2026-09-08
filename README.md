# Personal Agent Configuration

Keep the global agent context small. Store project skills here as an opt-in library, not as globally installed instructions.

## Layout

```text
agents/
├── AGENTS.md                  # Shared global instructions
├── setup.sh
├── skills/                    # Installed globally
│   ├── eco-mode/
│   └── skill-authoring/
└── library/                   # Copy selected packages into projects
    ├── code-style/
    ├── codereview/
    ├── commit/
    ├── debugging/
    ├── licence/
    ├── testing/
    └── typescript/
```

Each skill directory contains `SKILL.md` and any supporting files. Keep packages directly under `skills/` or `library/`.

- `AGENTS.md`: only project-independent instructions. Do not add a library inventory or instructions to scan the library on every task.
- `skills/`: deliberately small global set. `eco-mode` is an explicitly enabled, project-neutral resource policy; `skill-authoring` supports creating and maintaining skills. Global availability does not mean automatic activation.
- `library/`: reusable project-level packages. Add new skills here by default. Setup neither installs nor links this directory into agent discovery paths.

Skills commonly expose names and descriptions before their full bodies are loaded. Keeping the library outside installed skill directories avoids that discovery overhead and irrelevant activation. Do not globally install the entire library or link it wholesale into a project.

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
  --skill eco-mode skill-authoring \
  --agent pi codex claude-code zed universal \
  --yes
```

Setup derives the explicit skill names from immediate packages in `agents/skills/`; it does not use a wildcard or pass the whole module as the source. Adding packages to `library/` does not change global installation.

The CLI installs canonical copies under `~/.agents/skills/` and links them into the global directories for Pi, Codex, Claude Code, Zed, and universal agents. Re-running setup refreshes only global skills. The module records installed names under `$XDG_STATE_HOME/dotfiles/agents-skills` (or `~/.local/state/dotfiles/agents-skills`). Previously recorded skills that are no longer in `skills/`, including those moved into `library/`, are removed from global installation on the next enable. Unrecorded CLI installs are not inferred or removed by name.

Setup links `agents/AGENTS.md` to each supported global instruction location:

- Universal: `~/.agents/AGENTS.md`
- Pi: `~/.pi/agent/AGENTS.md`
- Claude Code: `~/.claude/CLAUDE.md`
- Zed: `~/.config/zed/AGENTS.md`
- OpenCode: `~/.config/opencode/AGENTS.md`

If a destination already exists, the shared setup helper backs it up before creating the managed link.

Node.js and `npx` are required. Unrelated skill names remain untouched; an existing skill with the same name is managed by the `skills` CLI.

## Adopt skills in a project

Ask the agent to select and copy packages explicitly. For example, replace the source path below with your dotfiles checkout:

```text
Take only the skills needed for this project from /path/to/dotfiles/agents/library.
Read /path/to/dotfiles/agents/README.md for the selection workflow, inspect this
project, and copy the selected complete packages into its project-local skills
directory. Explain each selection briefly. Do not install anything globally.
```

Selection workflow:

1. Inspect the project's instructions, stack, tooling, existing skills, and requested work before selecting anything.
2. List library package names and inspect their frontmatter descriptions first. Read full bodies and supporting files only for plausible candidates; do not load every skill into context.
3. Select the smallest useful set based on concrete project needs. Broadly applicable does not mean required: do not copy style, testing, review, or commit policies merely because this is a code repository. Selecting none is valid.
4. Read selected packages in full. Check referenced skills and host-specific requirements; include another package only when the selected workflow actually needs it. Project instructions and existing conventions take precedence over library defaults.
5. Use the project's established, host-supported skills directory. Examples include `.agents/skills/`, `.claude/skills/`, and `.pi/skills/`; verify support for the target host rather than creating every variant. Inspect existing same-name skills and preserve local customizations; ask before overwriting conflicting content.
6. Copy each complete selected directory, including assets, references, scripts, and host metadata. Use real copies, not symlinks back to dotfiles. Adapt project-specific guidance only where needed; do not copy the library inventory into project instructions.
7. Check that copied resources resolve and the target agent discovers the selected skills. Report destination paths, a short reason for each selection, adaptations, and any unverified host behavior.

Project copies are owned by the project and may be versioned with it. Library edits and global setup do not update those copies. Refresh them explicitly, comparing changes with local adaptations before replacing anything. Remove project skills when they no longer serve the project.

## Remove global configuration

```bash
bash agents/setup.sh disable
```

The module removes only managed global instruction links and asks the `skills` CLI to remove only the skill names recorded during installation. It also cleans up legacy direct skill symlinks from older versions of this setup. Files in dotfiles, project-local copies, backups, unrelated instructions, and unrelated installed skills remain untouched.
