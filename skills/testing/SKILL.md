---
name: testing
description: Design, write, review, and diagnose automated tests that prove observable behavior using project conventions and focused execution. Use for test changes, regression coverage, test-level or mocking decisions, and harness reliability; combine with debugging for non-obvious product failures surfaced by tests. Do not invoke merely to run an existing command.
---

# Testing

Create the smallest reliable test that proves the requested observable contract.

## Design

1. Inspect nearby tests, configuration, helpers, and repository instructions. Follow the project's framework, naming, layout, assertions, and setup conventions.
2. State the behavioral claim and the plausible reason the test should fail. For a reported bug, reproduce the contract violation when practical.
3. Choose the lowest test level that proves the claim. Prefer real in-process collaborators. Fake or mock external, slow, expensive, or nondeterministic boundaries, and avoid mocking away the mechanism under test.
4. Assert supported-interface outputs, state transitions, persisted effects, or meaningful boundary interactions. Avoid private methods, incidental structure, and internal call order.
5. Keep each test focused on one behavioral claim or reason to fail. Cover meaningful success, boundary, and error cases; do not chase arbitrary coverage targets.

Keep tests deterministic, isolated, order-independent, and easy to understand. Control time, randomness, networks, processes, and external services at their boundaries. Never use sleeps or retries to conceal nondeterminism.

Reuse existing helpers before adding abstractions. Keep behavior-relevant fixture values explicit, avoid duplicating production logic in assertions, and clean up acquired resources reliably. Verify expected errors precisely. Investigate unexpected warnings, logs, unhandled rejections, and errors instead of automatically ignoring or suppressing them.

Avoid broad snapshots, excessive mocks, and production-only hooks added solely for tests.

## Execute

- Prefer repository-defined commands. If none exists, derive the narrowest command from configuration, state that inference, and never invent a package script.
- Run the smallest affected test target first, then expand only when shared code, configuration, or observed failures justify it.
- Follow active eco-mode guidance: keep execution focused and defer expensive checks unless necessary for reliable completion.
- If a valid test exposes an out-of-scope product defect, report it instead of silently expanding the task.
- Report tests changed, behavior covered, commands run, results, and any checks not run.
