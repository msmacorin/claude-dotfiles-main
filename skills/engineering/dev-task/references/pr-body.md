# PR body requirements

For the PR opened in step 10. Write the body to a scratchpad file and pass `--body-file`.

- **Title**: `<type>(<scope>): <summary> (#<N>)` — conventional-commit type, in the repo's language for the summary.
- **Use the repo's PR template** if `REPO_PATH` has `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/*.md`): fill its sections, keep its structure. No template: the sections below.
- **Always include**, where the template has no slot:
  - **Resumo**: what changed and why, a few bullets.
  - **Feature flag**: the flag's name and how it gates the change. Otherwise "N/A" plus a specific reason tied to this change ("not necessary" alone is not a reason). N/A only when nobody asked for a flag.
  - **Test plan**: what the tests cover (new behavior, edge cases, negative paths) and the commands that ran green (lint, type-check, tests).
  - **Rollback**: "Revert this PR." plus, if there is a flag, "or set `<FLAG>` to off".
  - **Follow-ups**: findings left on purpose, one line each with `path:line`; omit if none.
- **Closing keywords** at the end, one per line: `Closes #<N>` for the story/task/bug and each dev task this PR completes. Never the parent epic — it closes once all its stories are done.
