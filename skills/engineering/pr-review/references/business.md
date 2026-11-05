# Business review

Most production bugs that tests don't catch are not logic slips — they are the code doing something *coherent* that the product didn't want. This lens finds them. Run it before the technical checklist, with the intended behavior written down first.

## 1. Load the intended behavior

Gather, in order, and note which ones exist:

| Source | Where | What you extract |
|---|---|---|
| Linked issue(s) | `closingIssuesReferences`, `Closes #N` in the body, branch name `<N>-<slug>` → `gh issue view <N> --json title,body,labels,comments` | Problem, ACs, out-of-scope notes |
| Parent story / epic | `gh issue view <N> --json parent` | The bigger rule this change is a piece of |
| Discovery / PRD | `~/.claude/discovery/<mission>.md`, the repo's `docs/`, links in the issue | Decisions, rejected options, edge cases already discussed |
| Repo conventions | `CLAUDE.md`, `README.md`, domain docs, `knowledge/domain/glossary/index.md` | Domain terms, invariants, "we always do X" |
| Issue comments, PR description | — | Late scope changes, promises made to the reviewer |
| Existing code | the same rule elsewhere (other endpoints, admin, seed, public API) | How the product already behaves |

Then write the **expected behaviors** as short Given/When/Then lines. This is the spec the code is judged against. Nothing found → say "business review limited: no issue/ACs" at the top and list the behaviors you inferred as `assumed`.

## 2. AC traceability

For every AC and every expected behavior: `AC → code location → test`.

| # | Check | Severity |
|---|---|---|
| R1 | Every AC is implemented | BLOCKING |
| R2 | Every AC has a test that exercises it end to end (not only a unit of it) | BLOCKING |
| R3 | No behavior beyond the ACs that a user would notice (scope creep, undocumented rule) | BLOCKING if user-visible, else WARNING |
| R4 | The code matches the AC's *meaning*, not just its words (e.g. "até 10 fotos" = 10 allowed, 11 rejected; who counts, when) | BLOCKING |

## 3. Domain-invariant questions

Ask each question that applies to the change. A "no" or "unclear" is a finding; an answer that needs a product call goes to "Precisa de você".

**Money and numbers (R5)**
- Stored and computed as integer cents or a decimal type, never float? Rounding rule explicit and consistent with the rest of the product?
- Negative, zero and very large values handled? Totals equal the sum of their parts after discounts, fees, refunds?
- Display formatted for the locale (`pt-BR`, `R$`), and parsing user input accepts the local format?

**Quantities, stock, limits (R6)**
- Can a count go negative or above its limit? Is the limit enforced on the server, not only in the UI?
- Two concurrent requests (double click, two tabs, retry): can both pass the check? Needs a transaction, a unique constraint or a conditional update?

**State and lifecycle (R7)**
- Which states can the entity be in, and is every transition this code allows valid? Terminal states really terminal?
- What happens to children, listings, public pages when the parent is deleted, archived, unpublished or expires?
- Soft-deleted / draft / unpublished data never leaks into public pages, search, counts or the public API?

**Tenancy, ownership and permissions (R8)**
- Every read and write scoped by the tenant/owner id taken from the session, not from the request body or URL? (IDOR)
- Role checks on the server for every entry point (route handler, server action, API), not just a hidden button?
- An admin or support path doesn't bypass a rule that should still apply?

**Time (R9)**
- "Today", "this month", expiry and deadlines computed in the right timezone (user's / `America/Sao_Paulo`), not server UTC? Date boundaries and DST?
- Stored as UTC instants; date-only values not shifted by timezone conversion?

**Idempotency and side effects (R10)**
- Retried request, duplicate webhook, re-run job, double submit: does it create duplicates or charge/send twice?
- Emails, notifications, external calls happen only after the write succeeds, and not on rollback?

**Consistency across entry points (R11)**
- The same rule enforced everywhere the data can be written: form, API, server action, admin, import, seed, public API, background job? A rule in one place only is a bypass.
- Validation shared (one Zod schema) between client and server?

**Existing data (R12)**
- Rows created before this change: new required field, new default, new rule — do they still load, display and pass validation? Backfill needed?
- Migration and deploy order: is the code safe while the migration is running, and after it, before every client has reloaded?

**What the user sees (R13)**
- Error and empty states say what happened and what to do, in the product's language and tone? i18n keys exist for every new string?
- The UI and the API agree (a limit shown as 10 but enforced as 12, a field optional on screen but required in the API)?

## 4. Severity for business findings

| Finding | Severity |
|---|---|
| AC not implemented or implemented with a different meaning | BLOCKING |
| Invariant violated (money wrong, data leak across tenants, limit bypassable, duplicate charge) | BLOCKING |
| Rule enforced in only some entry points | BLOCKING if reachable, else WARNING |
| Behavior unspecified and the code picked one answer | "Precisa de você" with the options and a recommendation |
| Copy / formatting / minor UX mismatch | WARNING or SUGGESTION |
