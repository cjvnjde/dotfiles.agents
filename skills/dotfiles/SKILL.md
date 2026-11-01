---
name: dotfiles
description: Set up and refresh project-local agent skills from the user's dotfiles library. ALWAYS use this skill when asked to set up skills for a project, choose or install project skills, take skills from dotfiles, or refresh skills previously adopted from that library. Inspect the dotfiles library before selecting skills and install with npx skills, not manual copying. Do not activate merely to use an already installed skill, install unrelated third-party skills, change other dotfiles configuration, or answer a question without an action request.
---

# Dotfiles

## Scope

Use the user's dotfiles as the source for project skill adoption. Packages under `agents/library/` are project-level skills: never install them globally. This workflow does not enable dotfiles modules, install the whole library, or update the dotfiles checkout unless separately requested.

## Locate the source and target

1. Identify the target project from the request and working directory. Inspect its instructions, stack, tooling, existing skill directories, and requested work before selecting skills.
2. Locate the actual dotfiles checkout from the user's instructions or known configuration. A managed global instruction symlink such as `~/.agents/AGENTS.md` can identify `dotfiles/agents/AGENTS.md`; resolve its target rather than assuming the installed skill itself lives in the checkout. If no location is known, check `~/dotfiles/agents/`. Verify the candidate contains `README.md` and `library/`; ask for the location only if it cannot be established. Do not clone another checkout or scan the entire home directory.
3. Read that module's `README.md` for the current adoption workflow. Set `AGENTS_SOURCE` to its verified absolute directory, and `PROJECT_ROOT` to the target project's absolute root. These are command variables, not persistent configuration.
4. Confirm Node.js and `npx` are available. If missing, report the prerequisite; do not install a runtime without permission. The commands below download and execute the latest `skills` CLI and write selected packages into the project.

## Select the smallest useful set

1. List immediate packages in `"$AGENTS_SOURCE/library"` and read their `SKILL.md` frontmatter descriptions first. Do not read every full skill into context.
2. Select explicitly requested skills and any additional skills justified by concrete project needs. A request to "set up skills" is not permission to install the entire library. Selecting none is valid; explain why instead of adding generic policies by default.
3. Read selected packages in full, including referenced resources needed for their workflow. Check dependencies, host compatibility, and conflicts with project instructions. Add a related package only when the selected workflow actually needs it.
4. Determine the target agent from the request and established project configuration. Use a supported `skills` CLI agent identifier; do not infer it from the model name. Consult `npx --yes skills@latest add --help` or the CLI's current agent documentation when uncertain. Ask only if the host cannot be determined or multiple choices materially differ. Never target every agent by default.
5. Inspect existing same-name skills before installing or refreshing. Preserve project adaptations and ask before overwriting conflicting content. Do not delete unrelated skills or silently migrate an existing skill layout.

## Install into the project

Run the CLI from `PROJECT_ROOT`, using the verified local library as the source and explicit selected names and agent identifiers. For example, after selecting `debugging` and `testing` for Codex:

```bash
cd "$PROJECT_ROOT"
npx --yes skills@latest add "$AGENTS_SOURCE/library" \
  --skill debugging testing \
  --agent codex \
  --copy \
  --yes
```

Replace the example names and agent with the actual selection. Use only identifiers accepted by the current CLI. Omit `--global`, `--all`, and wildcard selectors. `--copy` requests project-owned files rather than agent-directory symlinks; do not create links back to dotfiles or manually copy packages as a substitute for the CLI.

Let the CLI use the selected host's supported project-local directory. Respect the project's existing supported layout. If the CLI cannot install into that layout, explain the incompatibility and resolve it before writing to a second discovery directory. Do not edit global instructions or install the `dotfiles` routing skill into the project as part of library adoption.

## Refresh explicitly

For skills installed from the local library, compare the current library packages with installed copies and account for project adaptations, then rerun the same project-local `add` command for the selected names. Do not rely on remote update tracking for local-path sources. Do not fetch, pull, or switch branches merely to refresh project copies. If the user separately requests updating the dotfiles checkout, follow its repository update instructions first.

Library edits and global setup do not automatically refresh project copies. Do not promise automatic synchronization or replace a locally adapted package without resolving the conflict.

## Verify and report

- Check the CLI's per-skill installation result and actual destination paths. Confirm complete packages and referenced resources exist inside the project, with no links back to the checkout.
- Run `npx --yes skills@latest list` from the project and confirm the selected skills are listed for the intended agent. For agent-specific visibility, use `--agent` with the same identifier if supported by the current CLI.
- Inspect any generated lockfile and report it along with installed paths. Do not stage or commit files unless requested.
- Verify discovery in the target host when available; otherwise distinguish successful CLI listing from unverified live-host activation. Mention when a new session or skill reload is needed.
- Report each selected skill and its project-specific reason, destination paths, adaptations, verification results, and any blocker. If none were selected or an existing conflict prevented installation, state that no installation occurred.
