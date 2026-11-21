# The branches the workflow owns: the ones /begin, /branch and /audit-fix create. Sourced by
# .claude/hooks/commit-guard.sh and .claude/scripts/push-branch.sh, so both refuse the same branches.
# /install fills both from the branch convention in docs/workflow-config.md.
OWNED_BRANCH='^([A-Z][A-Z0-9]+-[0-9]+-[a-z0-9][a-z0-9-]*|(bugfix|housekeeping|spike|refactor)-[a-z0-9][a-z0-9-]*|audit/[a-z0-9][a-z0-9-]*)$'
OWNED_HINT='<TICKET-ID>-<summary>, bugfix-, housekeeping-, spike- or refactor-<slug>, or audit/<slug>'
