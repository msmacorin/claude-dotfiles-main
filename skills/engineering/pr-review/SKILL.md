---
name: pr-review
description: Rigorous review of a TypeScript PR or branch (Next.js/React, Node, Prisma, Zod) that checks business correctness as well as code - every acceptance criterion traced to code and a test, domain invariants (money, stock, state, tenancy, permissions, time), a Flow Coverage Matrix that flags tests which would still pass if the change were reverted, PR description vs code, safety and TypeScript rules. Returns a draft for the user; nothing is posted without approval, and it never approves or requests changes. Also runs as dev-task's fresh-context reviewer. Triggers include "revisa a PR", "faz o review", "review pr #12", "revisa minha branch", "olha essa PR antes de eu abrir", "/pr-review <N>".
category: quality
argument-hint: "[PR number or URL] [focus]"
---

# PR review

Produce a review draft for the user. The user decides what gets posted. Scope is **business and technical**: does the code do what the issue says the product should do, and does it do it safely, tested and well-structured.

The touchstone: *the intent is visible in the diff — the question is whether the code actually does it.*

## Rules

0. **Never invent a fact.** Author, SHA, issue number, `path:line`, flag name, AC text — each one comes from a tool this turn. Unavailable → write `unverified`, never a plausible value. One invented fact discredits the whole review.
1. **Intended behavior first.** Load the issue and its sources (see [business.md](references/business.md)) before reading the diff. Without them, say up front that the business review is limited and list what you assumed.
2. **Read changed files in full**, plus the callers and callees that the change affects. Never review hunks in isolation.
3. **Be specific and constructive.** Every finding: `path:line`, checklist ID, one-line explanation, and a concrete fix or code example (BLOCKING and WARNING).
4. **Contradictions are findings, not choices.** If the issue, the PR description and the code disagree, report it; don't silently pick one.
5. **Product decisions go to the user.** A finding whose fix depends on a business call goes under "Precisa de você" with options and a recommendation, not into a severity guess.
6. **Say what was done well.** Honest positives, briefly.

## Modes

| Invocation | Target | Output |
|---|---|---|
| `/pr-review <N or URL>` | a PR (yours or someone else's) | draft for the user; posting only on approval |
| `/pr-review` (no argument) | current branch vs `main` | self-review report, nothing to post |
| called by `dev-task` | the mission branch | findings list for the lead, posts nothing |

## Read only what you need

| When | Read |
|---|---|
| Loading intended behavior, business checks (step 2, 5) | [references/business.md](references/business.md) |
| Building the matrix (step 4) | [references/coverage-matrix.md](references/coverage-matrix.md) |
| Running the technical checklist (step 6) | [references/checklist.md](references/checklist.md) |
| Grading, writing and posting (steps 7–9) | [references/output.md](references/output.md) |
| TS rules behind the `TS*` checks | `typescript-expert` skill |
| UI conventions in a repo that has one | the repo's `.claude/skills/*/SKILL.md` (e.g. `velzon-frontend`) |

## Flow

1. **State.** PR mode: `gh pr view <N> --json number,title,body,author,state,isDraft,baseRefName,headRefName,headRefOid,files,reviews,closingIssuesReferences`. Already reviewed by the user → say so and stop unless asked to re-review. Branch mode: `git -C <repo> diff main...HEAD --stat` and `git -C <repo> log main..HEAD --oneline`.
2. **Intended behavior.** Load the linked issue(s), parent story/epic, ACs and any discovery/PRD doc per [business.md](references/business.md). Write down, before looking at code, the behaviors the change must produce.
3. **Read the code.** Changed files in full. For someone else's PR, don't touch the user's working tree: `git -C <repo> fetch origin pull/<N>/head:pr-<N>`, then read with `git -C <repo> show pr-<N>:<path>`. Read the repo's `CLAUDE.md`, `AGENTS.md`, `README.md` conventions, lint/tsconfig and test setup for local conventions — local rules win over this skill's.
4. **Flow Coverage Matrix.** Every changed function or endpoint, every path, mapped to its test, with the discriminates-on-revert check ([coverage-matrix.md](references/coverage-matrix.md)).
5. **Business review.** AC traceability and the domain-invariant questions in [business.md](references/business.md) (`R*`).
6. **Technical checklist.** `Z*`, `T*`, `S*`, `E*`, `TS*`, `W*`, `C*`, `D*`, `Q*` in [checklist.md](references/checklist.md). Record each failure with `path:line`.
7. **Run code only when a finding depends on it** (a test you suspect passes on the old code, a type error you can't confirm by reading). Branch mode: run it in place. Someone else's PR: ask before checking it out.
8. **Grade and draft** per [output.md](references/output.md): summary, matrix, findings by severity, "Precisa de você", positives, and the inline comments you'd post.
9. **Hand over.** Show the draft. Post only after the user approves it in the conversation, as inline comments in a `COMMENT` review, never approve or request changes.

## Inside dev-task

`dev-task` runs this skill in a **fresh-context subagent** after its own `/code-review --fix`: the session that wrote the code reads it as intended and misses what a fresh reader catches. Same protocol, read-only, posts nothing. It returns the matrix summary, the findings as `ID | severity | path:line | issue | fix`, and the human-only items. The lead fixes and may run it again (max 3 rounds).
