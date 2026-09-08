---
name: debugging
description: Diagnose non-obvious, recurring, flaky, concurrent, and performance failures through evidence and focused experiments. Use for unclear product failures, including those surfaced by tests; combine with testing for test design or harness reliability. Do not invoke for obvious mechanical corrections, new features, or behavior-preserving refactors.
---

# Debugging

Find the causal mechanism before making a fix.

## Investigate

- Treat reported behavior, supplied output, logs, and artifacts as starting evidence. Verify interpretations against relevant contracts when necessary.
- Capture expected and actual behavior, inputs, environment, and the exact failure. Reproduce the real failing surface when practical, and preserve the original reproduction for final verification.
- If reproduction is unavailable, state that limitation and investigate the supplied evidence and environment differences. Do not substitute a speculative fix.
- Minimize the reproduction enough to isolate the mechanism without replacing it with a different failure.
- Read complete errors and cause chains. Trace the executed path and relevant state. Separate observations from assumptions.
- For uncertain causes, form one falsifiable hypothesis at a time: state the proposed mechanism, supporting evidence, predicted observation, falsifier, and smallest useful experiment.
- Change one variable per experiment. Prefer focused inspection, profiling, bisection, or targeted instrumentation over broad edits. Remove or revert experimental changes before proceeding.
- Distinguish the trigger, visible symptom, causal mechanism, and violated invariant. Explain why the cause produces the failure.

After several rejected hypotheses or failed fixes, stop patching. Reassess confirmed facts, environment, state, dependencies, concurrency, and architectural boundaries before forming another hypothesis. Never stack changes whose effects are not understood.

## Fix and verify

- Make the narrowest coherent change that restores the violated invariant. Avoid unrelated refactoring, formatting, dependencies, and cleanup.
- Do not hide symptoms with guards, retries, delays, fallbacks, or suppression unless evidence shows that behavior is the intended response.
- Add a useful regression test using the `testing` guidance when an appropriate seam exists. Otherwise explain why no useful regression test exists and verify through the original reproduction.
- Re-run the original reproduction and the smallest affected checks. For performance or intermittent failures, compare repeatable measurements or failure rates against the baseline.
- Remove temporary logs, flags, breakpoints, scripts, fixtures, and instrumentation. Reverify if cleanup changes executable code.
- Report only observed evidence and results. Mark unresolved uncertainty explicitly.
