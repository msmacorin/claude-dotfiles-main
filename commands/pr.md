Generate a concise PR description and create/update the PR on GitHub.

# Guidelines

## Core Principles

- **Be brief**: Each section should have 2-5 lines max. No walls of text.
- **Bullet points over paragraphs**: Use lists for changes and decisions.
- **Skip the obvious**: Don't describe what the diff already shows. Focus on the "why".
- **Only include Rationale if non-trivial**: Skip it for straightforward changes.
- **Language**: Write in English by default. If the repo's recent PR descriptions are in another language, match that.

## Template

```markdown
## Problem
<!-- 1-2 sentences: what was wrong or missing -->

## Solution
<!-- Bullet list of main changes -->

## Rationale
<!-- Only if there are non-obvious decisions. Otherwise remove this section. -->
```

## Writing Rules

### Problem
- 1-2 sentences max. State what was broken, missing, or needed.
- No long backstory. Get to the point.

### Solution
- Bullet list of what changed (3-6 items).
- Mention new files/components only if relevant.
- Don't list every file -- summarize by area.

### Rationale
- Only include when the approach is non-obvious.
- 1-3 bullet points explaining key decisions.
- Omit entirely for simple bug fixes or small features.

## Execution Steps

1. **Detect base branch**: check `gh repo view --json defaultBranchRef` or look for `main`/`master`/`develop` — never assume.

2. **Analyze current branch**:
   ```
   git diff <base>...HEAD --name-only
   git diff <base>...HEAD
   git log --oneline <base>...HEAD
   ```

3. **Check for PR template**: look for `.github/PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template.md` in the repo. If one exists, use that template instead of the default one above.

4. **Check existing PRs style**: run `gh pr list --limit 3 --json title` to see title conventions. Adapt title format to match the repo's existing pattern.

5. **Read key files if context is unclear**: main modified files, new files, related tests.

6. **Generate PR title**: Keep under 70 chars. Match the repo's existing title convention (e.g., `[BRANCH] - summary`, `feat: summary`, `JIRA-123: summary`, or just a plain summary).

7. **Generate PR body** following the template (or repo template if found). Keep it short enough to read in 30 seconds.

8. **Show draft to user**: Present the full title + body for review before creating the PR. Wait for approval.

9. **Create or update PR**:
   - Try `gh pr create` first
   - If PR already exists, get PR number and use `gh pr edit` to update body
   - Use `--base <base-branch>`
   - Show the PR URL at the end

10. **Important**: the PR body must be passed via HEREDOC for correct formatting:
    ```
    gh pr create --title "title" --body "$(cat <<'EOF'
    body content here
    EOF
    )"
    ```

## Final Thoughts

A good PR description is **short enough to read in 30 seconds**. If the reviewer needs more detail, the code diff is right there. The description should answer "why" and "what changed at a high level" — nothing more.
