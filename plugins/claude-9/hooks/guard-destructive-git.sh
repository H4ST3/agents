#!/bin/bash
# guard-destructive-git.sh - PreToolUse hook that denies dangerous git
# subcommands. Defense-in-depth against pattern-matching bypass vectors.
#
# Handles:
#   1. Global options before subcommands: git -C /path push --force
#   2. Combined short flags: git push -fu (force + set-upstream)
#   3. Compound commands: echo foo && git push --force origin main
#   4. Subshell wrappers: bash -c "git reset --hard HEAD"
#   5. Additional destructive ops: stash drop/clear, branch -D

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

# =====================================================================
# Phase 1: Compound command / subshell scanning
# Catches bypass vectors where dangerous git ops are hidden after
# chain operators (&&, ||, ;) or inside subshells (bash -c, sh -c).
# =====================================================================

HAS_CHAIN=false
if [[ "$COMMAND" == *"&&"* ]] || [[ "$COMMAND" == *"||"* ]] || [[ "$COMMAND" == *";"* ]] || \
   [[ "$COMMAND" == *'$('* ]] || [[ "$COMMAND" == *'`'* ]]; then
  HAS_CHAIN=true
fi

HAS_SUBSHELL=false
if [[ "$COMMAND" =~ ^(bash|sh|zsh|dash)[[:space:]]+-c[[:space:]] ]] || \
   [[ "$COMMAND" =~ ^eval[[:space:]] ]]; then
  HAS_SUBSHELL=true
fi

if [[ "$HAS_CHAIN" == true ]] || [[ "$HAS_SUBSHELL" == true ]]; then
  # Scan for dangerous git patterns anywhere in the raw command string.
  # These regexes are intentionally broad — false positives on compound
  # commands are acceptable (too strict > too permissive).

  if [[ "$COMMAND" =~ git[[:space:]](.+[[:space:]])?clean([[:space:]]|$) ]]; then
    deny "DENIED: Compound/subshell command contains 'git clean' (removes untracked files)."
  fi

  if [[ "$COMMAND" =~ git[[:space:]](.+[[:space:]])?reset[[:space:]].*--hard ]]; then
    deny "DENIED: Compound/subshell command contains 'git reset --hard' (discards changes)."
  fi

  if [[ "$COMMAND" =~ git[[:space:]](.+[[:space:]])?push[[:space:]].*(--force-with-lease|--force) ]]; then
    deny "DENIED: Compound/subshell command contains force push (overwrites remote history)."
  fi

  # Catch combined -f flags: -f, -fu, -fv, -fn, etc. but not flags without f
  if [[ "$COMMAND" =~ git[[:space:]](.+[[:space:]])?push[[:space:]].*[[:space:]]-[a-eA-Eg-zG-Z]*f ]]; then
    deny "DENIED: Compound/subshell command contains force push via -f flag."
  fi

  # Also scan for destructive rm in chains (belt-and-suspenders with managed deny)
  if [[ "$COMMAND" =~ rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f ]] || \
     [[ "$COMMAND" =~ rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r ]] || \
     [[ "$COMMAND" =~ rm[[:space:]]+--recursive ]] || \
     [[ "$COMMAND" =~ rm[[:space:]]+-r[[:space:]]+-f ]] || \
     [[ "$COMMAND" =~ rm[[:space:]]+-f[[:space:]]+-r ]]; then
    deny "DENIED: Compound/subshell command contains destructive 'rm' operation."
  fi

  # If it's a pure subshell wrapper, also exit (don't fall through to Phase 2)
  if [[ "$HAS_SUBSHELL" == true ]]; then
    # No dangerous patterns found in subshell — allow it
    exit 0
  fi
fi

# =====================================================================
# Phase 2: Single git command parsing
# Strips global options (-C, --git-dir, -c, etc.) to find the real
# subcommand, then checks for destructive operations.
# =====================================================================

# Only process git commands
if [[ ! "$COMMAND" =~ ^git[[:space:]] ]]; then
  exit 0
fi

# --- Parse git command: strip global options to find subcommand + args ---
read -ra WORDS <<< "$COMMAND"

# Skip "git" (word 0), then skip global options
i=1
while [[ $i -lt ${#WORDS[@]} ]]; do
  word="${WORDS[$i]}"
  case "$word" in
    # Global options that consume the NEXT word as their argument
    -C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--config-env|--exec-path)
      i=$((i + 2))
      ;;
    # Global options with = syntax (--git-dir=/path, etc.)
    --git-dir=*|--work-tree=*|--namespace=*|--super-prefix=*|--config-env=*|--exec-path=*)
      i=$((i + 1))
      ;;
    # Global boolean flags (no argument)
    --no-pager|--paginate|-p|-P|--bare|--no-replace-objects|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--no-optional-locks|--html-path|--man-path|--info-path)
      i=$((i + 1))
      ;;
    # First non-option word is the subcommand
    *)
      break
      ;;
  esac
