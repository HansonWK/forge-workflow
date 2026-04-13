---
description: Run dev phase for current subtask
---

# Dev Phase

## Prerequisites

Requires active plan with a subtask ready for dev:

- Plan exists with Status: `IN_PROGRESS`
- Current subtask has `- [ ] Dev` unchecked

## Instructions

Implement the current subtask. Use native `TaskCreate` to create tasks for the dev steps below, marking each `in_progress` when you start it and `completed` when done. This gives the user real-time visibility into progress. Create all tasks upfront (skipping any that don't apply to this subtask) with dependencies so they execute in order.

### 1. Understand the subtask

Read the plan.md to understand:

- Subtask goal
- Files to create/modify/delete
- Context from previous subtask

### 2. Predict test impact (MANDATORY for existing code)

If you are modifying files that have existing tests, you **must** complete this step before writing any code:

1. **Read the existing test files** for every file you plan to modify
2. **Write down your predictions** — list which specific tests you expect to break and why
3. **State any tests you expect to remain unaffected** and why

Record these predictions in a brief list (test name → expected outcome). You will compare against actual results in the Verify step. This is how we catch unintended side effects early.

Skip this step only if the subtask is purely creating new files with no existing tests.

### 3. Implement

Write the implementation code following:

- Patterns identified in research.md
- Existing codebase conventions
- claude.md standards

### 4. Write Tests

Use `test-writer` agent for tests if applicable:

- Unit tests for new functions
- Integration tests for new endpoints
- Follow black-box, behavior-focused testing
- Test all core functionality and business logic

### 5. Documentation

Use `doc-writer` agent if needed:

- Update README if public API changes
- Add JSDoc for complex functions
- Update ADRs if architectural decisions made

### 6. Logging Check

Consider skipping this step if your changes only modify existing code without adding new handlers, consumers, business logic decisions, or error paths.

When this step applies, **run it as a background agent** so the developer is not blocked:

```
Agent({
  description: "Logging compliance check",
  subagent_type: "Explore",
  run_in_background: true,
  prompt: "Read docs/logging-strategy.md then audit the changed files for logging compliance. Check: new handlers have boundary logs at INFO, all logs include productId/entityType/brand/pipeline where applicable, business logic decisions log with a reason, logger names follow {service-name}:{module-name}. Report only issues found — say nothing if everything is compliant. Also note if the new logs could power useful dashboards (counts, summaries, structured reasons) and suggest the user runs /dashboard."
})
```

The agent will notify when complete. Only surface issues to the developer if found — don't block dev work for logging.

### 7. Verify and compare predictions

```bash
# Run tests
npm run test

# Run lint/type-check
npm run lint
npm run format:check
```

**Compare test results against your predictions from step 2:**

- A test you predicted would break but **didn't** → your understanding of the code may be wrong, or the test doesn't cover what you think. Investigate before proceeding.
- A test you **didn't predict** would break but **did** → you've introduced a side effect. This is likely a bug. Investigate and fix before updating the test.
- Only update tests to match new logic after confirming the new behaviour is correct.

Fix any failures before completing.

### 7b. Live Service Verification (optional)

If the current subtask changes data mapping, filtering, or transformation in a service and data flows through Service Bus, consider live verification:

1. Ask the user if they want to run a live service test
2. Dispatch the `live-tester` agent with the scenario details
3. The agent will: launch the service, construct test data (all IDs suffixed `-local-test`), show it for approval, send it to the SB emulator, watch the logs, report results, and provide downstream verification links (Algolia/Builder.io)
4. Include the results in the present phase

Skip if:

- Unit tests fully cover the scenario
- The change has no runtime data flow through Service Bus
- The fix is obvious and low-risk
- Changes are frontend-only or purely to types/constants

### 8. Update Plan and Status

Check `- [x] Dev` in plan.md for this subtask.

Also update `status.md` in the same task directory: set `work_status` to `in-progress` (if not already).

**NEVER commit automatically.** Prompt the user to validate the work and suggest a commit message. Wait for user to commit.

## After Dev

```
Dev complete for Subtask <N>: <title>

Files changed:
- <file list>

Tests: <passing/failing>
Lint: <clean/issues>

Suggested commit message: <concise description>

Please review and commit when ready, then run /next to continue.
```

## Rules

- Stay within scope of the current subtask
- Don't implement future subtasks
- Tests and lint must pass before completing
- Use test-writer agent for tests, not manual test writing
- Update plan.md checkbox when complete
- NEVER commit on behalf of the user - only suggest commit messages
- If work on this subtask might affect future work in the plan, update the user and ask for permission to change the plan
