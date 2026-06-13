# Jira Dev - Atlassian Reference

Tool names below are the `mcp__atlassian__*` MCP tools.

## Fetching & classifying

- `getJiraIssue(issueIdOrKey)` -> `fields.issuetype.name` (Epic/Story/Task/
  Bug/Sub-task...), `fields.description` (ADF), `fields.project.key`,
  `fields.subtasks`, `fields.parent`.
- To find an Epic's children: try `searchJiraIssuesUsingJql('parent =
  <EPIC-KEY>')` first (team-managed projects use the `parent` field); if
  empty, try `'"Epic Link" = <EPIC-KEY>'` (company-managed projects).

## Issue type discovery

- `getJiraProjectIssueTypesMetadata(projectKey)` -> issue types available in
  the project (Story, Task, Bug, Sub-task, etc.) with their ids.
- `getJiraIssueTypeMetaWithFields(projectKey, issueTypeId)` -> required/
  available fields for creating that issue type (parent field, Epic Link,
  etc.). Check this before `createJiraIssue` to avoid missing-field errors.

## ADF description format

Jira Cloud descriptions/comments are Atlassian Document Format (ADF) JSON,
not plain markdown. Minimal template:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    { "type": "paragraph", "content": [{ "type": "text", "text": "..." }] },
    { "type": "bulletList", "content": [
      { "type": "listItem", "content": [
        { "type": "paragraph", "content": [{ "type": "text", "text": "..." }] }
      ]}
    ]}
  ]
}
```

Use this shape for `editJiraIssue` (description field) and
`addCommentToJiraIssue` (body).

## Creating Stories under an Epic

- Team-managed projects: `createJiraIssue` with `fields.parent = { key:
  <EPIC-KEY> }`.
- Company-managed projects: set the Epic Link custom field instead (id from
  `getJiraIssueTypeMetaWithFields`).
- If neither field is available, fall back to `createIssueLink` with a link
  type from `getIssueLinkTypes` (e.g. "relates to") and note the limitation to
  the user at the checkpoint.

## Creating dev subtasks

- `createJiraIssue` with `fields.issuetype = { id: <Sub-task id> }` and
  `fields.parent = { key: <PARENT-KEY> }`.
- If the project has no "Sub-task" issue type (check via
  `getJiraProjectIssueTypesMetadata`), create them as `Task` and link to the
  parent via `createIssueLink` instead - call this out at the checkpoint so
  the user knows they won't nest visually under the parent.

## Status transitions

- `getTransitionsForJiraIssue(issueKey)` -> list of `{id, name}`. Match
  case-insensitively against `/review/` to find the post-development
  transition.
- If no transition name matches, leave the status untouched and note it in
  the final summary - don't guess a transition that might not reflect the
  project's actual workflow.
- `transitionJiraIssue(issueKey, transitionId)`.

## Linking the PR back

- `addCommentToJiraIssue(issueKey, <ADF body with PR URL>)` on the main issue
  and each subtask/story touched.

## Pre-existing subtasks

- If `getJiraIssue` already returns subtasks/children, treat their titles/
  descriptions as the current plan. At the checkpoint, propose edits (new
  title/description, or split/merge) rather than creating duplicates. Only
  call `createJiraIssue` for genuinely new subtasks; use `editJiraIssue` for
  existing ones that need updated descriptions.
