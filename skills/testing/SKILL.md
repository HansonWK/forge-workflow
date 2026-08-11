---
name: testing
description: How to write and verify tests in this project — black-box, behaviour-focused testing plus the predict-then-verify workflow for changing existing code. Use when writing tests or changing code that has tests.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Testing (method)

Follow the project's testing guidelines in `docs/testing.md` if it exists (method, coverage
philosophy, test levels, mocking, libraries, where UI components live). The defaults below apply when
it doesn't.

## Philosophy — test behaviour, not implementation

- A "unit" is a **meaningful behaviour**, not a function/class. Assert on **inputs → outputs /
  observable behaviour**, not internal state or call order.
- Do **not** assert on implementation details (spying on internal calls, logger invocations,
  private methods). If a refactor that preserves behaviour breaks the test, the test is wrong.
- Tests are documentation — name them for the behaviour, and make the assertions match the name
  ("should do X and Y" → assert both X and Y).
- Reuse the project's test factories/utilities; keep fresh setup per test (reset mocks/state).

## Predict-then-verify (mandatory when changing code that has tests)

Before writing code that modifies files with existing tests:

1. **Read the existing tests** for every file you'll change.
2. **Write down predictions** — which specific tests you expect to break, and why; which you expect
   to stay green, and why.
3. Implement.
4. **Run the tests and compare to your predictions:**
   - Predicted-break that **didn't** → your model of the code may be wrong; investigate before
     proceeding.
   - **Unpredicted** break → likely a real side effect / bug; investigate and fix the code, don't
     just update the test.
   - Only update a test to match new behaviour after confirming the new behaviour is correct.

Skip only when purely creating new files with no existing tests.

## Coverage bar

- **Test business logic and boundaries; don't chase 100% line coverage of mid-function
  implementation** — that's usually wasted effort (unless `docs/testing.md` says otherwise).
- Every new exported function or significant path gets tests: happy path, error cases, edge cases
  (null/undefined/empty). If a sibling has tests and the new code doesn't, that's a gap.

## What NOT to test

Framework internals, third-party libraries, trivial pass-throughs, pure type transformations,
and logging calls (logs are observability, not behaviour).
