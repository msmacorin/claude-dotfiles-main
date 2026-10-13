---
name: dev-task
description: Develop a GitHub issue (Epic, Story, Task, or Bug) end-to-end starting from its issue number. Fetches the issue, interviews the user grill-me style if requirements are thin, plans a breakdown (epic -> stories -> dev tasks, or story/task -> dev tasks) partitioned into non-overlapping scope, gets one approval, writes the plan back to GitHub as sub-issues, implements every task directly in the repo's working tree, runs code review, and opens a PR ready for the user's review, moving the issue(s) to Review on the linked GitHub Project. Use when the user wants to start development on a GitHub issue or epic - e.g. "desenvolve a #123", "vamos trabalhar nessa issue", "pega esse épico e parte pro código", or `/dev-task <NUMBER>`.
---

# Dev Task

Develop a GitHub issue end-to-end: gather requirements, write the plan back
as sub-issues, implement it directly in the repo's working tree, run code
review, and open a PR ready for the user to review.

All GitHub access goes through the `gh` CLI (needs the `project` token scope
for the Project steps - if missing, ask the user to run
`gh auth refresh -s project`).

## Quick start

`/dev-task <NUMBER>` (e.g. `/dev-task 123`, `#123`, or the issue URL). Run
from inside the target repo - `git rev-parse --show-toplevel` is used as
`REPO_PATH`, and `gh repo view --json nameWithOwner` gives `OWNER/REPO`. If no
number is given, ask for one.

## Workflow

1. **Fetch & classify** - `gh issue view <N> --json
   number,title,body,labels,state,url,parent,subIssues`. The issue type comes
   from its `type:*` label (`type:epic` / `type:story` / `type:task` /
   `type:bug`); if none, ask the user. Note the current body, parent, and
   existing sub-issues.

2. **Requirements**
   - Body present and detailed -> summarize your understanding back to the
     user.
   - Body blank/thin -> run a grill-me-style interview: one question at a
     time, exploring the repo first wherever the answer can be found there,
     offering a recommended answer for each open question.

3. **Plan the breakdown**
   - **Epic** -> propose Stories (title + acceptance criteria each). Each
     Story is then broken into dev tasks (next bullet).
   - **Story/Task/Bug** -> propose dev tasks directly.
   - Dev tasks must still partition the work by non-overlapping file/module
     scope - explore the codebase to validate the split. This keeps each task
     reviewable and independently verifiable even though step 7 implements
     them sequentially in the same working tree, not in parallel. If the work
     is a single unit, propose zero sub-tasks and implement the issue itself
     (no artificial splitting).
   - If the issue already has sub-issues, treat them as the starting plan
     instead of inventing new ones - propose edits only where needed.
   - Propose the mission identifier `<N>-<slug>` (e.g. `123-vehicle-sell`),
     used as the mission branch name (created in step 6). This doubles as the
     mission's codename - no need to ask the user for a separate one.

4. **CHECKPOINT (the only approval gate)** - present: updated body/bodies,
   full breakdown (stories + tasks, or tasks), labels for each new issue, and
   the mission identifier. Iterate until the user approves. Everything after
   this step runs autonomously except for execution failures (see "Failure
   handling").

5. **Apply the plan to GitHub** - update bodies with `gh issue edit`, create
   stories/tasks as sub-issues with `gh issue create --parent`, add every
   touched issue to the repo's linked Project and set Status to
   **In Progress**. See [REFERENCE.md](REFERENCE.md) for exact commands.

6. **Set up the mission branch** - `git checkout main && git pull` in
   `REPO_PATH`, then `git checkout -b <N>-<slug>`. All lead-agent work for
   this mission happens directly in `REPO_PATH` on this branch.

7. **Implementation** - work through each dev task directly in `REPO_PATH`,
   on the mission branch, in the lead session - no spawned agents, no
   worktrees. Do them one at a time in dependency order (schema before API
   before UI, etc.); the non-overlapping-scope split from step 3 still keeps
   each task reviewable on its own even though nothing runs in parallel.
   Write no WHAT-comments - only non-obvious WHY.

   **Frontend tasks**: if a task touches UI (pages, components, forms,
   SCSS, layouts), read the project's `velzon-frontend` skill
   (`.claude/skills/velzon-frontend/SKILL.md` inside `REPO_PATH`, if present)
   before writing any frontend code, and follow its conventions.

   **Opt-in parallel exception**: only spawn `sandboxed-worker` agents in
   worktrees for this mission if the user explicitly asks for parallel
   subagents on it (e.g. "roda essas tasks em paralelo"). Absent that ask,
   always implement directly - do not default back to sandboxing because a
   plan has multiple tasks.

8. **Verify** - in `REPO_PATH` (on the mission branch), run the full lint +
   test suite; stop on the first failure, fix, re-run.

9. **Code review** - run `/code-review --fix` (medium/high effort) on the
   mission branch's diff vs `main`, so findings are fixed in the working tree
   before the PR is opened.

9.5. **Second opinion (opt-in)** - if the change is risky or you want external
    eyes, run `/segunda-opiniao review` on the branch's diff to corroborate with
    Codex + Gemini before shipping. Skip for trivial changes.

10. **Ship** - push the mission branch and `gh pr create`. The PR body must
    carry one `Closes #<N>` line per issue this PR completes (the story/task/
    bug and its dev tasks - never the parent epic, which closes only when all
    its stories are done). This PR, already reviewed and fixed, is the
    deliverable handed back to the user for human review.

11. **Move to Review** - set Status = **Review** on the Project for every
    issue listed in `Closes`. Never set **Done** yourself: merging the PR
    closes the issues and the Project's built-in workflow moves them to Done.
    If the repo has no linked Project or no Review option, skip and say so in
    the summary.

12. **Wrap-up** - `REPO_PATH` stays on the mission branch with the open PR.
    Summarize for the user: PR link, issues created/updated, branch name.

## Failure handling

The checkpoint in step 4 is the only planned pause. Any execution failure - a
test that won't pass, a task turning out to need scope not covered by the
plan, missing labels/Project/Status options, missing token scope - stops the
flow and is reported to the user. Don't guess past these; autonomy covers the
happy path only.

## References

- [REFERENCE.md](REFERENCE.md) - `gh` command sequences for issues,
  sub-issues, Project discovery and Status updates.
- `sandboxed-worker` agent (`claude-dotfiles/agents/sandboxed-worker.md`) - the
  worktree/branch isolation protocol, only used if the user opts into
  parallel subagents for this mission (see step 7).
