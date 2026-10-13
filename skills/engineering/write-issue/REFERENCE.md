# Write Issue - Reference

## Creating issues

```bash
gh issue create --title "<title>" --body-file <scratchpad>/issue-<n>.md \
  --label "type:<type>" --label "area:<area>" [--parent <N>]
```

- Prints the issue URL; the number is the last path segment.
- Create parents first so children can use `--parent`.
- `--type` (Issue Types) only works on organization repos; personal repos use
  `type:*` labels.

## Body format for issue forms

GitHub renders an issue-form submission as one `### <label>` heading per
field. Mirror that so manual issues look identical to template ones:

```markdown
### História

Como gestor da loja, quero ... para ...

### Critérios de aceite

- [ ] ...
- [ ] ...

### Notas técnicas

- `src/lib/sellable/vehicle-adapter.ts:42` - ...
```

Omit optional sections that would be empty; never leave `_No response_`.

## Default structures (repo without templates)

| Type  | Sections |
|-------|----------|
| Epic  | Problema / oportunidade · Resultado esperado · Decisões e restrições · Stories planejadas |
| Story | História · Critérios de aceite · Notas técnicas |
| Task  | O que fazer · Escopo (arquivos/módulos) · Definição de pronto |
| Bug   | O que acontece · O que deveria acontecer · Como reproduzir · Ambiente · Contexto extra |

Write section titles in the repo's language.

## Epic with stories in one go

1. Create the epic (its "Stories planejadas" lists titles).
2. Create each story with `--parent <EPIC-N>`.
3. Edit the epic body to turn the list into links (`- #125 ...`); the
   sub-issue panel already tracks progress, so keep the list short.

## Project fields (only when the user asked)

```bash
ITEM_ID=$(gh project item-add <PROJECT-NUMBER> --owner <OWNER> --url <ISSUE-URL> --format json --jq .id)
gh project field-list <PROJECT-NUMBER> --owner <OWNER> --format json   # Priority / Iteration ids
gh project item-edit --id "$ITEM_ID" --project-id <PROJECT-NODE-ID> \
  --field-id <PRIORITY-FIELD-ID> --single-select-option-id <OPTION-ID>
gh project item-edit --id "$ITEM_ID" --project-id <PROJECT-NODE-ID> \
  --field-id <ITERATION-FIELD-ID> --iteration-id <ITERATION-ID>
```

Find the Project linked to the repo as in `dev-task`'s REFERENCE.md. Leave
Status alone - the "Item added to project" workflow sets Backlog.
