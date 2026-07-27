---
description: Add a new environment variable record to Keeper
argument-hint: [name] [value] [environment] [service]
---

<!--
  REFERENCE EXAMPLE — Keeper Secrets Manager (keeper-commander CLI).

  Fully-worked implementation of the generalized `/secret` command for one provider
  (Keeper, via the `keeper` CLI). The value here is the SHAPE: gather → normalise the
  name → authenticate → resolve the target folder/path → PREVIEW → require explicit
  approval → execute. When adapting during /install for another provider (1Password
  `op`, HashiCorp Vault, Doppler, AWS/GCP Secrets Manager, or a plain .env file),
  keep that shape and the "never write a secret without showing a preview and getting
  approval" rule; swap the CLI commands, the auth flow, and the path/folder model.

  Company-specific details (service list, folder layout) are a fictional example.
-->

# Keeper Environment Variable Record

Execute a `keeper` CLI command to add a new encrypted-note record to the "Environment Variables" folder. This is a strict command. Follow it exactly.

## Security — production secrets

**Adding** a secret is allowed for any environment, including production (the value is
supplied by the user). **Fetching / reading** a secret value is allowed **only for dev
or test** — never fetch, print, or use a production secret value. If a step needs
production credentials to connect to a service, stop and ask the user to do it.

## Arguments

All optional:

$ARGUMENTS[0] — Variable Name
$ARGUMENTS[1] — Value
$ARGUMENTS[2] — Environment
$ARGUMENTS[3] — Service

If all arguments are passed, skip step 1.

## Steps

1. **User Prompts** — Gather information used to build the keeper command:

### Variable Name

"Environment variable name:"

### Value

"Value:"

### Environment

"Target environment:"

Allowed options:

- development
- acceptance
- production

### Service

"Service:"

Allowed options (project-specific — /install fills these in):

- Catalog Service
- Content Service
- Order Service
- Notification Service
- Search Service
- CI Secrets

2. **Format Data** — Using the data provided, format it for the keeper command:

- Variable Name
  - Transform to all uppercase, whitespace swapped for `_`
  - No leading or trailing whitespace
  - No leading or trailing `_`
  - Prefix with `[DEV] `, `[ACC] `, or `[PRD] ` based on the selected environment
  - Double-check before running the keeper command

3. **Keeper CLI Login** —

Ensure the user has authenticated with keeper. You may need to run `keeper login` and follow the steps. Prompt them for their email address for the login.

If prompted for SSO login, select option `o` to open the login in a browser. Open the browser on the SSO page for the user to copy their token. Allow the user to paste the auth token back to be used to login via option `p`.

If there are issues with the login, prompt the user to run `keeper login` in a separate terminal and wait for them to complete it before continuing.

4. **Fetch Folder UID** — Find the UID for the target folder.

Run in order:

```
keeper ls "Environment Variables"
```

Based on the selected environment, run:

```
keeper ls -l "Environment Variables/1 Dev"
```

(Options: 1 Dev, 2 Acc, 3 Prd)

Find the matching service in the returned list and its UID — used in the add command.

5. **Generate Command** — Using the transformed data:

```
keeper record-add --title "<variable-name>" --record-type encryptedNotes --folder <folder-uid> note=<value> --force
```

6. **Present a brief overview to the user** — Include:

   - The details they provided (transformed if applicable)
   - The keeper command that will be executed
   - The target path of the new record

   Example output:

   ```
   Overview
   Variable name: [PRD] MY_NEW_ENV_VAR
   Value: "<redacted-preview>"
   Environment: production
   Service: CI Secrets

   Path: Environment Variables/3 Prd/CI Secrets/[PRD] MY_NEW_ENV_VAR
   ```

7. **Execute Command** — Run the keeper CLI command and return a success/failure message.

## Rules

- **Never fetch/read a production secret value** — dev/test only. Adding to any environment (incl. prod) is fine.
- **Never run the record-add command without explicit permission** — that's the whole point of this command
- Never echo the full secret value back in plaintext beyond a short preview
