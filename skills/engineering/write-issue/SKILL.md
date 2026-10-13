---
name: write-issue
description: Write well-structured GitHub issues (Epic, Story, Task, or Bug) from a loose idea, bug report, or plan - following the repo's issue templates, labels, and sub-issue hierarchy - and file them on the repo's linked GitHub Project. Drafts first, creates only after approval. Does not implement anything. Use when the user wants to register work without starting it - e.g. "cria uma issue pra isso", "abre um bug", "escreve as stories desse épico", "registra essa task no board", or `/write-issue <description>`. For developing an issue end-to-end use dev-task; for investigating a feature first use feature-discovery.
argument-hint: "<idea, bug report, or plan> [--parent #N]"
---

# Write Issue

Turn a loose description into GitHub issues that someone (usually
`/dev-task`) can pick up without re-asking questions. Draft -> approve ->
create. No code changes.

## Quick start

`/write-issue <text>` from inside the target repo. Optional `--parent #N` to
file as sub-issue(s) of an existing epic/story. If no text is given, ask what
needs to be registered.

## Workflow

1. **Load the repo's conventions**
   - `gh repo view --json nameWithOwner` -> `OWNER/REPO`.
   - Templates: read `.github/ISSUE_TEMPLATE/*.yml` (issue forms). Each
     form's `body[].attributes.label` becomes a `### <label>` section in the
     issue body, in the same order; `labels:` gives the type label; `title:`
     gives any title prefix (e.g. `[Epic] `). No templates -> use the
     defaults in [REFERENCE.md](REFERENCE.md).
   - Labels: `gh label list --limit 100`. Use only `type:*` / `area:*` labels
     that exist - never invent taxonomy; if a needed one is missing, ask.
   - If `--parent` was given: `gh issue view <N> --json title,body,labels,subIssues`
     to inherit context and avoid duplicating existing children.

2. **Classify** - pick the type from the text (bug report -> Bug, user-facing
   outcome -> Story, technical chore -> Task, multi-story initiative -> Epic).
   If ambiguous, ask with a recommendation. One request may yield several
   issues (an epic plus its stories, or a story plus tasks).

3. **Fill the gaps** - only ask what you can't find. Explore the codebase
   first for technical notes (affected modules as `file:line`, existing code to
   reuse). For each still-missing required field, ask one question at a time
   with a recommended answer. Don't invent reproduction steps or acceptance
   criteria the user hasn't implied - mark them as open questions instead.

4. **Check for duplicates** - `gh issue list --state open --search "<keywords>"`.
   If something close exists, show it and ask: update it, link as related, or
   create anyway.

5. **Draft** - write every issue following the quality rules below and show
   the full draft: title, labels, parent, body. Iterate until approved. This
   is the only approval gate.

6. **Create** - per [REFERENCE.md](REFERENCE.md): write each body to a file in
   the session scratchpad, `gh issue create --body-file ... --label ...
   [--parent N]`, parents before children. The Project's auto-add workflow
   places them in Backlog; set Priority/Iteration only if the user gave them.

7. **Report** - list created issues (number, title, link, parent) and offer
   the next step: `/dev-task <N>` for something ready to build, or
   `/feature-discovery` if the issue exposed open questions.

## Quality rules

- **Title**: short, specific, imperative or outcome-phrased, in the repo's
  language (`Permitir venda de veículo com troca`, not `Veículos`). No type
  word in the title unless the template prefixes it.
- **Problem before solution**: Epics and Stories describe the outcome and who
  benefits; implementation ideas go under technical notes, never in the
  story statement.
- **Acceptance criteria are testable**: checklist items an observer can verify
  (`- [ ] Ao vender, o veículo sai da lista de disponíveis`), including at
  least one edge/negative case. No "funciona corretamente".
- **Bugs are reproducible**: actual vs expected, numbered steps, environment.
  Missing info -> explicit `**Em aberto:**` line, not a guess.
- **Tasks are scoped**: name the files/modules touched so sibling tasks don't
  overlap (this is what lets `/dev-task` sequence them).
- **Small enough**: a Story should fit one PR. If it doesn't, split it, or
  promote it to an Epic with stories.
- **Link, don't repeat**: reference related issues/PRs/discovery docs by link
  instead of copying their content.

## Failure handling

Missing labels/templates/Project, `gh` auth errors, or a duplicate the user
hasn't resolved stop the flow - report and ask. Never create issues before
the draft is approved.
