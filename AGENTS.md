# Dependency Versions

- Use latest available stable versions of packages, tools, and actions unless instructed otherwise.
- Prefer installers and version selectors that automatically resolve latest version. Do not separately verify versions in this case.
- Before adding or changing any version selector that does not automatically resolve latest—including GitHub Actions `uses` refs—verify against authoritative source that it is latest stable release.
- Never introduce a specific or pinned version selector without this verification.

# Attribution

- Never add attribution, authorship, provenance, or generated-by notices to text, code, comments, or documentation.

# Code Conventions

- Follow repository-specific instructions, configured tools, and established local conventions before global defaults.
- Follow the configured formatter and linter. Format affected files when appropriate, but do not add or reconfigure tooling or reformat unrelated code unless requested.
- Do not hand-edit generated, vendored, or minified files unless explicitly required. Update snapshots and lockfiles through project tooling when relevant.

# Safe Changes

- Keep changes narrow and coherent.
- For behavior-preserving refactors, preserve public contracts, errors, side effects, timing, and ordering.
- Trace references before renaming, moving, or changing exported symbols.
- Do not mix refactoring with feature or bug changes unless necessary; isolate the concerns when practical.
- Remove obsolete code only after proving it unused across relevant callers and configurations.
- Do not silently swallow failures. Catch only to recover, translate at a boundary, add useful context, or guarantee cleanup.
- Make ownership and caller-controlled cleanup explicit for listeners and acquired resources.
- For bug fixes, start from available evidence, identify the causal mechanism, and avoid masking symptoms with guards, retries, delays, or fallbacks unless that behavior belongs to the intended contract.
