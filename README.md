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

Installer creates individual symlinks for every skill in both locations:

```text
~/.claude/skills/<skill-name> -> <dotfiles>/agents/skills/<skill-name>
~/.agents/skills/<skill-name> -> <dotfiles>/agents/skills/<skill-name>
```

Existing destination directories and unrelated skills remain untouched. Name conflicts are reported and skipped. Re-running installer adds new skills, keeps current links, and removes stale links previously pointing into this repository.

## Remove links

```bash
bash agents/setup.sh disable
```

Only skill symlinks pointing directly into this repository's `agents/skills/` directory are removed. Skill files in dotfiles and unrelated installed skills remain untouched.
