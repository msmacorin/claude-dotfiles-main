---
name: dev-task
description: Develop a GitHub issue (Epic, Story, Task or Bug) end-to-end from its number - plan a breakdown with one approval, write it back as sub-issues, implement directly in the repo's working tree, verify, code-review, open a PR, move the issues to Review on the linked GitHub Project, and stay with the PR through review comments and merge, with handoff checkpoints. Triggers include "desenvolve a #123", "vamos trabalhar nessa issue", "pega esse épico e parte pro código", "implementa essa story", "/dev-task <NUMBER>", and after the PR is open "lê os comentários", "pode mergear?".
category: orchestration
---

# Dev Task

## Quick start

`/dev-task <NUMBER>` (`123`, `#123` or the issue URL) from inside the target repo: `git rev-parse --show-toplevel` is `REPO_PATH`, `gh repo view --json nameWithOwner` gives `OWNER/REPO`. No number given: ask for one. All GitHub access goes through `gh`; the Project steps need the `project` scope (missing → ask the user to run `gh auth refresh -s project`).

## Read only what you need

| When | Read |
|---|---|
| Any `gh` issue / sub-issue / Project call (steps 1, 5, 11) | [references/github-calls.md](references/github-calls.md) |
| Opening the PR (step 10) | [references/pr-body.md](references/pr-body.md) |
| PR is open: review comments, CI, merge | [references/after-pr.md](references/after-pr.md) |
| Task touches UI | the repo's `.claude/skills/velzon-frontend/SKILL.md`, if present |

TypeScript work follows the `typescript-expert` skill.

## Workflow

1. **Fetch & classify.** `gh issue view <N> --json number,title,body,labels,state,url,parent,subIssues`. Type = its `type:*` label; none → ask.
2. **Requirements.** Detailed → summarize your understanding. Thin → `grill-me` stance: explore the repo first, ask only what's left, one question at a time, each with a recommended answer.
3. **Plan the breakdown.** Epic → Stories with ACs, each split into dev tasks; Story/Task/Bug → dev tasks. Tasks own non-overlapping files/modules (validate against the code) so each is reviewable on its own; a single unit stays zero sub-tasks. Existing sub-issues are the starting plan. Propose the mission id `<N>-<slug>`: it is the branch name and the codename.
4. **Checkpoint (the one approval).** Show updated bodies, the full breakdown with labels, and the mission id; iterate until approved. Then run on your own, except for the failures below.
5. **Write the plan to GitHub.** `gh issue edit` for bodies, `gh issue create --parent` for sub-issues, every touched issue to the Project with Status **In Progress**. Then save a handoff checkpoint.
6. **Mission branch.** `git -C <REPO_PATH> checkout main`, then `git -C <REPO_PATH> pull`, then `git -C <REPO_PATH> checkout -b <N>-<slug>` (one command per call).
7. **Implement directly in `REPO_PATH`**, in the lead session, one task at a time in dependency order (schema → API → UI). No spawned agents, no worktrees — `sandboxed-worker` only if the user explicitly asks for parallel subagents on this mission. No WHAT-comments, only non-obvious WHY. Behavior changes go behind a feature flag; test the new behavior plus its edge cases, negative paths and regressions.
8. **Verify.** Full lint + type-check + test suite; stop at the first failure, find the root cause, fix, re-run.
9. **Code review.** `/code-review --fix` (medium/high) on the branch diff vs `main`. Then a **fresh-context review**: spawn one read-only general-purpose subagent with only `Review branch <N>-<slug> of <OWNER/REPO> vs main using the pr-review skill, in dev-task mode: load the skill and its references, load issue #<N> and its sources yourself, build the full matrix, post nothing, return the dev-task format.` — no reasoning or plan from you, it must judge on its own. Fix every BLOCKING and WARNING, re-verify (step 8), and repeat the subagent (max 3 rounds); items it can't converge on and "Precisa de você" go to step 12. Risky change → also `/segunda-opiniao review`; skip for trivial ones.
10. **Ship.** Push the branch and `gh pr create`, body per [pr-body.md](references/pr-body.md).
11. **Move to Review.** Status **Review** on the Project for every issue in the PR's `Closes` lines. Never set **Done** yourself: the merge closes the issues and the Project workflow moves them. No linked Project or no Review option → skip and say so.
12. **Hand over.** Report: PR link, issues created/updated, branch, what code review fixed, and **Precisa de você** (info you couldn't find, decisions, follow-ups). `REPO_PATH` stays on the mission branch. Save a checkpoint; from here follow [after-pr.md](references/after-pr.md).

## Handoff checkpoints

Run `/handoff <mission-id> --checkpoint` after step 5 and after step 12. After the merge, a full `/handoff <mission-id>` archives the mission. Later sessions resume from the last checkpoint with `/resume`.

## Failure handling

After step 4, fix what you can explain and keep going. Stop and report only for: a test failure or review finding you can't explain or whose fix changes expected behavior or scope; a task needing scope the plan doesn't cover; missing labels, Project, Status options or token scope. Save a checkpoint before stopping.
