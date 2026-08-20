# Personal Agent Configuration

Store user-level agent instructions and skills here and manage them with dotfiles.

## Layout

```text
agents/
├── AGENTS.md
├── setup.sh
└── skills/
    └── my-skill/
        ├── SKILL.md
        └── ...
```

Each immediate directory under `skills/` must contain `SKILL.md`. Supporting files stay inside that skill directory.

`AGENTS.md` contains shared global instructions.

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

Setup links this file to each supported global instruction location:

- Universal: `~/.agents/AGENTS.md`
- Pi: `~/.pi/agent/AGENTS.md`
- Claude Code: `~/.claude/CLAUDE.md`
- Zed: `~/.config/zed/AGENTS.md`
- OpenCode: `~/.config/opencode/AGENTS.md`

If a destination already exists, the shared setup helper backs it up before creating the managed link.

Node.js and `npx` are required. Unrelated skill names remain untouched; an existing skill with the same name is managed by the `skills` CLI.

## Remove

```bash
bash agents/setup.sh disable
```

The module removes only managed global instruction links and asks the `skills` CLI to remove only the skill names recorded during installation. It also cleans up legacy direct skill symlinks from older versions of this setup. Files in dotfiles, backups, unrelated instructions, and unrelated installed skills remain untouched.
