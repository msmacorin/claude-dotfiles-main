---
name: resume
description: Resume a previous conversation from a handoff document saved by the "handoff" skill. Use when the user says "resume <slug>" or wants to continue work saved under a slug.
argument-hint: "<slug>"
---

Resume work from a handoff document previously saved by the "handoff" skill.

## Loading the handoff

The argument is the slug. Sanitize it the same way "handoff" does (lowercase alphanumeric and hyphens) and read `~/.claude/handoffs/<slug>.md`.

If no slug was given, or the file doesn't exist, list the `.md` files in `~/.claude/handoffs/` and ask the user which one to resume (or whether to start fresh).

## Resuming

Once loaded, treat the handoff document as your primary context for this conversation:

- Briefly summarize back to the user what you understood from the handoff and what you're about to do next, before starting work.
- Follow the "suggested skills" section - invoke any skills it recommends.
- Follow references to other artifacts (PRDs, plans, issues, diffs) mentioned in the document to refresh context as needed.

The handoff file is left in place after resuming, so it can be reused if the session is interrupted again.

## Tracking the active slug

After successfully loading a handoff, write the slug to `~/.claude/handoffs/.active-resume-slug` (create the file, or overwrite if it already exists). This allows automatic re-saving on context compaction.

Use the Write tool or a Bash command to write the slug (just the slug text, no newline needed) to that path.
