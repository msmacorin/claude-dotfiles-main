---
name: typescript-expert
description: Enforces senior-level strict TypeScript practices across the full stack (frontend and backend) - no `any`, `unknown` with type guards instead of assertions, branded ID types, Zod-based runtime validation with inferred types, explicit return types, discriminated-union error handling, and DRY utility types. Use when writing, reviewing, or refactoring TypeScript code (React components, API route handlers, services, shared types/DTOs).
---

# TypeScript Expert (Full Stack)

## Goal

Every piece of TypeScript code, frontend or backend, should meet senior-level
strict type safety standards: no type leaks, no duplication.

## Prerequisite: Strict tsconfig

These rules only work if the compiler enforces them. `tsconfig.json` must have
at least:

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true
  }
}
```

## Strict Typing Rules

- **Never use `any`**. No exceptions. If a type is dynamic or uncertain, use
  `unknown` combined with type guards or type narrowing.
- **Avoid type assertions (`as Type`)**. Prefer runtime validation or inferred
  types. Only use assertions in tests or when interacting with untyped
  external APIs.
- **Use utility types**. Maximize generics, `Omit`, `Pick`, `Partial`,
  `ReturnType`, and `Record` to keep code DRY.
- **Brand entity IDs**. When multiple entities share a primitive ID type
  (e.g., `storeId`, `productId`, `userId` all being `string`), use nominal
  ("branded") types so the compiler rejects passing the wrong ID where
  another is expected:

  ```typescript
  type StoreId = string & { readonly __brand: "StoreId" };
  type ProductId = string & { readonly __brand: "ProductId" };

  function asProductId(id: string): ProductId {
    return id as ProductId; // the one sanctioned place for this assertion
  }
  ```

  Especially valuable in multi-tenant schemas where every query is scoped by
  `storeId` - a mixed-up ID becomes a compile error instead of a data leak.

## Backend Patterns

- **Validate at the boundary**: every API/HTTP input must go through a
  runtime schema (e.g., Zod). The static TS type should be inferred from the
  schema (`z.infer<typeof schema>`).
- **Explicit return types**: always type the return values of controllers,
  services, middlewares, and handlers to avoid incorrect promise inference.
- **Safe error handling**: replace generic thrown exceptions with
  discriminated-union result types
  (e.g., `type Result<T, E> = { ok: true, value: T } | { ok: false, error: E }`).

## Frontend Patterns

- **Type components and props strictly**: declare component props
  explicitly (e.g., `React.FC` or explicit prop types).
- **Native event types**: use the ecosystem's native types for forms
  (e.g., `React.FormEvent`, `React.ChangeEvent`).
- **End-to-end sync**: when a backend contract changes, immediately check the
  shared type/DTO files that affect the frontend's API calls.

## Quick Example: End-to-End Type Flow

```typescript
// 1. Schema is the source of truth - type is inferred, never duplicated
const createProductSchema = z.object({
  name: z.string().min(1),
  storeId: z.string(),
  price: z.number().positive(),
});

// 2. Handler: validate, return a discriminated union, type the return
type CreateProductResult = Result<{ id: ProductId }, { message: string }>;

export async function createProduct(
  input: unknown
): Promise<CreateProductResult> {
  const parsed = createProductSchema.safeParse(input);
  if (!parsed.success) {
    return { ok: false, error: { message: parsed.error.message } };
  }

  const product = await db.product.create({ data: parsed.data });
  return { ok: true, value: { id: asProductId(product.id) } };
}

// 3. Frontend: narrow on `ok` before reading `value`/`error`
const result = await createProduct(formData);
if (!result.ok) {
  showError(result.error.message);
} else {
  redirectTo(`/products/${result.value.id}`);
}
```
