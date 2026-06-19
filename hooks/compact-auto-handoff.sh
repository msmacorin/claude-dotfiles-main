#!/bin/bash
# Fires on context compaction (SessionStart with "compact" matcher).
# If a /resume was previously done in this session, instructs Claude
# to re-save the handoff using the same slug so progress is not lost.

SLUG_FILE="$HOME/.claude/handoffs/.active-resume-slug"

if [ -f "$SLUG_FILE" ]; then
  SLUG=$(cat "$SLUG_FILE")
  if [ -n "$SLUG" ]; then
    echo "<system-reminder>Context compaction just occurred. This session was previously resumed from handoff '${SLUG}'. Immediately invoke the 'handoff' skill with the argument '${SLUG}' to persist current progress before responding to the user.</system-reminder>"
  fi
fi
