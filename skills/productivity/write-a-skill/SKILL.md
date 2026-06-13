---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

_Source: [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/write-a-skill)_

# Writing Skills

## Process

1. **Gather requirements** - ask user about:
   - What task/domain does the skill cover?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Any reference materials to include?
   - Is this adapted/copied from an existing skill or repo? (needed for the
     source reference in step 4)
   - Global (`~/.claude/skills/`, every project) or project-specific
     (`<project>/.claude/skills/`)?

2. **Draft the skill** - create:
   - SKILL.md with concise instructions
   - Additional reference files if content exceeds 500 lines
   - Utility scripts if deterministic operations needed

3. **Review with user** - present draft and ask:
   - Does this cover your use cases?
   - Anything missing or unclear?
   - Should any section be more/less detailed?

4. **Place the skill**:
   - **Project-specific**: write to
     `<project>/.claude/skills/<skill-name>/SKILL.md` (flat, no
     categorization).
   - **Global**: lives in `claude-dotfiles/skills/<category>/<skill-name>/`:
     - List existing categories (`ls claude-dotfiles/skills/`, e.g.
       `productivity/`, `engineering/`) and read their `README.md` to see
       what fits.
     - Pick the best-fitting existing category, or propose a new one and
       confirm with the user before creating it.
     - Write `SKILL.md` (+ any extra files) to
       `claude-dotfiles/skills/<category>/<skill-name>/`.
     - If the category is new, create
       `claude-dotfiles/skills/<category>/README.md` with a one-line header,
       mirroring existing category READMEs.
     - Add an entry for the new skill to
       `claude-dotfiles/skills/<category>/README.md`:
       `- **[<name>](./<name>/SKILL.md)** — <one-line description>`
     - If adapted/copied from an external source, add
       `_Source: [<label>](<url>)_` right after the frontmatter.
     - Run `claude-dotfiles/scripts/link-skills.sh` to (re)generate the
       `~/.claude/skills/<name>` symlink.
     - Commit and push `claude-dotfiles` (per CLAUDE.md Law 2, no approval
       needed).

## Skill Structure

Project-specific:

```
<project>/.claude/skills/skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.js
```

Global (categorized, see `claude-dotfiles/CLAUDE.md` dotfiles sync table):

```
claude-dotfiles/skills/<category>/
├── README.md          # Catalog of skills in this category
└── skill-name/
    ├── SKILL.md
    └── ...             # same as above
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, contexts, file types)

**Format**:

- Max 1024 chars
- Write in third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

**Good example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines
- Content has distinct domains (finance vs sales schemas)
- Advanced features are rarely needed

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...")
- [ ] SKILL.md under 100 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Concrete examples included
- [ ] References one level deep
- [ ] (global) Placed in the right category folder, category README updated
- [ ] (global) Source reference added if adapted from elsewhere
- [ ] (global) `link-skills.sh` re-run, `~/.claude/skills/<name>` symlink verified
