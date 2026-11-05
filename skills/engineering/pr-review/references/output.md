# Grading, report and posting

## Severity

- **BLOCKING** — must be fixed before merge: wrong behavior, missing/non-discriminating test for a behavior, security or data-integrity risk.
- **WARNING** — should be fixed before merge: likely bug, fragile pattern, convention break with real cost.
- **SUGGESTION** — nice to have.
- **Precisa de você** — not a severity: a product decision, missing information, or something only a human can verify. Each item has options and your recommendation.

Use the severity from the checklist table; deviate only with a written reason. Don't inflate: a review with ten blockers that are really suggestions trains people to ignore it.

## Report for the user (in Portuguese)

```
## Review — <owner/repo#N or branch> · <title>
Autor: <from a tool, or unverified> · Base: <base> · Head: <short SHA>
Escopo: <one line of what the change does>
Fontes de negócio: <issue #N, ACs, discovery doc… or "limitado: sem issue/ACs">

Veredito: <Limpo | N blocking · M warnings · K suggestions>
Flow coverage: <N> casos · <M> cobertos

### Comportamentos esperados
- Given … When … Then …  (fonte)

### Flow Coverage Matrix
<full table, all rows>

### Findings
#### BLOCKING
- **R4** `path:line` — <issue>. **Fix:** <concrete fix or code>
#### WARNING
#### SUGGESTION

### Precisa de você
- [ ] <decision: options + recommendation>
- [ ] <info not found: what, where you looked>

### Pontos positivos
- <specific, honest>
```

Long reports: the summary (veredito, coverage, top 3 blockers) comes first, so it can be read in five seconds.

## Inline comments (PR mode)

Draft one comment per finding, anchored to its line, self-contained (ID, issue, why it matters here, fix). Comments are written in the language the PR and team use. Each ends with the agent footer:

```
---
🤖 Review by **pr-review** · [Claude Code Agent](https://claude.com/claude-code)
```

Show all drafts with the report. Post only after the user approves them in the conversation (all, or the ones they pick), as **one** review with `event: COMMENT`:

```bash
gh api repos/{owner}/{repo}/pulls/<N>/reviews --method POST --input <scratch>/review.json
```

`review.json`: `{"commit_id": "<head SHA>", "event": "COMMENT", "body": "<short summary>", "comments": [{"path": "...", "line": 42, "side": "RIGHT", "body": "..."}]}`. The line must be part of the diff; findings on lines outside it go in the summary body with `path:line`.

Never use `APPROVE` or `REQUEST_CHANGES`, and never `gh pr review --approve` / `--request-changes`. Approving or rejecting is a human action.

## Return format inside dev-task

```
Flow coverage: <N> casos · <M> cobertos
ID | severity | path:line | issue | fix
...
Precisa de você:
- ...
```
