---
name: segunda-opiniao
description: Take any subject - a design, a plan, a diff, a tricky decision - to external LLMs (OpenAI Codex and Google Gemini) via their local CLIs, then synthesize a single verdict comparing where they agree, where they diverge, and your own take. Two modes - general ("leva isso pros dois", "pede uma segunda opiniao", "o que o gpt e o gemini acham") and review ("passa o diff pro conselho", review of a branch/diff vs a base). Resilient - uses whichever provider is authenticated. Invoke with /segunda-opiniao <subject> or /segunda-opiniao review [base].
---

# Segunda Opinião

Consult external LLMs (**Codex / OpenAI** and **Gemini / Google**) through their
local CLIs and return **one synthesized answer**, not two raw dumps. This is the
single place that knows *how* to call them - other skills (e.g. `dev-task`) call
this skill instead of re-implementing the CLI mechanics (DRY - Lei #6).

## Quick start

- `/segunda-opiniao <subject>` - general consult on a question, plan, or design.
- `/segunda-opiniao review [base]` - review the current diff vs `base` (default
  `main`) with both models.

## Providers

| Provider | CLI | Clean invocation |
|----------|-----|------------------|
| **Codex** (OpenAI, `gpt-5.4`) | `codex` | `codex exec "PROMPT" -o <file> >/dev/null 2>&1 && cat <file>` |
| **Gemini** (Google) | `gemini` | `gemini -p "PROMPT" 2>/dev/null` |

`gemini` prints cosmetic warnings to **stderr** (256-color, ripgrep) - always
`2>/dev/null`. `codex exec` prints a header block; `--output-last-message`
(`-o <file>`) writes **only** the final answer, so use that instead of parsing.

**Resilience:** a provider may be unauthenticated (`gemini` needs
`GEMINI_API_KEY` or Google login; `codex` needs `codex login`). If a call fails
with an auth/credential error, **do not abort** - continue with whoever
answered and tell the user which provider was skipped and why. Never invent an
answer for a provider that did not run.

## Workflow

1. **Frame the ask.** These CLIs do **not** see this conversation. Build a
   self-contained prompt: the concrete question + the minimum context needed
   (relevant code, the decision, constraints). Ask each for a **direct opinion
   with reasoning**, not a mirror of the question.

2. **Fan out in parallel.** Launch both CLIs in the **same turn** (parallel Bash
   calls) - they are slow (tens of seconds). Write prompts/outputs to the
   scratchpad dir, not `/tmp` hardcoded.
   - Codex: `codex exec "$PROMPT" -o <scratch>/codex.txt >/dev/null 2>&1 && cat <scratch>/codex.txt`
   - Gemini: `gemini -p "$PROMPT" 2>/dev/null`
   - For long prompts, write the prompt to a file and pipe it in via stdin
     (both CLIs accept stdin) to avoid shell-escaping pain.

3. **Optional: give them different lenses.** Two identical prompts often echo.
   When it adds signal, ask each a slanted question - e.g. Codex for
   correctness/edge cases, Gemini for alternative approaches/design - and say so
   in the synthesis.

4. **Synthesize.** Present **one** answer, in Portuguese:
   - **Concordam:** points both landed on (highest confidence).
   - **Divergem:** where they disagree, with each position attributed.
   - **Meu veredito:** your own call, weighing both against the actual code/context.
   Attribute claims to their source. Keep the raw outputs available but lead with
   the synthesis, not the transcripts.

## Review mode - `/segunda-opiniao review [base]`

For reviewing a branch's diff (default base `main`):

1. **Codex** has a native reviewer - prefer it over a hand-rolled prompt:
   - `codex review --base <base>` (diff vs a branch), or `--uncommitted`
     (staged+unstaged+untracked), or `--commit <sha>`.
2. **Gemini** has no review subcommand - feed it the diff explicitly:
   - `git -C <repo> diff <base>...HEAD > <scratch>/diff.patch`
   - prompt Gemini to review that patch for bugs, edge cases, and simplifications.
3. **Synthesize** as above, ranked most-severe first. This composes with - does
   **not** replace - `/code-review`: run the built-in `/code-review` for your own
   findings, then this for external corroboration.

## Notes

- The built-in `/code-review` is compiled into the Claude Code binary and is
  **not** editable. Integration happens by *calling* this skill as an extra
  step (that is how `dev-task` uses `/code-review` too), never by patching it.
- Consulting two external models costs latency and tokens - keep it **opt-in**,
  for genuinely hard calls, not every question.
