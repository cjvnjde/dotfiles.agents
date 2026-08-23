---
name: licence
description: Adds a project MIT licence from bundled canonical text with the current year. ALWAYS invoke this skill when the user asks to add or create an MIT license or licence, or asks generally to add or create a project license or licence and must choose one. Do not create a licence file directly—use this skill first. Do not invoke for legal interpretation, licence audits, dependency reports, or source-file licence headers.
---

# Licence

Create exactly one MIT licence file. Make no unrelated code, documentation, metadata, or header changes.

## Workflow

1. Determine whether the user explicitly requested MIT and whether they specified a destination path.
2. If MIT was explicitly requested, proceed without asking which licence to use.
3. If the user requested a licence without naming one, use the available user-question tool (`ask`, `ask_user`, or `AskUserQuestion`) to present MIT, Apache License 2.0, GNU GPLv3, and BSD 3-Clause. Recommend MIT. Continue only when the user selects MIT; otherwise stop without modifying files because this skill provides only the MIT template.
4. Use the requested destination path, or `LICENSE` at the project root when none was specified. If that path already exists, do not overwrite it unless the user explicitly requested replacement.
5. Read `${CLAUDE_SKILL_DIR}/assets/MIT.txt`. Determine the current four-digit calendar year from the trusted session date or an available date tool, then replace the single `{year}` placeholder with that year. Do not alter any other template text.
6. Write only the destination licence file. Do not add notices, attributions, package metadata, documentation links, licence headers, or generated-by text.
7. Verify that the destination exactly matches the bundled template after substitution, contains `Copyright (c) <current year> Vitalij Nykyforenko`, and contains no `{year}` placeholder.

## Output

Report only the created path, `MIT`, and the inserted year. If blocked by an existing file or a non-MIT selection, report that condition without changing files.
