---
name: dev-task
description: Develop a Jira issue (Task, Story, Bug, or Epic) end-to-end starting from its issue key. Fetches the issue, interviews the user grill-me style if requirements are thin, plans a breakdown (epic -> stories -> dev subtasks, or task -> dev subtasks) partitioned for non-conflicting parallel work, gets one approval, writes the plan back to Jira, develops every subtask in parallel via sandboxed-worker agents, consolidates, runs code review, and opens a PR ready for the user's review, linking/transitioning the Jira issue(s). Use when the user wants to start development on a Jira ticket or epic - e.g. "desenvolve a PROJ-123", "vamos trabalhar nessa task do jira", "pega esse épico e parte pro código", or `/dev-task <ISSUE-KEY>`.
---

# Dev Task

Develop a Jira issue end-to-end: gather requirements, write the plan back to
Jira, fan out the implementation to parallel sandboxed subagents, consolidate,
run code review, and open a PR ready for the user to review.

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
   - Dev subtasks must partition the work by non-overlapping file/module
     scope so they can run in parallel without merge conflicts - explore the
     codebase to validate the split. If the work is a single unit, propose
     exactly one subtask (no artificial splitting).
   - If the issue already has subtasks/children, treat them as the starting
     plan instead of inventing new ones - propose edits only where needed.
   - Propose the mission identifier `<ISSUE-KEY>-<slug>`, used for
     branch/worktree names. This doubles as the mission's codename - no need
     to ask the user for a separate one.

4. **CHECKPOINT (the only approval gate)** - present: updated description(s),
   full breakdown (stories + subtasks, or subtasks), and the mission
   identifier. Iterate until the user approves. Everything after this step
   runs autonomously except for execution failures (see "Failure handling").

5. **Apply the plan to Jira** - update description(s) via `editJiraIssue`,
   create Stories under the Epic and/or dev subtasks via `createJiraIssue`.
   See [REFERENCE.md](REFERENCE.md) for exact call sequences.

6. **Set up the mission worktree** - `git checkout main && git pull` in
   `REPO_PATH`, then create `~/dev/claude-working-here/worktrees/<ISSUE-KEY>/`
   on branch `<ISSUE-KEY>-<slug>` from updated main.

7. **Parallel development** - for each dev subtask, spawn a
   `sandboxed-worker` agent (`mode: bypassPermissions`), all in a single
   message so they run in parallel. Give each: `REPO_PATH`,
   `AGENT_NAME=<ISSUE-KEY>-<subtask-key>`,
   `TASK_BRANCH=<ISSUE-KEY>-<subtask-key>`,
   `BASE_REF=<ISSUE-KEY>-<slug>` (the mission branch), and its subtask
   description/acceptance criteria. `sandboxed-worker` already enforces no
   WHAT-comments in the code it writes - only non-obvious WHY.

8. **Consolidate** - in the mission worktree, `git merge --no-ff` each
   subagent branch in turn, then delete the merged branches. Run the full
   lint + test suite; stop on the first failure, fix, re-run.

9. **Code review** - run `/code-review --fix` (medium/high effort) on the
   consolidated diff vs `main`, so findings are fixed in the working tree
   before the PR is opened.

10. **Ship** - push the mission branch and `gh pr create` referencing
    `<ISSUE-KEY>`. This PR, already reviewed and fixed, is the deliverable
    handed back to the user for human review.

11. **Link back to Jira** - for each Jira issue touched (main issue, stories,
    subtasks): comment the PR link and, if a "review"-like transition exists
    (see REFERENCE.md), move it there.

12. **Cleanup** - `git worktree remove` the mission worktree (keep the branch
    - it has an open PR). Summarize for the user: PR link, issues updated,
    branch name.

## Failure handling

The checkpoint in step 4 is the only planned pause. Any execution failure - a
subagent stuck or out of scope, merge conflicts in step 8, a test that won't
pass, missing Jira fields/issue types/transitions - stops the flow and is
reported to the user. Don't guess past these; autonomy covers the happy path
only.

## References

- [REFERENCE.md](REFERENCE.md) - Atlassian MCP call sequences, ADF description
  format, issue-type/transition discovery, epic<->story linking.
- `sandboxed-worker` agent (`claude-dotfiles/agents/sandboxed-worker.md`) - the
  per-subtask worktree/branch isolation protocol used in step 7.
