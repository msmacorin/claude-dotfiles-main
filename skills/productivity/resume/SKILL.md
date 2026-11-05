---
name: resume
description: Pick up a mission from its last handoff (saved by the "handoff" skill) without preloading the whole document. Pick a mission by slug or issue number, list the open missions of the current repo or of every repo ("/resume all"), or reopen an archived one. Triggers "resume <slug>", "continua de onde parei", "/resume 45", "quais missões estão abertas".
category: productivity
argument-hint: "[slug or issue number | all]"
---

Find the latest handoff for a mission, pull a small preview, and continue — keeping the full document on disk as a lazy reference.

## Pick the mission

Handoffs live in `~/.claude/handoffs/<slug>/latest.md`. Older ones are flat files, `~/.claude/handoffs/<slug>.md`; treat them the same way.

- **Slug or issue number given** → that mission; a number prefix matches (`/resume 45` finds `45-card-fuel-transmission`).
- **`all`** → list open missions of every repo, grouped by the `Repo:` line.
- **No argument** → the open missions of the current repo: handoffs (except `_archive/`) whose `Repo:` line names this repo, newest first. One → resume it. Several → show slug, date and first Summary line, and ask which.
- **Only under `_archive/`** → say the mission was archived (PR merged) and ask whether to reopen it.
- **Nothing found** → list what exists in `~/.claude/handoffs/` and ask which one to resume, or whether to start fresh.

## Extract a preview — don't read the whole file

```bash
awk '/^## Summary/{f=1;next} /^## /{f=0} f' <handoff>
awk '/^## State/{f=1;next} /^## /{f=0} f' <handoff> | head -8
awk '/^## Open questions/{f=1;next} /^## /{f=0} f' <handoff>
awk '/^## Next steps/{f=1;next} /^## /{f=0} f' <handoff> | head -5
awk '/^## Suggested skills/{f=1;next} /^## /{f=0} f' <handoff>
```

A legacy handoff without these headings: read it whole.

Keep the path as a lazy reference: if a later topic plausibly lives in the handoff, grep for it and read only that section.

## Track the active slug

Write the slug (no newline) to `~/.claude/handoffs/.active-resume-slug`. The compaction hook uses it to re-save the handoff after context compaction.

## Orient and continue

- **Mission**: one sentence from Summary.
- **Where we stopped**: one sentence from State.
- **Open questions**: only if any.
- **Next step**: the first item of Next steps.

Invoke the skills listed under Suggested skills. If the mission branch isn't checked out and the next step needs code, `git -C <repo> checkout <branch>`.

If the user's message already says what to do, proceed. Otherwise ask once: *"Sigo daqui?"*

## Notes

- The handoff is a briefing, not ground truth. Check the branch, PR and issues directly when relevant; trust the source and the user over the handoff.
- Don't modify or delete handoff files; older ones stay for history.
