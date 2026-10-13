---
name: feature-discovery
description: Run end-to-end discovery for a feature — from the product problem to a technical implementation plan. Frames the opportunity (product discovery), researches and distills documentation, spikes into the codebase, and synthesizes a written discovery doc with a ready-to-build plan. Use when the user wants to investigate/research a feature before building it — e.g. "faz o discovery dessa feature", "quero investigar/pesquisar antes de codar", "vamos entender esse problema antes", or `/feature-discovery <feature or problem>`. Not for tasks already scoped and ready to implement — for those use dev-task.
argument-hint: "<feature idea, problem statement, or GitHub issue #N>"
---

# Feature Discovery

Orchestrate a full discovery pass for a feature: understand the **problem**
(product side), gather **evidence** (research + docs), map the **technical**
reality (codebase spike), and end with a written discovery doc that hands off
cleanly to implementation. No code is written here — the deliverable is
understanding plus a plan.

This skill is a conductor: it leans on skills and agents that already exist
rather than re-deriving their content. Invoke the referenced product skills
when their phase runs; use the `Explore` and `Plan` agents for the technical
half; finish by handing off to `/dev-task`.

## When NOT to use this

- The feature is already scoped, agreed, and ready to code → go straight to
  `/dev-task`.
- The change is a trivial fix or one-liner → just do it.
- You only need to read one doc/article → use `/knowledge-extract` directly.

## Quick start

`/feature-discovery <feature or problem>`. Run from inside the target repo when
possible (`git rev-parse --show-toplevel`) so the codebase spike has a tree to
explore. If a GitHub issue is given (`#123` or URL), fetch it first for context
with `gh issue view <N> --json number,title,body,labels,parent,subIssues`.

## Phase 0 — Frame the mission

1. **Codename.** Per the user's Asimov's Law #4, every significant initiative
   needs a codename. Ask for one if not given; use it as the discovery slug.
2. **Restate the ask in one paragraph** and confirm it back. Capture: who is
   affected, what outcome the business wants, and what is explicitly out of
   scope. If the ask is thin, grill the user (invoke `grill-me`) — one question
   at a time, each with your recommended answer — until the problem is sharp.
3. Create the discovery doc skeleton at `~/.claude/discovery/<slug>.md` (create
   the dir if missing). It is filled progressively across the phases below and
   is the single source of truth for this discovery. Offer to also drop a copy
   in the repo (`docs/discovery/<slug>.md`) if the user wants it version-tracked.

## Phase 1 — Product discovery (the problem)

Goal: separate the *opportunity* from any presumed solution. Do not let a
solution the user already has in mind short-circuit this.

- Build an **Opportunity Solution Tree**: Outcome → Opportunities → Solutions →
  Experiments. Invoke **`continuous-discovery`** for the OST method, experience
  mapping, and assumption testing.
- If there are real users/stakeholders to talk to, invoke **`mom-test`** for
  interview technique (ask about past behavior, never pitch). If not, say so
  explicitly and mark the resulting nodes as *assumption, unvalidated*.
- For team/vision framing and opportunity assessment, invoke
  **`inspired-product`**.
- Output into the doc: the outcome, the opportunity space, the candidate
  solution(s), and — critically — the **riskiest leap-of-faith assumptions**
  (desirability / viability / feasibility / usability) each solution rests on.

Do not proceed to build recommendations until the riskiest assumptions are
named. Naming an untested assumption is a valid, valuable discovery output.

## Phase 2 — Research & documentation (the evidence)

Gather external evidence for the assumptions and the solution space:

- Prior art, competitor approaches, standards, and API/library docs relevant to
  the candidate solutions.
- Use **`WebSearch`/`WebFetch`** for external sources; when a source is worth
  keeping, run **`/knowledge-extract <source>`** to distill it into structured
  knowledge under the project's `knowledge/` dir and link it from the doc.
- Pull internal context tied to the feature: related GitHub issues/PRs
  (`gh issue list --search`, `gh pr list --search`) and, if the Atlassian tools
  are connected, Confluence docs.

Output into the doc: a short annotated list of sources, each with the one
finding that changes a decision (skip sources that don't).

## Phase 3 — Technical discovery (the codebase)

Now map the solution against the real system. Spawn the **`Explore`** agent
(read-only, fan-out) to answer feasibility questions concretely:

- Where would this live? Which modules, routes, schemas, and boundaries does it
  touch?
- What already exists that can be reused vs. built new?
- What are the constraints, migrations, feature-flag surfaces, and blast radius?
- What breaks or regresses? Where are the seams for safe change?

Output into the doc: integration points (as `file:line` refs), reuse
opportunities, constraints, and a feasibility verdict per candidate solution —
this is what turns a desirability assumption into a buildable shape.

## Phase 4 — Synthesize the plan

- Spawn the **`Plan`** agent to turn the chosen solution + technical findings
  into a step-by-step implementation plan (critical files, ordering, tradeoffs).
- Stress-test the plan by invoking **`grill-me`** on it if any decision is still
  soft.
- Every proposed change must be gated behind a **feature flag** and carry a test
  scenario — flag anything that can't be, per the user's review rules.

## Phase 5 — Deliverable & handoff

Finalize `~/.claude/discovery/<slug>.md` with these sections:

1. **Problem** — outcome, who's affected, out of scope.
2. **Opportunity tree** — the OST (or a text outline of it).
3. **Assumptions** — riskiest first, each marked validated / unvalidated, with
   the test that would validate it.
4. **Evidence** — annotated sources + distilled `knowledge/` links.
5. **Technical findings** — integration points (`file:line`), reuse,
   constraints, feasibility verdict.
6. **Recommendation** — the solution to pursue (or "don't build yet, validate X
   first"), with rationale.
7. **Implementation plan** — the Plan agent's step list, feature flag, tests.

Then present a tight summary to the user and offer the handoff:
- If a GitHub issue exists → offer to update its body with the plan
  (`gh issue edit <N> --body-file`) and run `/dev-task <N>`.
- If not → offer to create it with `/write-issue` (usually a `type:epic` whose
  stories come from the plan), then `/dev-task` on it.

A discovery can legitimately end at "don't build this yet" — that is a
successful outcome, not a failure.

## Skills & agents this orchestrates

| Phase | Uses |
|-------|------|
| 0 Frame | `grill-me` |
| 1 Product | `continuous-discovery`, `mom-test`, `inspired-product` |
| 2 Research | `WebSearch`/`WebFetch`, `knowledge-extract`, `gh`, Atlassian tools (Confluence) |
| 3 Technical | `Explore` agent |
| 4 Plan | `Plan` agent, `grill-me` |
| 5 Handoff | `write-issue`, `dev-task` |
