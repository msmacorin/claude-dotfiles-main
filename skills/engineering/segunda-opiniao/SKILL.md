---
name: segunda-opiniao
description: Take any subject - a design, a plan, a file, a diff, a tricky decision - to external LLMs (OpenAI Codex and Google Gemini) via their local CLIs, then synthesize a single verdict comparing where they agree, where they diverge, what's new, and your own take. Three modes - free question ("leva isso pros dois", "pede uma segunda opinião", "o que o gpt e o gemini acham"), file/plan review, and diff review ("passa o diff pro conselho", review of a branch vs a base). Resilient - uses whichever provider is authenticated. Invoke with /segunda-opiniao <subject> or /segunda-opiniao review [base].
category: quality
---

# Segunda Opinião

Consult **Codex** (OpenAI) and **Gemini** (Google) through their local CLIs as independent reviewers, and return **one synthesized answer**, not raw dumps. This is the single place that knows how to call them — other skills (e.g. `dev-task`) call this skill instead of re-implementing the CLI mechanics.

It is an extra input, never the final word and never a substitute for human review. Two external models cost latency and tokens: keep it for genuinely hard calls.

## Modes

Pick the mode from the request; ask only if genuinely ambiguous.

1. **Free question** — the user's question plus the context already discussed, summarized in 3–5 lines (not the whole conversation).
2. **File / plan** — confirm the file exists with `Read`, then pass its **path** and run the CLI with the repo as working dir, so the model reads it (and related files) itself instead of getting it pasted.
3. **Diff review** (`/segunda-opiniao review [base]`, default `main`) — Codex uses its native reviewer; Gemini gets the patch as a file via stdin. Diff over ~500 lines → warn the user and offer to focus on specific files. This composes with the built-in `/code-review` (not editable — integrate by calling this skill), it doesn't replace it.

## Framing

The CLIs don't see this conversation. Every prompt is self-contained and says it is an independent second opinion, not an implementation request:

> "Você está sendo consultado para dar uma segunda opinião técnica, independente, sobre o que segue. Não edite nada; analise e responda com sua avaliação honesta, incluindo discordâncias. Contexto: <...>"

When it adds signal, give each a different lens (e.g. Codex on correctness/edge cases, Gemini on alternative designs) and say so in the synthesis. Don't impose the `/code-review` checklist — the value is an independent view.

## Invocation

Launch both in the **same turn** (parallel Bash calls) with a high timeout (e.g. 300000 ms). Prompts and outputs go to the session scratchpad dir. Read-only always: this skill never edits files or runs commands with side effects.

| Provider | Command |
|---|---|
| Codex — question / file | `codex exec -s read-only --skip-git-repo-check -C <repo-or-cwd> -o <scratch>/codex.md "<prompt>"`, then read `<scratch>/codex.md` |
| Codex — diff | `codex review --base <base>` (or `--uncommitted`, `--commit <sha>`), run from the repo |
| Gemini — question / file | `gemini -p "<prompt>" 2>/dev/null`, run from the repo |
| Gemini — diff | `git -C <repo> diff <base>...HEAD > <scratch>/diff.patch`, then `gemini -p "<review prompt>" < <scratch>/diff.patch 2>/dev/null` |

- `-o` writes only Codex's final answer — read that file, don't parse stdout. Never `-s workspace-write` or `danger-full-access`.
- `gemini` prints cosmetic warnings to stderr: always `2>/dev/null`. **Never inline a patch** in `-p "...$(cat patch)..."` — it hangs; use stdin. Long prompts: write them to a file and pipe via stdin.
- Model: use the CLI's configured default. If Codex refuses the model (`not supported when using Codex with a ChatGPT account`), don't try other model names — that provider is skipped.

## Resilience

A provider may be unauthenticated (`codex login`; `gemini` needs Google login or `GEMINI_API_KEY`), refuse the model, or hang. Don't abort and don't work around a login: continue with whoever answered and say which provider was skipped and why. Neither answered → say so and rely on local verification (type-check, tests, lint). Never invent an answer for a provider that didn't run.

## Synthesis

In Portuguese, attributing every claim to its source:

```markdown
## Segunda opinião (Codex + Gemini)

**Concordam**: points both landed on (highest confidence).
**Divergem**: where they disagree, each position attributed — the most valuable part.
**Pontos novos**: things neither this conversation nor the other model had considered.
**Meu veredito**: your own call, weighing both against the actual code and context.
```

Diff review: rank findings most-severe first, with `path:line`. If they add nothing and agree with the prior analysis, say so in one line — don't inflate the sections. Keep the raw outputs in the scratchpad; lead with the synthesis.
