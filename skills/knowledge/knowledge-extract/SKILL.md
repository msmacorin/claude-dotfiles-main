---
name: knowledge-extract
description: Extract structured expert knowledge (5-layer DNA) from any content — URL, file, or pasted text — and save it as a markdown file in the current project's knowledge/ directory. Use when the user wants to distill expertise from an article, book, podcast transcript, video transcript, or any other material into a reusable structured format. Trigger: /knowledge-extract [source].
---

# Knowledge Extract

Extract the cognitive DNA from expert content and save it to the current project.

## Quick start

`/knowledge-extract <source>` where `<source>` is a URL, a file path, or omitted
(you'll paste the text directly). Run from inside the target project — the output
goes to `./knowledge/` relative to the current directory.

## Workflow

1. **Get the content**
   - URL → `WebFetch` it; grab full text.
   - File path → `Read` it.
   - No arg → ask the user to paste the text now, then proceed.

2. **Identify the source**
   Ask (or infer from content) two things:
   - **Expert / Source name** — who or what this is (e.g. "Benjamin Graham",
     "Acquired Podcast – Ep 312", "The Intelligent Investor Ch. 8").
   - **Domain** — what field this belongs to (e.g. `investing`, `product`,
     `engineering`, `marketing`). If obvious from content, don't ask — infer.

3. **Extract the 5-layer DNA**

   Read the full content carefully, then extract:

   ### Layer 1 — Philosophies
   Core beliefs, worldviews, and first principles. These are the "why" behind
   everything else. Look for: what the expert holds as fundamentally true,
   what they would never compromise on, their relationship with risk/uncertainty.

   ### Layer 2 — Mental Models
   Conceptual lenses used to reason about situations. Look for: analogies,
   metaphors, cross-domain thinking, named models ("Mr. Market", "circle of
   competence"). Each model should be 2–4 sentences: what it is + when to apply.

   ### Layer 3 — Heuristics
   Rules of thumb, filters, and shortcuts. Practical and fast — things the expert
   uses to quickly evaluate or discard options. Format as bullet list.
   Look for: "I never…", "I always…", "the first thing I check is…", thresholds
   and ratios, simple yes/no tests.

   ### Layer 4 — Frameworks
   Structured multi-step approaches for analyzing specific situations.
   Heavier than heuristics — frameworks require deliberate application.
   Look for: checklists, scoring systems, named processes, decision matrices.

   ### Layer 5 — Methodologies
   End-to-end repeatable workflows. The most process-like layer — could be
   turned into an SOP. Look for: step-by-step sequences, if-then logic,
   iteration patterns.

4. **Key Quotes**
   Pull 3–8 quotes that capture the expert's voice and are directly useful
   (not decorative). Each quote must be verbatim from the source.

5. **Synthesis**
   One paragraph (5–8 sentences) that captures what makes this expert's thinking
   *distinctive* — what separates their approach from conventional wisdom.

6. **Determine output path**
   - Check if `./knowledge/` exists in the project root.
     - If yes, use it.
     - If no, create `./knowledge/`.
   - Subdirectory: `./knowledge/experts/`.
   - Filename: kebab-case slug of the expert/source name, e.g.
     `benjamin-graham.md`, `acquired-ep312-nvidia.md`.
   - If the file already exists, read it first and **merge** new content rather
     than overwriting — add a new dated section at the bottom.

7. **Write the file** using this template:

```markdown
# {Expert / Source Name} — DNA Extract

**Source**: {URL or file path or "pasted text"}
**Extracted**: {YYYY-MM-DD}
**Type**: {book | article | podcast | video | transcript | other}
**Domain**: {domain}

---

## Philosophies

{content}

## Mental Models

{content}

## Heuristics

{bullet list}

## Frameworks

{content}

## Methodologies

{content}

## Key Quotes

> "{quote}" — {attribution if different from main source}

## Synthesis

{paragraph}
```

8. **Report back**
   Tell the user: file path written, word count of extracted content, and one
   sentence on the most surprising or distinctive thing found in the extraction.

## Quality rules

- Extraction must be **source-grounded**: every item must be traceable to
  something actually said or written in the source. Do not extrapolate or add
  general knowledge not present in the content.
- Layers must be **distinct**: if something fits in multiple layers, put it in
  the most specific one only.
- Be **dense, not exhaustive**: 3 sharp heuristics beat 12 generic ones. Cut
  anything a generalist would already know.
- Use the expert's **own language** where possible — their vocabulary is part
  of the knowledge.
