# Dev Task - GitHub Reference

Everything uses the `gh` CLI (>= 2.6x for `--parent`). Run from inside the
repo so `gh` infers `OWNER/REPO`; otherwise add `-R OWNER/REPO`.

## Fetching & classifying

```bash
gh issue view <N> --json number,title,body,labels,state,url,parent,subIssues
```

- Type = the `type:*` label (`type:epic`, `type:story`, `type:task`,
  `type:bug`). Issue Types (`--type`) only exist on organization repos; on
  personal repos the labels are the source of truth.
- `parent` is `null` or `{number, title, ...}`; `subIssues.nodes` lists
  children.
- Missing `type:*` / `area:*` labels in the repo -> stop and tell the user
  (don't create taxonomy on the fly).

## Updating a body

```bash
gh issue edit <N> --body-file <file>
```

Bodies are plain GitHub Markdown. Write the body to a temp file under the
session scratchpad and pass `--body-file` to avoid shell-quoting issues.

## Creating stories / dev tasks as sub-issues

```bash
gh issue create --title "<title>" --body-file <file> \
  --label "type:story" --label "area:<x>" --parent <PARENT-N>
```

- Epic -> stories: `--label type:story --parent <EPIC-N>`.
- Story/Task/Bug -> dev tasks: `--label type:task --parent <PARENT-N>`.
- Prints the new issue URL; the number is its last path segment.
- Existing sub-issues: edit them with `gh issue edit` instead of creating
  duplicates. To attach an existing issue as a sub-issue:
  `gh api -X POST repos/OWNER/REPO/issues/<PARENT-N>/sub_issues -F sub_issue_id=<databaseId>`
  (`databaseId` from `gh api repos/OWNER/REPO/issues/<N> --jq .id`, NOT the
  issue number).

## Project discovery

Find the Project linked to the repo (use the first one; if several, ask):

```bash
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){projectsV2(first:5){nodes{id number title owner{... on User{login} ... on Organization{login}}}}}}'
```

Then the Status field and its option ids:

```bash
gh project field-list <PROJECT-NUMBER> --owner <PROJECT-OWNER> --format json \
  --jq '.fields[] | select(.name=="Status") | {id, options}'
```

Match option names case-insensitively (`in progress`, `review`). If no
`review` option exists, skip the Review move and report it - don't pick a
different status as a substitute.

## Adding an issue to the Project & setting Status

`item-add` is idempotent: for an issue already in the Project it returns the
existing item, so it doubles as "get item id".

```bash
ITEM_ID=$(gh project item-add <PROJECT-NUMBER> --owner <PROJECT-OWNER> \
  --url <ISSUE-URL> --format json --jq .id)

gh project item-edit --id "$ITEM_ID" --project-id <PROJECT-NODE-ID> \
  --field-id <STATUS-FIELD-ID> --single-select-option-id <OPTION-ID>
```

- Newly added items get Status = Backlog from the Project's "Item added to
  project" workflow, which runs asynchronously and can overwrite an edit made
  right after `item-add`. For freshly created issues, wait a few seconds after
  `item-add`, then `item-edit`, then confirm with
  `gh project item-list <PROJECT-NUMBER> --owner <PROJECT-OWNER> --format json`.
- Step 5: every touched issue -> **In Progress** (the epic too, if this
  mission is working on one of its stories).
- Step 11: every issue in the PR's `Closes` lines -> **Review**.
- **Done** is never set by the skill: merging the PR closes the issues and
  the Project's built-in "Item closed" / "Pull request merged" workflows
  move them.

## Shipping the PR

```bash
gh pr create --base main --title "<type>(<scope>): <summary> (#<N>)" --body-file <file>
```

Body ends with the closing keywords, one per line:

```
Closes #<STORY-N>
Closes #<TASK-N1>
Closes #<TASK-N2>
```

Never put the parent epic in `Closes` - it closes manually (or via its last
story) once every sub-issue is done.
