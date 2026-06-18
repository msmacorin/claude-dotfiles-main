---
name: security-auditor
description: Runs structured npm security audits with actionable remediation plans. Parses `npm audit --json`, classifies vulnerabilities by severity (critical/high/medium/low), extracts CVE identifiers, distinguishes direct vs transitive deps, generates markdown reports with fix commands, and supports risk acceptance via `security-exceptions.json`. Use when user mentions "npm audit", "security vulnerability", "dependency vulnerability", "CVE", "security check", "audit dependencies", or "check vulnerabilities".
---

_Source: [wrsmith108/claude-skill-security-auditor](https://github.com/wrsmith108/claude-skill-security-auditor)_

# Security Auditor

## Quick start

```bash
# From the project directory (needs Node.js + npm + package.json)
npx tsx ~/.claude/skills/security-auditor/scripts/index.ts

# JSON output (for CI integration)
npx tsx ~/.claude/skills/security-auditor/scripts/index.ts --json

# Fail CI on high or critical vulnerabilities
npx tsx ~/.claude/skills/security-auditor/scripts/index.ts --fail-on high

# Audit a specific directory
npx tsx ~/.claude/skills/security-auditor/scripts/index.ts --cwd /path/to/project
```

## Workflows

### Interactive audit
1. Run the audit script from the project root
2. Read the markdown report — vulnerabilities sorted by severity (critical first)
3. Apply auto-fixable items: `npm audit fix` (or `npm audit fix --force` for major bumps)
4. For unfixable items, evaluate alternatives or add to `security-exceptions.json`

### CI integration
```bash
# Exit code 1 if any high/critical found
npx tsx ~/.claude/skills/security-auditor/scripts/index.ts --fail-on high
```
Exit codes: `0` = clean, `1` = threshold exceeded, `2` = error

### Accepting known risks

Create `security-exceptions.json` in the project root:
```json
{
  "exceptions": [
    {
      "id": "GHSA-xxxx-xxxx-xxxx",
      "reason": "Not exploitable in our usage context",
      "expires": "2025-12-01",
      "approvedBy": "security-team"
    }
  ]
}
```
Expired exceptions are automatically ignored.

## Scripts

- `scripts/audit.ts` — core logic: runs `npm audit --json`, parses output, applies exceptions, generates reports
- `scripts/index.ts` — CLI entry point with `--json`, `--fail-on`, `--cwd`, `--help` flags
