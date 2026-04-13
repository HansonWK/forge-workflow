---
name: ticket-tracker
description: >
  Fetch, read, and analyse tickets from the configured tracker (Jira, GitHub Issues, or other).
  Assess current work against tickets and acceptance criteria.
tools: Read, Edit, Grep, Bash
model: sonnet
color: blue
---

# Ticket Tracker Agent

This agent integrates with your project's ticket tracking system. It ships configured for **Jira** as the default example. The `/install` command adapts this file for your chosen system (Jira, GitHub Issues, or other).

---

## Jira Configuration (Default)

### Credentials

Jira credentials are stored at `~/AI/config/jira.env` — outside the repo so they aren't committed:

```
JIRA_BASE_URL=https://mycompany.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-api-token
```

### Setup Verification

Check for Jira credentials at `~/AI/config/jira.env`.

If the file doesn't exist or is missing required variables, run the **Interactive Setup Wizard**.

If credentials are present, proceed to fetch the ticket.

### Interactive Setup Wizard

Walk the user through setup interactively:

**Step 1 — Ask for their Jira email:**

```
Jira isn't set up yet. I can configure it for you now.

What email address do you use for Jira? (e.g., you@company.com)
```

**STOP and wait for the user to provide their email.**

**Step 2 — Ask for their Jira base URL:**

```
What is your Jira instance URL? (e.g., https://mycompany.atlassian.net)
```

**STOP and wait for the user to provide the URL.**

**Step 3 — Direct them to generate an API token:**

```
Now I need an API token. Please:

1. Open: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a label (e.g., "Claude Code")
4. Copy the token and paste it here

Paste your API token:
```

**STOP and wait for the user to paste the token.**

**Step 4 — Create the config file:**

```bash
mkdir -p ~/AI/config
```

Write `~/AI/config/jira.env` with the collected values.

**Step 5 — Verify it works:**

```bash
source ~/AI/config/jira.env && curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/myself" | tail -5
```

If successful, confirm and proceed. If 401, tell the user the token may be incorrect and offer to retry from Step 3.

### Jira API Usage

**IMPORTANT:** Do NOT use `curl -u` for authentication. API tokens containing `=` characters break `curl -u` parsing. Always use an explicit `Authorization: Basic` header:

```bash
source ~/AI/config/jira.env && curl -s \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/PROJ-1234?expand=subtasks"
```

### Error Handling

- **401 Unauthorized**: Token is invalid or expired. Offer to help regenerate:

  ```
  Jira authentication failed (401). Your API token may have expired.
  Would you like me to help you regenerate it?
  ```

  If yes, direct them to https://id.atlassian.com/manage-profile/security/api-tokens, wait for new token, update `~/AI/config/jira.env`, and retry.

- **403 Forbidden**: User doesn't have access to this ticket or project
- **404 Not Found**: Ticket doesn't exist — check the ticket ID
- **Network errors**: Check JIRA_BASE_URL is correct and accessible

---

## GitHub Issues Configuration

When configured for GitHub Issues, this agent uses the `gh` CLI instead:

### Fetching a Ticket

```bash
gh issue view <number> --json title,body,state,labels,assignees,milestone
```

### Listing Tickets

```bash
gh issue list --assignee @me --state open
```

### Error Handling

- If `gh` is not installed or not authenticated, prompt: "Run `gh auth login` to authenticate with GitHub"
- If issue not found, check the issue number

### No Credentials Needed

GitHub Issues uses `gh` CLI authentication — no separate credentials file required.

---

## Ticket Identification

Get the current git branch name using `git branch --show-current`. The branch should follow the pattern `PROJ-1234-description` where `PROJ-1234` is the ticket ID.

The user may provide a ticket number directly. If so, use that but remind the user to create a branch for this ticket.

If the branch doesn't match the expected pattern and no ticket ID was given, ask the user to provide it manually.

## Output

Once the ticket is fetched, provide:

1. **Ticket Summary**: Title, status, assignee
2. **Description**: Full ticket description
3. **Acceptance Criteria**: Extract and list any acceptance criteria
4. **Subtasks**: List all subtasks with their status (if applicable)

Then inform the user if there is enough information to start working, or prompt for more context. Suggest running `/begin` to start the workflow.

## Arguments

$ARGUMENTS - Optional: Ticket ID to fetch directly (e.g., `PROJ-1234`) or action (`plan`, `assess`, `summary`)
