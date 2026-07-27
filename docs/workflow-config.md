# Workflow Configuration

> This is an example configuration. Run `/install` to generate one tailored to your project.

## Project
- **Language:** TypeScript
- **Framework:** React / Next.js
- **Monorepo:** No
- **Package manager:** pnpm

## Commands
- **Test:** npm run test
- **Lint:** npm run lint
- **Format:** npm run format
- **Format check:** npm run format:check
- **Build:** npm run build

## Ticket Tracker
- **System:** Jira
- **Base URL:** https://mycompany.atlassian.net
- **Project prefix:** PROJ
- **Credentials:** ~/AI/config/jira.env

## Git
- **Hosting:** GitHub
- **Default branch:** main
- **Branch convention:** <TICKET-ID>-<kebab-case-summary>

## Working Directories
- **AI temp files:** .claude/temp/
- **AI docs:** .claude/docs/

## Modules
- **observability:** installed (provider: Azure App Insights)
- **audit:** installed
- **release:** skipped
- **secrets:** n/a

## Observability
- **Provider:** Azure Application Insights (KQL)
- **Logging strategy:** docs/logging-strategy.md
- **Dashboards dir:** dashboards/

## Audit
- **Targets:** catalog-service, search-service, content-service, web-app
- **Output:** .claude/audit/<date>/

## Forge Workflow
- **Version:** 1.2.0
