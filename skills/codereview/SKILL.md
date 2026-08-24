---
name: codereview
description: Reviews diffs, pull requests, commits, and pending changes for evidence-backed defects when the user explicitly requests a review, audit, or pre-merge assessment. Do not invoke for architecture feedback without a change, debugging a known failure, implementation or commit requests without review intent, or standalone test design.
---

# Code Review

## Routing

- Require explicit review intent. Implementation or commit requests alone do not imply review.
- Use `testing` for standalone test design; use both skills for a test-focused diff review.

## Workflow

1. Establish scope and intended behavior from the request, specification, change description, and tests.
2. Read the complete diff and enough surrounding code to understand each changed path.
3. Trace relevant callers, callees, data flow, state transitions, contracts, error paths, and tests. Use symbol-aware references when available.
4. Prioritize correctness, security, data loss, performance, compatibility, concurrency, and error handling.
5. Verify each candidate against reachable behavior and concrete evidence. Run focused checks when practical; discard speculation.
6. Flag missing tests only when changed behavior creates meaningful regression risk.
7. Report findings in descending severity.

## Finding standard

Report a finding only when all are true:

- The change causes, exposes, or materially worsens the problem.
- A concrete input, state, sequence, or caller can trigger it.
- Its impact is meaningful and attributable to the change.
- Evidence identifies the violated behavior or contract.
- An actionable next step exists: correction, mitigation, revert, or clarification.

Do not report style preferences, hypothetical hardening, unrelated cleanup, or pre-existing defects. Never manufacture findings.

## Output

For each finding, provide severity, a concise title, the exact file and smallest useful line range when available, trigger and impact, evidence, and a concrete next step.

If none remain, say no actionable findings. If coverage is incomplete, state exactly what was not inspected or verified and why. Keep findings self-contained; omit summaries and praise unless requested.
