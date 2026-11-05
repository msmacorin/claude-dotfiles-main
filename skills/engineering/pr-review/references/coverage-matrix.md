# Flow Coverage Matrix

Mandatory. "Tests look good" is not a review result. The matrix makes coverage a fact you can count.

## 1. List every scenario

For each changed or added function, endpoint, server action, component behavior and migration, one row per path:

- Happy path
- Each branch: `if` / `else`, `switch` cases, ternaries, early returns, `??` / `?.` fallbacks
- Empty, `null`/`undefined`, zero, boundary values (limit − 1, limit, limit + 1)
- Validation rejections (each Zod refinement that matters)
- Error paths: thrown errors, rejected promises, `Result` error variants, external call failures
- Authorization: unauthenticated, wrong role, other tenant's id
- Side effects: DB write, email, queue, cache revalidation, external API
- Feature flag on **and** off
- Each Given/When/Then from the business review

## 2. Map each scenario to its test

| # | Scenario | Code | Test | Discriminates? | Verdict |
|---|---|---|---|---|---|
| 1 | Seller adds 11th photo → rejected | `src/app/api/photos/route.ts:42` | `photos.test.ts` "rejects above limit" | yes | ✅ PASS |
| 2 | Photo limit for other seller's listing | `route.ts:30` | — | — | 🔴 MISSING |
| 3 | Listing without photos renders | `ListingCard.tsx:18` | `ListingCard.test.tsx` "renders" | no — passes on old code | ⚠️ STALE |

**Discriminates?** = would this test **fail** if the change were reverted? Reason it out from the old code (`git show main:<path>`); run the test against the old code only when reasoning can't settle it. A test that passes on both versions doesn't validate the change.

Common non-discriminating tests: asserting only that a function was called, snapshot tests that were regenerated, mocks that return the expected value regardless of input, assertions on the mock instead of the result, `toBeDefined()` on something always defined.

## 3. Verdicts

- ✅ **PASS** — a test exists and discriminates.
- ⚠️ **STALE** — a test exists but would pass without the change.
- 🔴 **MISSING** — no test.
- ➖ **N/A** — not testable at this level, with the reason (e.g. pure styling); never for a behavior.

Any 🔴 or ⚠️ on a behavior is **BLOCKING** (`T1`/`T3`). An incomplete matrix is itself BLOCKING.

Summary line, used in the report: `Flow coverage: <N> casos · <M> cobertos` — `M` counts ✅ only.
