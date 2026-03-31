# claude-dotfiles

Hello, Claude Code. If you're reading this, it means the user has shared this repository with you so you can set up their environment. This file contains everything you need to install, backup, and rollback their Claude Code configuration.

## What is this repository?

This repository is the **single source of truth** for the user's Claude Code configuration. It contains:

```
claude-dotfiles/
├── CLAUDE.md              # Global instructions (personas, workflow rules, behaviors)
├── settings.json          # Permission rules (curated allow/deny lists)
├── hooks/                 # PreToolUse hooks (auto-approve scripts)
│   └── auto-approve-claude-dir.sh
├── knowledge/             # Living knowledge base (domain, architecture, operations)
│   ├── README.md          # Knowledge base structure and conventions
│   ├── domain/            # Business domain (glossary, context maps)
│   ├── architecture/      # Technical docs (services, patterns, decisions)
│   └── operations/        # Runbooks, infrastructure
├── agents/                # Custom agent definitions (project-specific)
└── README.md              # You are here
```

## Deployment strategy

Not all files are deployed the same way. Some are **symlinked** (edits go directly to the repo), others must be **copied** (Claude Code breaks with symlinks for certain files).

| File / Dir | Deploy method | Reason |
|------------|---------------|--------|
| `CLAUDE.md` | **symlink** | Works fine; edits go directly to repo |
| `settings.json` | **copy** | Symlinked settings.json breaks Claude Code ([#3575](https://github.com/anthropics/claude-code/issues/3575)) |
| `hooks/` | **copy** | Same sensitive-path issue; must be real files |
| `knowledge/` | lives in repo | Accessed through CLAUDE.md symlink path |
| `agents/` | manual | Project-specific, not globally deployed |

**Sync rule**: when editing a copy-deployed file, update in both places (repo + `~/.claude/`). The auto-commit behavior in CLAUDE.md handles git commits.

## Step 1: Backup existing files

Before changing anything, **backup the user's current `~/.claude/` configuration**:

```bash
BACKUP_DIR=~/.claude/pre-dotfiles-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

# Backup everything that matters
for f in CLAUDE.md settings.json settings.local.json; do
  [ -e ~/.claude/$f ] && cp -L ~/.claude/$f "$BACKUP_DIR/$f" && echo "Backed up $f"
done

[ -d ~/.claude/hooks ] && cp -r ~/.claude/hooks "$BACKUP_DIR/hooks" && echo "Backed up hooks/"

echo "Backup complete: $BACKUP_DIR"
ls -la "$BACKUP_DIR"
```

## Step 2: Clone the repository

```bash
REPO_DIR=~/dev/claude-dotfiles-main
git clone git@github.com:msmacorin/claude-dotfiles-main.git "$REPO_DIR"
```

If already cloned, just pull:

```bash
cd ~/dev/claude-dotfiles-main && git pull
```

## Step 3: Install

```bash
REPO_DIR=~/dev/claude-dotfiles-main

# 1. CLAUDE.md — symlink (edits go to repo)
rm -f ~/.claude/CLAUDE.md
ln -s "$REPO_DIR/CLAUDE.md" ~/.claude/CLAUDE.md

# 2. settings.json — copy (symlinks break Claude Code)
cp "$REPO_DIR/settings.json" ~/.claude/settings.json

# 3. hooks/ — copy (must be real files)
mkdir -p ~/.claude/hooks
cp "$REPO_DIR/hooks/"* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 4. Clean project memories (stale context from previous sessions)
rm -rf ~/.claude/projects/
echo "Project memories cleared."
```

## Step 4: Verify

```bash
# Symlink points to the right place
readlink ~/.claude/CLAUDE.md

# CLAUDE.md is readable
head -5 ~/.claude/CLAUDE.md

# settings.json is a real file (NOT a symlink)
file ~/.claude/settings.json

# Hooks are in place and executable
ls -la ~/.claude/hooks/

# Knowledge base exists
ls knowledge/

# Git remote is configured for auto-commit
cd ~/dev/claude-dotfiles-main && git remote -v
```

## Rollback

```bash
# Find the backup
ls -d ~/.claude/pre-dotfiles-backup-*

# Restore (use the actual backup directory name)
BACKUP_DIR=~/.claude/pre-dotfiles-backup-XXXXXXXX-XXXXXX

rm -f ~/.claude/CLAUDE.md
cp "$BACKUP_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
cp "$BACKUP_DIR/settings.json" ~/.claude/settings.json 2>/dev/null
cp "$BACKUP_DIR/settings.local.json" ~/.claude/settings.local.json 2>/dev/null
[ -d "$BACKUP_DIR/hooks" ] && cp -r "$BACKUP_DIR/hooks" ~/.claude/hooks

echo "Rollback complete."
```

## Forking this repository

If you want to use this setup as a starting point for your own Claude Code configuration, **fork it** — do not clone directly. This prevents accidental pushes to the original repo.

### Step 1: Fork and clone

```bash
# Fork on GitHub first (via UI or gh cli), then:
gh repo fork msmacorin/claude-dotfiles-main --clone --remote
cd claude-dotfiles-main
```

### Step 2: Adjust references to your environment

The following files contain paths and identifiers specific to the original author. Search and replace them:

| What to replace | Where | Replace with |
|-----------------|-------|--------------|
| `msmacorin` (GitHub user) | `README.md` (clone URL) | Your GitHub username |
| `macorin` (Linux user) | `CLAUDE.md`, `settings.json`, `hooks/` | Your Linux username (`whoami`) |
| `/home/macorin/` | `CLAUDE.md`, `settings.json`, `hooks/` | Your home directory (`echo $HOME`) |
| `~/dev/claude-dotfiles-main` | `CLAUDE.md`, `README.md` | Path where you cloned your fork |
| Character personas | `CLAUDE.md` (Persons section) | Keep, modify, or remove — these are optional fun |
| `knowledge/` contents | `knowledge/` | Delete and rebuild with your own domain knowledge |
| Aliases table | `CLAUDE.md` (Aliases section) | Replace with your own repo/service aliases |

A quick way to find all references:

```bash
grep -rn "macorin" .
grep -rn "/home/macorin" .
```

### Step 3: Protect against accidental pushes to the original

After forking, verify your remotes point to the right place:

```bash
git remote -v
# origin should point to YOUR fork, not msmacorin/claude-dotfiles-main
```

If `origin` still points to the original repo, fix it:

```bash
git remote set-url origin git@github.com:YOUR_USERNAME/claude-dotfiles-main.git
```

Optionally, keep the original as `upstream` (read-only, for pulling updates):

```bash
git remote add upstream git@github.com:msmacorin/claude-dotfiles-main.git
git remote set-url --push upstream no-push  # prevents accidental pushes
```

### Step 4: Clean up and personalize

1. **Delete `knowledge/`** — this contains domain-specific knowledge from the original author. Start fresh with your own.
2. **Reset `Claude Notes`** — the last section of `CLAUDE.md` contains session-specific notes. Clear it and let your Claude build its own.
3. **Delete project memories** — run `rm -rf ~/.claude/projects/` to remove stale per-project memory from previous sessions. Claude will rebuild these as needed.
4. **Review `settings.json`** — permissions reference specific paths. Adjust to match your filesystem.
5. **Review `hooks/`** — the auto-approve hook references `~/.claude/`. This should work as-is, but verify.
6. **Delete `agents/`** — or keep `sandboxed-worker.md` as a template and adapt to your workflow.

After cleaning up, follow the normal install steps (Step 1-4 above) using your fork's path.

---

## Notes for you, Claude Code

Once installed, read `CLAUDE.md` carefully. It contains:

- **Asimov's Laws**: Fundamental rules that override everything else.
- **Workflow behaviors**: Auto-commit rules for this repo, knowledge base conventions, dotfiles sync strategy.
- **Development behaviors**: Linting, testing, and commit rules (GPG signing required — always ask before committing).
- **Character mode**: The user may greet you as a fictional character. Follow the persona instructions in the Characters section.
- **Knowledge base**: Persist domain and technical knowledge under `knowledge/` following `knowledge/README.md` conventions.

Welcome aboard.
