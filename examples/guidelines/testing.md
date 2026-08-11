# Testing Guidelines

> Fill this in — or run `/clarify testing` to be quizzed and have it generated. The `testing` and
> `code-review` skills read this. Keep it **decision-focused**.

## Method

<!-- How do you drive development? Options:
     - Full TDD (red → green → refactor).
     - Predict-then-verify (a pragmatic TDD variant): read the existing tests, predict which will break
       and why, write the code, run the tests, compare against your predictions, fix, then add new tests.
     - Test-after. -->
- **Method:** <e.g. predict-then-verify>

## What we test (coverage philosophy)

<!-- Pick your stance:
     - Business logic + boundaries: test behaviour at boundaries and the business rules; do NOT chase
       100% line coverage of mid-function implementation — it's usually wasted effort.
     - 100% line coverage.
     - Domain logic / pure functions only. -->
- <e.g. Business logic and boundaries; not 100% mid-function line coverage>

## Test levels

<!-- What is unit- vs component- vs e2e-tested? For example:
     - Unit: pure logic and use-cases with mocked ports.
     - Component: a slice wired together (real internal adapters, mocked externals).
     - E2E: critical user journeys only. -->
- Unit: <...>
- Component: <...>
- E2E: <...>

## Mocking

<!-- Options:
     - Only mock what's needed — mock at boundaries/ports, not internals.
     - Shared mocks + test-data factories across tests, so everyone tests the same shapes.
     - Mock nothing below the port. -->
- <e.g. Shared factories for test data; mock only external ports>

## Libraries & tools

<!-- Test runner, assertions, mocking, e2e. e.g. Vitest + Testing Library + Playwright. -->
- <...>

## UI components

<!-- Where are components developed/tested? Storybook, in-app, or both? -->
- <e.g. Storybook for components; in-app for pages>