done

# If we ran out of words, no subcommand found — pass through
if [[ $i -ge ${#WORDS[@]} ]]; then
  exit 0
fi

SUBCMD="${WORDS[$i]}"
# Remaining words after the subcommand
SUBCMD_ARGS=("${WORDS[@]:$((i + 1))}")
SUBCMD_ARGS_STR="${SUBCMD_ARGS[*]:-}"

# --- Helper: check if a word appears as a standalone arg ---
has_arg() {
  local target="$1"
  for arg in "${SUBCMD_ARGS[@]}"; do
    [[ "$arg" == "$target" ]] && return 0
  done
  return 1
}

# --- Helper: check if any arg contains a flag character ---
# Matches -f, -fu, -fv, etc. (any short flag group containing 'f')
has_flag() {
  local flag_char="$1"
  for arg in "${SUBCMD_ARGS[@]}"; do
    # Only check short flag groups (start with - but not --)
    if [[ "$arg" =~ ^-[a-zA-Z]+$ ]] && [[ "$arg" == *"$flag_char"* ]]; then
      return 0
    fi
  done
  return 1
}

# --- Check for dangerous subcommands ---

case "$SUBCMD" in
  clean)
    deny "DENIED: 'git clean' is destructive (removes untracked files). Use 'git status' to review instead."
    ;;

  reset)
    if [[ "$SUBCMD_ARGS_STR" == *"--hard"* ]]; then
      deny "DENIED: 'git reset --hard' discards uncommitted changes permanently."
    fi
    ;;

  push)
    # Check for --force and --force-with-lease
    if [[ "$SUBCMD_ARGS_STR" == *"--force-with-lease"* ]]; then
      deny "DENIED: 'git push --force-with-lease' is a force push variant that overwrites remote history."
    elif [[ "$SUBCMD_ARGS_STR" == *"--force"* ]]; then
      deny "DENIED: 'git push --force' overwrites remote history. Use regular 'git push' instead."
    fi
    # Check for -f in any combined short flag group (-f, -fu, -fv, etc.)
    if has_flag "f"; then
      deny "DENIED: 'git push -f' (force push) overwrites remote history. Use regular 'git push' instead."
    fi
    ;;

  checkout)
    # Deny "git checkout ." — discard all working tree changes
    # Must catch: git checkout ., git checkout -- ., git checkout HEAD -- .
    # But allow: git checkout <branch>, git checkout <file>
    if has_arg "."; then
      deny "DENIED: 'git checkout .' discards all uncommitted changes. Use 'git stash' to save changes instead."
    fi
    ;;

  restore)
    # Deny "git restore ." — discard working tree changes
    # Must catch: git restore ., git restore -W ., git restore --source=X .
    # Allow: git restore --staged . (only affects index, working tree is safe)
    # Allow: git restore -S . (short form of --staged)
    if has_arg "."; then
      # Check if ONLY staging (--staged / -S without -W / --worktree)
      staged_only=false
      if [[ "$SUBCMD_ARGS_STR" == *"--staged"* ]] || has_flag "S"; then
        # Has --staged or -S. Check if also has --worktree / -W
        if [[ "$SUBCMD_ARGS_STR" != *"--worktree"* ]] && ! has_flag "W"; then
          staged_only=true
        fi
      fi
      if [[ "$staged_only" != true ]]; then
        deny "DENIED: 'git restore .' discards all working tree changes. Use 'git stash' to save changes instead."
      fi
    fi
    ;;

  stash)
    # Deny stash drop and stash clear — lose stashed changes
    stash_sub="${SUBCMD_ARGS[0]:-}"
    if [[ "$stash_sub" == "drop" ]] || [[ "$stash_sub" == "clear" ]]; then
      deny "DENIED: 'git stash $stash_sub' permanently deletes stashed changes."
    fi
    ;;

  branch)
    # Deny force-delete: git branch -D, git branch --delete --force
    if has_flag "D"; then
      deny "DENIED: 'git branch -D' force-deletes a branch (may lose unmerged commits). Use 'git branch -d' for safe delete."
    fi
    if [[ "$SUBCMD_ARGS_STR" == *"--delete"* ]] && [[ "$SUBCMD_ARGS_STR" == *"--force"* ]]; then
      deny "DENIED: 'git branch --delete --force' force-deletes a branch (may lose unmerged commits)."
    fi
    ;;
esac

# Not a dangerous command — pass through to other hooks/permissions
exit 0
