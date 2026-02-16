#!/bin/bash
# guard-sensitive-files.sh - PreToolUse hook that blocks Bash commands
# from reading sensitive files (.env, .pem, credentials, secrets, etc.)
#
# The Read tool has deny rules for these patterns, but Bash commands
# like "cat .env" bypass the Read tool entirely. This hook closes
# that gap for common file-reading commands.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# --- Helper: emit deny and exit ---
deny() {
  local reason="$1"
  jq -n --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# --- Helper: check if a filename matches sensitive patterns ---
is_sensitive() {
  local file="$1"
  local base
  base=$(basename "$file")

  case "$base" in
    .env|.env.*)           return 0 ;;
    *.pem|*.key|*.p12|*.pfx) return 0 ;;
    .netrc|.npmrc|.pypirc) return 0 ;;
    id_rsa|id_ed25519|id_ecdsa|id_dsa) return 0 ;;
    *credentials*|*credential*) return 0 ;;
    *secret*|*secrets*)    return 0 ;;
  esac

  # Also match paths containing these directories/patterns
  case "$file" in
    */.ssh/*|*/.gnupg/*) return 0 ;;
  esac

  return 1
}

# --- Determine if this is a file-reading command ---

# Extract the base command (first word, stripping any path prefix)
CMD_WORD=$(echo "$COMMAND" | awk '{print $1}')
CMD_BASE=$(basename "$CMD_WORD")

# File-reading commands that take filenames as arguments
case "$CMD_BASE" in
  cat|head|tail|less|more|bat|batcat|nl|strings|xxd|od|hexdump|base64|file|tee)
    ;;
  cp|mv|rsync|scp)
    # Copy/move commands: check source files (not destination)
    ;;
  grep|egrep|fgrep|rg|ag)
    # grep can read files, but also searches patterns — check file args
    ;;
  *)
    # Not a file-reading command, pass through
    exit 0
    ;;
esac

# --- Scan command arguments for sensitive filenames ---
# Parse words from the command, skipping flags (words starting with -)

read -ra WORDS <<< "$COMMAND"
SKIP_NEXT=false

for ((idx=1; idx<${#WORDS[@]}; idx++)); do
  word="${WORDS[$idx]}"

  # Skip flag values (e.g., -n 10, --lines=10)
  if [[ "$SKIP_NEXT" == true ]]; then
    SKIP_NEXT=false
    continue
  fi

  # Skip flags and their arguments
  if [[ "$word" == --*=* ]]; then
    continue
  fi
  if [[ "$word" == -* ]]; then
    # Flags that consume the next word as a value
    case "$CMD_BASE" in
      grep|egrep|fgrep|rg|ag)
        # grep -e PATTERN, grep -f FILE, grep -m NUM, etc.
        case "$word" in
          -e|-f|-m|--file|--regexp|--max-count|-A|-B|-C|--after-context|--before-context|--context)
            SKIP_NEXT=true ;;
        esac
        ;;
      head|tail)
        case "$word" in -n|-c|--lines|--bytes) SKIP_NEXT=true ;; esac
        ;;
      cp|mv)
        case "$word" in -t|--target-directory|-S|--suffix|--backup) SKIP_NEXT=true ;; esac
        ;;
    esac
    continue
  fi

  # This word is a non-flag argument — check if it's a sensitive file
  if is_sensitive "$word"; then
    deny "DENIED: Bash command reads sensitive file '$word'. Use environment variables or a secret manager instead."
  fi
done

# Not reading any sensitive files — pass through
exit 0
