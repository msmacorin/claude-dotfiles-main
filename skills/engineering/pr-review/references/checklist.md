# Technical checklist

Evaluate every group that applies to the change. Record each failure with `path:line` and its ID. Local rules (`CLAUDE.md`, `AGENTS.md`, `README.md` conventions, lint config, repo skills) win on conflict — cite them when a finding relies on them.

## Z — PR description vs code

| # | Check | Severity |
|---|---|---|
| Z1 | Description exists and explains what and why (PR mode) | WARNING |
| Z2 | Every claim in the description is implemented | BLOCKING |
| Z3 | No behavior change in code that the description doesn't mention | BLOCKING |
| Z4 | Tests validate every behavior the description states | BLOCKING |
| Z5 | Every added or changed function/endpoint has coverage (matrix) | BLOCKING |

## T — Tests

| # | Check | Severity |
|---|---|---|
| T1 | Every changed behavior has a test (matrix has no 🔴) | BLOCKING |
| T2 | Edge cases, negative paths and regressions covered, not just the happy path | BLOCKING |
| T3 | Each behavioral change has a discriminating test (matrix has no ⚠️) | BLOCKING |
| T4 | Pre-existing tests touched by the change still test something (not green by coincidence, not weakened to pass) | BLOCKING |
| T5 | Flag on and flag off both tested | BLOCKING |
| T6 | Tests assert outcomes (returned data, DB state, rendered output, HTTP status), not just that a mock was called; mocks don't hide the logic under test | WARNING |
| T7 | No `.only`, `.skip`, `it.todo` left behind; no commented-out tests | BLOCKING |
| T8 | Deterministic: time faked (`vi.useFakeTimers`/injected clock), no reliance on order, randomness or network | WARNING |
| T9 | Test names describe behavior (Given/When/Then style), no ticket ids | SUGGESTION |

## S — Safety

| # | Check | Severity |
|---|---|---|
| S1 | Behavior change with production impact behind a feature flag, or an explicit, specific reason why not | BLOCKING |
| S2 | Rollback is possible: revert or flag off; migrations reversible or additive | BLOCKING |
| S3 | AuthN/AuthZ enforced server-side at every new entry point (route handler, server action, API) using the session, not client data | BLOCKING |
| S4 | Every query scoped by tenant/owner (see business R8) | BLOCKING |
| S5 | Every external input validated at the boundary with a runtime schema (Zod), type inferred from it | BLOCKING |
| S6 | No secrets, tokens, password hashes or unnecessary PII in responses, logs, client bundles or error messages | BLOCKING |
| S7 | Migration safe on existing data: no destructive change without backfill, nullable/default for new columns, safe while old and new code run side by side | BLOCKING |
| S8 | Public or unauthenticated endpoints have abuse protection where it matters (rate limit, size limits, enumeration) | WARNING |
| S9 | Dependencies added are needed, maintained and not duplicating an existing one | WARNING |

## E — Errors

| # | Check | Severity |
|---|---|---|
| E1 | No swallowed errors: empty `catch`, `catch` that only logs and continues as if it succeeded, `.catch(() => {})` | BLOCKING |
| E2 | Expected domain failures returned as typed results (discriminated union), not thrown strings | WARNING |
| E3 | Multi-step writes atomic (transaction) or explicitly compensated; no half-written state on failure | BLOCKING |
| E4 | No floating promises (missing `await`, unhandled rejection in handlers/effects) | BLOCKING |
| E5 | Re-thrown errors keep the cause (`new Error(msg, { cause })`) and context | WARNING |
| E6 | User-facing errors are actionable and don't expose internals | WARNING |

## TS — TypeScript (details in the `typescript-expert` skill)

| # | Check | Severity |
|---|---|---|
| TS1 | No `any` (explicit or leaked from untyped libs) | BLOCKING |
| TS2 | No `as` assertions or non-null `!` outside tests and sanctioned brand constructors; narrow with guards or schemas instead | WARNING |
| TS3 | Explicit return types on exported functions, handlers, services | WARNING |
| TS4 | Exhaustive `switch` over unions (`never` check); new union members handled everywhere | BLOCKING |
| TS5 | Types derived, not duplicated (`z.infer`, Prisma types, `Pick`/`Omit`); shared DTO updated on both sides | WARNING |
| TS6 | Indexed access handled (`noUncheckedIndexedAccess`): `arr[0]` may be `undefined` | WARNING |
| TS7 | Entity ids that can be mixed up are branded | SUGGESTION |
| TS8 | No `@ts-ignore` / `@ts-expect-error` / `eslint-disable` without a reason comment | WARNING |

## W — Web (React / Next.js)

Check the repo's framework version first: if `AGENTS.md`/`CLAUDE.md` says the framework changed (e.g. Next.js 16), verify suspect APIs against the docs it points to (`node_modules/next/dist/docs/`) before flagging or approving them.

| # | Check | Severity |
|---|---|---|
| W1 | Server/client boundary right: server-only code and secrets never imported into `"use client"` modules; `server-only` where it applies | BLOCKING |
| W2 | Data freshness: mutations revalidate/invalidate what they change; caching of per-user data never shared across users | BLOCKING |
| W3 | Loading, error and empty states exist for new async UI | WARNING |
| W4 | Hooks: correct dependency arrays, no state updates after unmount, no race between overlapping fetches | WARNING |
| W5 | No hydration mismatch (dates, locale, random, `window` during render) | WARNING |
| W6 | Forms: client and server share the same schema; server re-validates; double submit prevented | BLOCKING |
| W7 | Public pages: real HTTP status for not-found/redirects (check what the rendering mode actually returns — e.g. streaming/PPR answers 200), metadata/canonical correct, no private data rendered | BLOCKING if wrong status or data leak, else WARNING |
| W8 | Accessibility basics: labels, alt text, keyboard reachable controls, contrast via the design system | WARNING |
| W9 | UI follows the repo's design system and conventions (its README or UI skill) | WARNING |

## C — Contracts between services

Applies when the PR changes an API others consume, or consumes another service's API.

| # | Check | Severity |
|---|---|---|
| C1 | Response/request shape changes are backward compatible, or every consumer is updated and the deploy order is stated | BLOCKING |
| C2 | Consumer validates the upstream response at its boundary (schema), and handles errors, timeouts and empty results | BLOCKING |
| C3 | Fields exposed publicly are intended to be public (no internal ids, PII or moderation data leaking through a public endpoint) | BLOCKING |
| C4 | Pagination, filters and sort semantics documented and consistent between producer and consumer | WARNING |

## D — Data access

| # | Check | Severity |
|---|---|---|
| D1 | No N+1: queries in loops replaced by `include`/`in`/batching | WARNING |
| D2 | New query patterns backed by an index; uniqueness enforced by a constraint, not only a pre-check | WARNING |
| D3 | Selects only needed fields (no full user row with hash/tokens sent onward) | BLOCKING if sensitive, else SUGGESTION |
| D4 | Lists paginated or bounded | WARNING |
| D5 | Schema change has its migration committed, matching the model | BLOCKING |

## Q — Code quality

| # | Check | Severity |
|---|---|---|
| Q1 | No dead code, commented-out code, debug `console.log` | WARNING |
| Q2 | No magic numbers or strings for business rules — named constant in one place | WARNING |
| Q3 | Reuses existing utilities/components instead of re-implementing them | WARNING |
| Q4 | Functions focused; names say what they do; no WHAT-comments, only non-obvious WHY | SUGGESTION |
| Q5 | Lint, format and type-check pass (CI or local run) | BLOCKING |
