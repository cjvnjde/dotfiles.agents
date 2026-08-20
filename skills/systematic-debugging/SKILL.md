---
name: systematic-debugging
argument-hint: "[reported bug, failure, or performance regression]"
description: Evidence-driven diagnosis and minimal root-cause fixes for reported software bugs, regressions, crashes, errors, flaky failures, and performance regressions. ALWAYS invoke this skill before investigating or fixing a reported failure, including implicit requests to diagnose why behavior changed. Skill authoring and skill activation failures are outside its domain. Do not edit code, add guards, retries, or fallbacks, or write a speculative fix before using this skill.
---

# Systematic Debugging

## Objective

Use this loop:

```text
reproduce → minimize → understand → hypothesize → test → root cause → minimal fix → regression test → verify → cleanup
```

Treat the reported failure as ground truth. Reproduce it to establish an executable feedback loop, not to challenge the report.

Do not invoke this skill for new features, behavior-preserving refactors, code review without a reported failure, or tests requested without a bug.

## Source-of-truth order

1. User-reported expected and actual behavior.
2. Exact failing input, command, environment, error, stack trace, logs, and captured artifacts.
3. A locally observed reproduction using the same surface.
4. The minimized reproduction.
5. Relevant code path and runtime state.
6. Hypotheses and controlled experiments.

If the user already supplied current output from the same workspace, accept it. Do not rerun solely to confirm their claim; use it as the initial reproduction evidence and build the smallest useful feedback loop from it.

## Workflow

### 1. Reproduce before editing

- Record expected behavior, actual behavior, exact steps or command, input, environment, and failure output.
- Exercise the real failing surface when available: application, API, CLI, worker, device, build, or test.
- Preserve one exact original reproduction for final verification.
- Do not edit production code until the failure is observable or the supplied evidence establishes it reliably.
- If reproduction is unavailable, inspect environment differences and all supplied artifacts. Never substitute a speculative fix.

### 2. Minimize the reproduction

- Remove irrelevant inputs, state, setup, steps, and dependencies while preserving the same failure mechanism.
- Change one dimension at a time so the observation remains attributable.
- Prefer the smallest existing test, command, request, fixture, or interaction that still fails.
- Temporary reproducer code is allowed only when needed for diagnosis and must be removed or converted into a durable regression test.

### 3. Understand the evidence

- Read the complete error, cause chain, stack trace, logs, input, environment, and nearby events. Do not stop at the first symptom.
- Trace the executed code path from the observed failure backward through actual callers and data transformations.
- Inspect runtime state with the debugger, profiler, targeted logs, or focused experiments. Prefer debugger inspection over permanent instrumentation.
- Separate facts from assumptions. Mark anything not observed as a hypothesis.

### 4. Form a falsifiable hypothesis

Use this compact record:

```text
Hypothesis: proposed causal mechanism
Evidence: observations supporting it
Prediction: observation that must occur if correct
Falsifier: observation that would reject it
Experiment: smallest test of one variable
Result: observed output
Decision: accept, reject, or refine
```

A label without a prediction and falsifier is not a useful hypothesis.

### 5. Test one hypothesis at a time

- Run one targeted experiment or alter one variable.
- Keep unrelated code and environment unchanged.
- Prefer breakpoints, state inspection, focused inputs, profiling, or bisection over broad edits.
- Reject contradicted hypotheses explicitly. Do not reinterpret failed experiments as confirmation.
- Revert experimental production changes before testing the next hypothesis.

### 6. Identify root cause

- Distinguish triggering input, visible symptom, causal mechanism, and violated invariant.
- Explain why the failure occurs and why the proposed change restores the invariant.
- Never add a guard, retry, delay, fallback, suppression, or special case merely because it hides the symptom.
- Such behavior is valid only when evidence shows it is the intended invariant-preserving response.

### 7. Make one minimal fix

- Change only code required to correct the proven mechanism.
- Avoid unrelated refactoring, renaming, formatting, dependency changes, or “while here” cleanup.
- Keep the fix coherent and reviewable as one causal change.
- Invoke any language- or technology-specific skill before editing files in its domain.

### 8. Add a regression test when useful

Add a test when an appropriate seam exists and the test:

- reproduces the observable contract failure before the fix;
- passes because the root cause is corrected;
- remains deterministic, isolated, and maintainable;
- would fail for a plausible recurrence.

Do not force a test that checks source text, mocks away the mechanism, duplicates stronger coverage, or cannot represent the real failure. When no useful seam exists, explain why and rely on the original behavioral reproduction.

### 9. Verify the real bug

- Re-run the exact original reproduction after the fix.
- Confirm expected behavior and absence of the reported failure.
- Run the regression test when added and the smallest affected checks.
- A passing new test alone is insufficient.
- Verify nearby invariant-sensitive behavior only when the fix could affect it.

### 10. Clean debugging artifacts

- Remove temporary logs, breakpoints, flags, instrumentation, scripts, fixtures, captures, and experimental changes.
- Keep only the minimal fix and justified regression coverage.
- Re-run the relevant verification if cleanup changed executable code.

## Reassessment stop condition

After multiple failed hypotheses or fix attempts:

1. Stop patching.
2. Revert experimental changes.
3. Restate confirmed facts, rejected hypotheses, and unverified assumptions.
4. Re-read the original evidence and executed code path.
5. Reconsider environment, state, dependency, concurrency, and architectural boundaries.
6. Form a new falsifiable hypothesis before making another change.

Never stack patches whose individual effects are not understood.

## Specialized failures

### Performance

- Measure before optimizing.
- Establish a repeatable baseline using the reported workload and environment.
- Profile or bisect to locate the cost; do not infer hotspots from code appearance.
- Change one variable, repeat the same measurement, and compare against the baseline.
- Report workload, environment, metric, baseline, result, and measurement variability.

### Intermittent or concurrent failures

- Establish a repeat count or failure-rate baseline before changing code.
- Capture ordering, timestamps, state transitions, and seeds where relevant.
- Reduce nondeterminism without replacing the real mechanism with a mock.
- Verify with enough repetitions to distinguish the fix from chance.

## Final output

Report:

```text
Problem: original and minimized reproduction
Root cause: causal mechanism and supporting evidence
Fix: minimal changed behavior and location
Regression: test added, or concrete reason none was useful
Verification: original reproduction result and affected checks
Cleanup: temporary debugging artifacts removed
```

State only observed results. Mark remaining uncertainty explicitly.
