---
name: testing
description: Plans, writes, reviews, and diagnoses automated tests that prove observable behavior using project conventions and focused execution. ALWAYS invoke this skill when the user asks to add, change, fix, review, or design tests; add a regression test; choose a test level or mocking boundary; or improve test reliability. Do not author or review tests directly—use this skill first. Do not invoke merely to run an existing test command without test-related changes or analysis.
---

# Testing

Create the smallest reliable test that proves the requested behavior.

## Workflow

1. Inspect nearby tests, test configuration, and existing helpers. Follow the project's framework, naming, layout, assertions, and setup conventions.
2. Identify the observable contract and plausible failure being defended. For bugs, reproduce the reported failure with a regression test when practical.
3. Choose the lowest test level that proves the contract. Prefer real collaborators; mock only external, expensive, or nondeterministic boundaries.
4. Write one behavior per test. Cover meaningful success, boundary, and error cases without chasing arbitrary coverage.
5. Run the smallest affected test set first using repository-defined commands. Never guess commands; expand checks only when shared code, configuration, or failures justify it.
6. Report tests changed, behavior covered, commands run, and results.

## Test design

- Assert outputs, state transitions, persisted effects, or boundary interactions visible through the supported interface. Never assert private methods, internal call order, or incidental structure.
- Keep tests deterministic, isolated, independent, and simple. Control time, randomness, network, processes, and external services at their boundaries.
- Reuse project helpers before adding new ones. Use factories or builders only when test data is complex; keep relevant values explicit in each test.
- Avoid duplicating production logic in assertions or fixtures.
- Treat unexpected warnings, logs, unhandled rejections, and errors as failures, not noise.
- Verify expected errors precisely enough to distinguish the intended failure from unrelated failures.
- Keep fixtures minimal and cleanup reliable. Tests must pass alone and in any suite order.

Do not add broad snapshots, excessive mocks, sleeps, retries, or production-only hooks to make tests pass. Fix source behavior when the test exposes a product defect.