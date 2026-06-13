---
name: handoff
description: Compact the current conversation into a slug-named handoff document, so it can be resumed later with the "resume" skill. Use when the user says "handoff <slug>" or wants to save progress to pick up again later.
argument-hint: "<slug> [optional: what the next session will focus on]"
---

_Source: [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff)_

Write a handoff document summarising the current conversation so a fresh agent (or the same agent, in a later session) can continue the work.

## Slug and save location

The first word of the arguments is the slug - a short identifier (e.g. "ops"). Sanitize it to lowercase alphanumeric characters and hyphens.

Save the document to `~/.claude/handoffs/<slug>.md`, creating the directory if it doesn't exist. If a file already exists at that path, overwrite it.

If no arguments are given, derive a slug from today's date and the main topic (e.g. "2026-06-13-some-topic") and make sure to tell the user the slug you chose.

Any words after the slug describe what the next session will focus on - tailor the doc accordingly.

## Document contents

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

## After saving

Tell the user the slug and that they can continue this work later with `/resume <slug>`.
