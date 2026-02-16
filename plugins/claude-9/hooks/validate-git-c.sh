#!/bin/bash
# validate-git-c.sh - PreToolUse hook for git -C commands.
# Allows safe read-only git commands under ~/projects, with optional
# piping to safe filter commands (head, tail, grep, wc, etc.).
# Denies path traversal, shell metacharacters, and unsafe pipes.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process git -C commands; let everything else pass through
if [[ ! "$COMMAND" =~ ^git[[:space:]]+-C[[:space:]] ]]; then
  exit 0
fi

# --- Helper: emit JSON decision and exit ---
decide() {
  local decision="$1" reason="$2"
  jq -n --arg d "$decision" --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: $d,
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# --- Split command on pipe into segments ---

# Detect trailing pipe (IFS read won't capture trailing empty segment)
if [[ "$COMMAND" =~ \|[[:space:]]*$ ]]; then
  decide "deny" "Empty pipe segment (trailing pipe)"
fi

IFS='|' read -ra SEGMENTS <<< "$COMMAND"
GIT_PART="${SEGMENTS[0]}"

# Reject empty segments (catches || bypass)
for ((i=0; i<${#SEGMENTS[@]}; i++)); do
  trimmed="${SEGMENTS[$i]}"
  trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
  if [[ -z "$trimmed" ]]; then
    decide "deny" "Empty pipe segment (possible || bypass)"
  fi
done

# --- Validate git portion ---

# Reject path traversal in the git portion
if [[ "$GIT_PART" == *".."* ]]; then
  decide "deny" "Path traversal (..) not allowed in git -C"
fi

# Reject shell metacharacters in the git portion (but NOT pipe — already split)
if [[ "$GIT_PART" == *";"* ]] || [[ "$GIT_PART" == *"&&"* ]] || [[ "$GIT_PART" == *'$('* ]] || [[ "$GIT_PART" == *'`'* ]]; then
  decide "deny" "Shell metacharacters not allowed in git -C commands"
fi

BASE_PATH="${CLAUDE9_PROJECTS_PATH:-$HOME/projects}"
SAFE_CMDS="^git[[:space:]]+-C[[:space:]]+${BASE_PATH}(/[a-zA-Z0-9_./-]+)?[[:space:]]+(status|log|diff|branch|show|ls-files|ls-tree|remote|rev-parse|describe|tag|stash[[:space:]]+list|shortlog|reflog|merge-base|for-each-ref|blame|fetch|config[[:space:]]+--get)([[:space:]]|$)"

if [[ ! "$GIT_PART" =~ $SAFE_CMDS ]]; then
  decide "ask" "git -C command not on safe read-only list"
fi

# --- Git portion is safe; validate pipe segments if any ---

if [[ ${#SEGMENTS[@]} -gt 1 ]]; then
  SAFE_PIPE="^[[:space:]]*(head|tail|grep|egrep|fgrep|wc|sort|uniq|cat|awk|sed|cut|tr|column|nl|fmt|fold)([[:space:]].*)?$"

  for ((i=1; i<${#SEGMENTS[@]}; i++)); do
    segment="${SEGMENTS[$i]}"

    # Reject metacharacters and output redirection in pipe segments
    if [[ "$segment" == *";"* ]] || [[ "$segment" == *"&&"* ]] || [[ "$segment" == *'$('* ]] || [[ "$segment" == *'`'* ]] || [[ "$segment" == *".."* ]]; then
      decide "deny" "Shell metacharacters not allowed in pipe segments"
    fi
    if [[ "$segment" =~ [^0-9]\>[[:space:]] ]] || [[ "$segment" == *">>"* ]] || [[ "$segment" =~ 2\> ]]; then
      decide "deny" "Output redirection not allowed in pipe segments"
    fi

    # Check pipe segment against safe filter whitelist
    if [[ ! "$segment" =~ $SAFE_PIPE ]]; then
      decide "ask" "Pipe segment not on safe filter list"
    fi
  done

  decide "allow" "Safe read-only git -C command with safe pipe filters"
else
  decide "allow" "Safe read-only git -C command"
fi
