---
name: handoff
description: Save the state of each mission worked on in this session to a short handoff document, so a later session continues it with the "resume" skill. One handoff stream per mission (issue number + slug, e.g. 45-card-fuel-transmission). Runs at dev-task checkpoints (--checkpoint), after context compaction, or when the user says "handoff <slug>", "salva o estado", "vou parar por hoje".
category: productivity
source: https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff
argument-hint: "[slug] [--checkpoint] [focus of the next session]"
---

Write a short handoff with the **state of each mission** touched in this session, so a fresh session can continue it. This is task state, not a knowledge base.

## Which missions

1. **Argument** slug given → that mission only. The rest of the argument (minus `--checkpoint`) is the focus of the next session.
2. Otherwise, **every mission worked on in this session**: the mission ids used for branches or issues in this conversation (dev-task, an explicit `/resume`). One handoff per mission.
3. Session on a mission branch (`<N>-<slug>`) → that branch's mission.
4. Work that belongs to no mission (exploration, discovery on main) → slug = the repo name.
5. Nothing material happened (only reading, a resume with no action) → save nothing and say so. Never create an empty handoff.

Slug = mission id lowercased; drop anything outside `[a-z0-9-_]`. If none can be derived, use `<YYYY-MM-DD>-<topic>` and tell the user which slug you chose.

## Where to save

`~/.claude/handoffs/<slug>/<YYYY-MM-DD-HHmmSS>.md` (local time), then point `latest.md` in the same folder at it (`ln -sfn <file> latest.md`). Create the folder if needed. Never save to the repo or `$TMPDIR`. A legacy flat `~/.claude/handoffs/<slug>.md` stays where it is; new saves go to the folder.

## What to write

Keep it short — under ~60 lines. Reference, don't duplicate: link PRs, issues, commits and files (clickable links). No long code blocks. Redact secrets, tokens and PII.

The `Repo:` line is required and must start with the **main repo's name** (`basename` of the parent of `git rev-parse --git-common-dir`); `resume` matches missions to the repo by it.

```markdown
# <slug> — <YYYY-MM-DD HH:mm>
Repo: <main repo name> · Branch: <mission branch> · PR: <[owner/repo#N](url) or none>

## Summary
One paragraph: what this mission is and where it stands.

## State
- Done this session: ...
- In progress / about to do: ...
- Blockers: ...

## Open questions
- Decisions the user (or the next session) must make.

## Next steps
1. Concrete, ordered. The first one is what resume shows.

## Assumptions
- Judgment calls made without asking.

## Suggested skills
- Skills the next session should invoke (e.g. dev-task, velzon-frontend).

## References
- Issue: ... · PR: ... · Key files: ... · Docs: ...
```

## Durable findings

Durable knowledge (gotchas, non-obvious behavior, "why it's done this way") doesn't go in the handoff. List each one in the report-back under `💡 Para guardar`, with where it fits (auto-memory, the repo's `CLAUDE.md`, or claude-dotfiles `knowledge/`), and offer once to write them.

## Archive finished missions

After saving, check the mission's PR by branch: `gh pr view <mission-branch> --json state -q .state`. If `MERGED`, move the slug folder to `~/.claude/handoffs/_archive/<slug>/` (append `-N` if it exists). An open handoff folder always means work in progress.

## Report back

`--checkpoint`: one line, `💾 Checkpoint <slug> salvo.`

Otherwise, one line per mission:

```
✅ Saved: ~/.claude/handoffs/<slug>/<YYYY-MM-DD-HHmmSS>.md — continue com /resume <slug>
```

Add, when applicable: `📦 Archived: PR merged — <slug> moved to _archive/` and the `💡 Para guardar` list.
