---
name: codereview
description: Reviews code diffs, pull requests, commits, and pending changes for concrete defects and regressions with evidence. ALWAYS invoke this skill when the user asks for code review, PR review, diff review, patch audit, pre-merge review, or assessment of whether a change meets its specification. Do not review changed code directly—use this skill first. Do not invoke for architecture feedback without a change, diagnosing a known failure without a review request, or reviewing test design alone.
---

# Code Review

Understand change → trace impact → find concrete risks → verify evidence → rank findings.

## Workflow

1. Establish review scope and intended behavior from the request, specification, change description, and tests.
2. Read the complete diff. Inspect enough surrounding code to understand every changed path; do not review changed lines in isolation.
3. Trace relevant callers, callees, data flows, state transitions, contracts, error paths, and tests. Use symbol-aware references when available.
4. Check whether the change satisfies its intent. Prioritize correctness, security, data loss, performance, compatibility, concurrency, and error handling.
5. Verify each candidate finding against reachable behavior and concrete evidence. Use focused execution when practical; discard speculative concerns.
6. Check for missing tests only when changed behavior creates meaningful regression risk.
7. Report actionable findings in descending severity. If none remain, say no actionable findings.

## Finding standard

Report a finding only when all are true:

- The reviewed change causes, exposes, or materially worsens the problem.
- A concrete input, state, sequence, or caller can trigger it.
- Impact is meaningful and attributable to the change.
- Evidence identifies the violated behavior or contract.
- A practical correction exists.

Do not report style preferences, hypothetical hardening, unrelated cleanup, or pre-existing defects. Do not manufacture findings to fill a review.

## Output

For each finding, provide:

- Severity and concise defect title.
- Exact file and smallest useful line range.
- Trigger and impact.
- Evidence from the diff and traced code or contract.
- Concrete fix direction.

Rank by impact, not ease of repair. Keep findings self-contained; omit summaries and praise unless requested.