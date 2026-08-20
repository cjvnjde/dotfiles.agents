---
name: refactoring
description: Guides behavior-preserving refactors through narrow, incremental simplification with explicit safety checks. ALWAYS invoke this skill when the user asks to refactor, clean up, simplify, restructure, deduplicate, remove dead code, reduce nesting, extract or inline code, or improve maintainability without intentional behavior changes. Do not refactor directly—use this skill first. Do not invoke for feature work, bug fixes, formatting-only changes, or code review without requested edits.
---

# Refactoring

Understand → establish safety → simplify one thing → verify behavior → repeat.

## Workflow

1. Define behavior that must remain unchanged: outputs, errors, side effects, ordering, state transitions, and public contracts.
2. Read the relevant code, tests, specifications, and project conventions. Trace callers, callees, and references before changing shared or exported symbols.
3. Establish a safety net. Prefer focused existing tests; add the lowest-level characterization test when current behavior is important but unclear.
4. Choose one narrow simplification. Prefer existing helpers and patterns before introducing an abstraction.
5. Make the smallest coherent change. Keep feature work, bug fixes, and unrelated cleanup outside the refactor.
6. Run repository-defined focused checks after each step. Exercise relevant edge cases and compare errors, effects, and ordering for behavior drift.
7. Repeat only while each change is independently verifiable and clearly simpler. If the result is not clearer, do not keep it.

## Simplification rules

- Prefer explicit, simple control flow over cleverness or fewer lines.
- Reduce unnecessary nesting, duplication, dead code, and indirection only when readability genuinely improves.
- Remove code only after proving it unreachable, unused, or redundant across relevant configurations and callers.
- Introduce an abstraction only for demonstrated duplication or a stable existing concept; never for speculative reuse.
- Keep scope narrow. Do not refactor neighboring code merely because it is imperfect.
- Preserve public names, signatures, data formats, error behavior, side-effect timing, and operation order unless the user explicitly changes the contract.
- When a defect appears, report or fix it separately; do not hide a behavior change inside refactoring.
- Keep safety tests focused on observable behavior, not the old implementation structure.

## Output

Report the preserved contract, simplifications made, safety checks run, results, and any behavior uncertainty. Do not claim equivalence beyond what was inspected or exercised.