---
Define Ticket and Prompt from Investigation
---

# Create Ticket and Prompt from Investigation

Summarize investigation findings into a prompt for `/begin` and a ticket description.

## Instructions

### 1. Gather Context

Review the conversation to identify:

- **Problem discovered**: What issue was found during investigation/testing?
- **Root cause**: Why does the problem occur?
- **Proposed solution**: What approach was discussed?
- **Affected files**: Which files need changes?
- **Scope**: What needs to be done?

### 2. Write the Begin Prompt

Create a file at `.claude/temp/<topic>/prompt.md` with:

```markdown
# Prompt: <Short title>

## Problem

<1-2 paragraphs explaining the issue, with concrete examples>

## Solution

<Brief description of the approach>

## Scope

<Numbered list of changes needed, with file locations>

## Implementation Notes

<Any technical details, constraints, or considerations>

## Files to Investigate

<List of files to read during research phase>

## Testing

<How to verify the fix works>

## Note: we will need to rename this folder when we have a ticket created with the ticket ID to follow our naming conventions. Please do this now
```

### 3. Write the Ticket

Save a ticket description to ticket.md and present it to the user with:

```markdown
**Title:** <Imperative, concise title>

**Description:**

<1-2 sentences on the problem>

**Root cause:** <Why it happens>

**Example:** <Concrete example if available>

**Solution:** <Brief approach>

**Scope:**
<Numbered list of high-level changes>

**Acceptance Criteria:**

- [ ] <Testable criteria>
- [ ] <Testable criteria>
```

### 4. Present to User

```markdown
## Ticket

<summary of ticket content>

## Files Created

- `.claude/temp/<topic>/ticket.md` - Ticket description
- `.claude/temp/<topic>/prompt.md` - Prompt for `/begin`

---

**To start work later:**
```

/begin @.claude/temp/<topic>/prompt.md

```

```

## Rules

- Keep prompts focused - one problem per prompt
- Include concrete examples where possible
- List specific files, not vague references
- Acceptance criteria must be testable
- Do not start the work - only prepare for future work
