---
name: dev-task
description: Develop a Jira issue (Task, Story, Bug, or Epic) end-to-end starting from its issue key. Fetches the issue, interviews the user grill-me style if requirements are thin, plans a breakdown (epic -> stories -> dev subtasks, or task -> dev subtasks) partitioned into non-overlapping scope, gets one approval, writes the plan back to Jira, implements every subtask directly in the repo's working tree, runs code review, and opens a PR ready for the user's review, linking/transitioning the Jira issue(s). Use when the user wants to start development on a Jira ticket or epic - e.g. "desenvolve a PROJ-123", "vamos trabalhar nessa task do jira", "pega esse épico e parte pro código", or `/dev-task <ISSUE-KEY>`.
---

# Dev Task

Develop a Jira issue end-to-end: gather requirements, write the plan back to
Jira, implement it directly in the repo's working tree, run code review, and
open a PR ready for the user to review.

## Quick start

`/dev-task <ISSUE-KEY>` (e.g. `/dev-task PROJ-123`). Run from inside the
target repo - `git rev-parse --show-toplevel` is used as `REPO_PATH`. If no
key is given, ask for one.

## Workflow

1. **Fetch & classify** - `getJiraIssue(<KEY>)`. Note issue type (Epic vs
   Story/Task/Bug), current description, existing subtasks/children, and
   project key.

2. **Requirements**
   - Description present and detailed -> summarize your understanding back to
     the user.
   - Description blank/thin -> run a grill-me-style interview: one question
     at a time, exploring the repo first wherever the answer can be found
     there, offering a recommended answer for each open question.

3. **Plan the breakdown**
   - **Epic** -> propose Stories/Tasks (title + acceptance criteria each).
     Each Story is then broken into dev subtasks (next bullet).
   - **Task/Story/Bug** -> propose dev subtasks directly.
   - Dev subtasks must still partition the work by non-overlapping file/module
     scope - explore the codebase to validate the split. This keeps each
     subtask reviewable and independently verifiable even though step 7
     implements them sequentially in the same working tree, not in parallel.
     If the work is a single unit, propose exactly one subtask (no artificial
     splitting).
   - If the issue already has subtasks/children, treat them as the starting
     plan instead of inventing new ones - propose edits only where needed.
   - Propose the mission identifier `<ISSUE-KEY>-<slug>`, used as the mission
     branch name (created directly in `REPO_PATH` in step 6). This doubles as
     the mission's codename - no need to ask the user for a separate one.

4. **CHECKPOINT (the only approval gate)** - present: updated description(s),
   full breakdown (stories + subtasks, or subtasks), and the mission
   identifier. Iterate until the user approves. Everything after this step
   runs autonomously except for execution failures (see "Failure handling").

5. **Apply the plan to Jira** - update description(s) via `editJiraIssue`,
   create Stories under the Epic and/or dev subtasks via `createJiraIssue`.
   See [REFERENCE.md](REFERENCE.md) for exact call sequences.

6. **Set up the mission branch** - `git checkout main && git pull` in
   `REPO_PATH`, then `git checkout -b <ISSUE-KEY>-<slug>`. All lead-agent work
   for this mission happens directly in `REPO_PATH` on this branch.

7. **Implementation** - work through each dev subtask directly in
   `REPO_PATH`, on the mission branch, in the lead session - no spawned
   agents, no worktrees. Do them one at a time in dependency order (schema
   before API before UI, etc.); the non-overlapping-scope split from step 3
   still keeps each subtask reviewable on its own even though nothing runs
   in parallel. Write no WHAT-comments - only non-obvious WHY.

   **Frontend tasks**: if a subtask touches UI (pages, components, forms,
   SCSS, layouts), read the project's `velzon-frontend` skill
   (`.claude/skills/velzon-frontend/SKILL.md` inside `REPO_PATH`, if present)
   before writing any frontend code, and follow its conventions.

   **Opt-in parallel exception**: only spawn `sandboxed-worker` agents in
   worktrees for this mission if the user explicitly asks for parallel
   subagents on it (e.g. "roda essas subtasks em paralelo"). Absent that ask,
   always implement directly - do not default back to sandboxing because a
   plan has multiple subtasks.

8. **Verify** - in `REPO_PATH` (on the mission branch), run the full lint +
   test suite; stop on the first failure, fix, re-run.

9. **Code review** - run `/code-review --fix` (medium/high effort) on the
   mission branch's diff vs `main`, so findings are fixed in the working tree
   before the PR is opened.

9.5. **Second opinion (opt-in)** - if the change is risky or you want external
    eyes, run `/segunda-opiniao review` on the branch's diff to corroborate with
    Codex + Gemini before shipping. Skip for trivial changes.

10. **Ship** - push the mission branch and `gh pr create` referencing
    `<ISSUE-KEY>`. This PR, already reviewed and fixed, is the deliverable
    handed back to the user for human review.

11. **Link back to Jira** - for each Jira issue touched (main issue, stories,
    subtasks): comment the PR link and, if a "review"-like transition exists
    (see REFERENCE.md), move it there.

12. **Wrap-up** - no worktree to remove; `REPO_PATH` stays on the mission
    branch with the open PR. Summarize for the user: PR link, issues updated,
    branch name.

## Failure handling

The checkpoint in step 4 is the only planned pause. Any execution failure - a
test that won't pass, a subtask turning out to need scope not covered by the
plan, missing Jira fields/issue types/transitions - stops the flow and is
reported to the user. Don't guess past these; autonomy covers the happy path
only.

## References

- [REFERENCE.md](REFERENCE.md) - Atlassian MCP call sequences, ADF description
  format, issue-type/transition discovery, epic<->story linking.
- `sandboxed-worker` agent (`claude-dotfiles/agents/sandboxed-worker.md`) - the
  worktree/branch isolation protocol, only used if the user opts into
  parallel subagents for this mission (see step 7).
