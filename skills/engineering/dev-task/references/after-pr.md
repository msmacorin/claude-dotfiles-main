# After the PR is open

The PR is in the user's review. Stay with it until it is merged. The user drives the pace: they can ask to read the comments, check CI, paste feedback, or give their own notes. This often happens in a later session resumed with `/resume <mission-id>`.

## Review-feedback loop

1. **Fetch** on request ("lê os comentários", "como tá o CI") or when the user pastes feedback:
   ```
   gh pr view <N> --json state,isDraft,reviewDecision,reviews,statusCheckRollup
   gh api repos/{owner}/{repo}/pulls/<N>/comments --jq '.[] | {id: .id, path: .path, line: .line, author: .user.login, body: .body}'
   gh pr checks <N>
   ```
   Summarize: reviewers and state, comment counts, CI status, then each comment with `file:line`.
2. **Triage** each comment (from Copilot, linters, bots or humans): valid → fix; conflicts with a repo convention → push back with the reason; out of scope → propose a follow-up issue (`write-issue`); needs a product/design call → list it for the user with a recommendation. A bot finding and a human comment on the same line are one item.
3. **Fix** on the mission branch in `REPO_PATH` (`git -C <REPO_PATH> checkout <N>-<slug>` if needed). Lint + type-check + tests, one commit per logical fix, push. For a non-trivial change, run `/code-review` again before replying.
4. **CI.** If it fails, read the failing job (`gh run view <id> --log-failed`), fix, push.
5. **Replies.** Draft one reply per comment handled (with the commit SHA when there is one) and show them all to the user. Post only after the user approves them in the conversation (CLAUDE.md rule).
6. **Checkpoint.** `/handoff <mission-id> --checkpoint`.
7. Repeat until the user is satisfied and CI is green.

Never approve or request changes on a PR (`gh pr review --approve` / `--request-changes` are forbidden).

## Merge

Merge only when the user asks and CI is green. Prefer `gh pr merge <N> --squash` unless the repo uses another strategy.

## After merge

Merged is not deployed: check the deployed SHA (e.g. the Vercel deployment for `main`) before saying a change is in production. If the work introduced a flag, remind the user of its rollout.

Then run a full `/handoff <mission-id>`: the PR is merged, so the mission is archived.
