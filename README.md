# Personal Agent Skills

Store user-level agent skills here and manage them with dotfiles.

## Layout

```text
agents/
├── setup.sh
└── skills/
    └── my-skill/
        ├── SKILL.md
        └── ...
```

Each immediate directory under `skills/` must contain `SKILL.md`. Supporting files stay inside that skill directory.

## Install

Enable `agents` in `.modules`, then run:

```bash
bash setup.sh
```

Or run this module directly:

```bash
bash agents/setup.sh enable
```

The module uses the latest [`skills`](https://github.com/vercel-labs/skills) CLI non-interactively:

```bash
npx --yes skills@latest add ./agents \
  --global \
  --skill '*' \
  --agent pi codex claude-code zed universal \
  --yes
```

The CLI installs canonical copies under `~/.agents/skills/` and links them into the global directories for Pi, Codex, Claude Code, Zed, and universal agents. Re-running setup refreshes every skill from this repository. The module records installed names under `$XDG_STATE_HOME/dotfiles/agents-skills` (or `~/.local/state/dotfiles/agents-skills`) so removed skills can be cleaned up safely.

Node.js and `npx` are required. Unrelated skill names remain untouched; an existing skill with the same name is managed by the `skills` CLI.

## Remove skills

```bash
bash agents/setup.sh disable
```

The module asks the `skills` CLI to remove only the skill names recorded during installation. It also cleans up legacy direct symlinks from older versions of this setup. Skill files in dotfiles and unrelated installed skills remain untouched.
