---
description: Add or manage a secret / environment variable in your secrets manager
argument-hint: [name] [value] [environment] [service]
---

# Secret Manager

Add (or update) a secret / environment variable in the project's configured secrets manager, safely and with an explicit preview before anything is written.

> **Provider:** see the `## Secrets` section of `docs/workflow-config.md`. A
> fully-worked reference implementation for **Keeper** lives at
> `.claude/examples/secrets/keeper.md` — mirror its shape (gather → normalise →
> authenticate → resolve target → preview → approve → execute), adapting the CLI/API,
> auth flow, and path model to this project's provider (1Password `op`, HashiCorp
> Vault, Doppler, AWS/GCP Secrets Manager, or a plain `.env` file). `/install`
> (secrets module) tailors this command.

## Security — production secrets (read this first)

There is a hard asymmetry between **writing** and **reading** secrets:

- **Adding / updating** a secret is allowed for **any** environment, including
  production — that is the purpose of this command. The value is supplied by the
  user; you are not reading an existing production value to do it.
- **Fetching / reading** a secret **value** is allowed **only for development or
  test** environments. **Never fetch, print, log, or use a production secret value.**

When a task needs credentials to connect to a service directly (a database, API,
queue, search index, …), pull them **only from a dev or test source**. If a step
appears to require a production secret value, **STOP and ask the user to supply it or
perform that step themselves** — do not read it yourself.

## Arguments (all optional)

$ARGUMENTS[0] — Variable name · [1] — Value · [2] — Environment · [3] — Service/scope

If all are supplied, skip the prompts in Step 1.

## Step 1: Gather

Prompt for anything not supplied: variable name, value, target environment (the project's environments — e.g. development / acceptance / production), and the service/scope (the allowed list is in `docs/workflow-config.md`).

## Step 2: Normalise the name

Apply the project's naming convention (e.g. UPPER_SNAKE_CASE, an environment prefix). Trim stray whitespace/underscores. Double-check before use.

## Step 3: Authenticate

Ensure the user is authenticated with the provider (run its login flow if needed; for browser/SSO logins, open the page and let the user paste the token back). If auth is stuck, ask the user to complete login in a separate terminal and wait.

## Step 4: Resolve the target

Resolve where the secret goes (folder/path/vault/scope) using the provider's list/lookup commands, matched to the chosen environment and service.

## Step 5: Preview and get approval

Show an overview: the (transformed) name, a **redacted** value preview, the environment, the scope, the resolved target path, and the exact command that will run. **Wait for explicit approval.**

## Step 6: Execute

Run the provider command and report success/failure.

## Rules

- **Never fetch/read a production secret value.** Reading secret values is dev/test only; adding secrets is allowed for any environment (see Security above).
- **Never write a secret without showing a preview and getting explicit approval** — that is the entire point of this command
- Never echo the full secret value in plaintext beyond a short redacted preview
- Never commit secret values into the repo
