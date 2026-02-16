#!/bin/bash
# pre-push-review.sh - PreToolUse hook for git push commands.
# Generates a structured review summary of commits about to be pushed,
# surfaced in the permission dialog via permissionDecisionReason.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process git push commands; let everything else pass through
if [[ ! "$COMMAND" =~ ^git[[:space:]]+push ]]; then
  exit 0
fi

# --- Helper: emit JSON decision and exit ---
emit() {
  local decision="$1" reason="$2" context="${3:-$2}"
  jq -n --arg d "$decision" --arg r "$reason" --arg c "$context" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: $d,
      permissionDecisionReason: $r,
      additionalContext: $c
    }
  }'
  exit 0
}

# --- Gather branch info ---
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
UPSTREAM=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")

# Fetch latest remote state (quiet, with timeout protection)
git fetch --quiet 2>/dev/null || true

# Determine comparison base
if [[ -n "$UPSTREAM" ]]; then
  BASE="$UPSTREAM"
  REMOTE_NAME="${UPSTREAM%%/*}"
  REMOTE_BRANCH="${UPSTREAM#*/}"
  PUSH_TARGET="${REMOTE_NAME}/${REMOTE_BRANCH}"
else
  # No upstream; try to determine from push command or default remote
  REMOTE_NAME=$(echo "$COMMAND" | awk '{for(i=1;i<=NF;i++) if($i!="git" && $i!="push" && substr($i,1,1)!="-") {print $i; exit}}')
  REMOTE_NAME="${REMOTE_NAME:-origin}"
  # Check if remote/branch exists
  if git rev-parse --verify "${REMOTE_NAME}/${BRANCH}" &>/dev/null; then
    BASE="${REMOTE_NAME}/${BRANCH}"
    PUSH_TARGET="${REMOTE_NAME}/${BRANCH}"
  elif git rev-parse --verify "${REMOTE_NAME}/main" &>/dev/null; then
    BASE="${REMOTE_NAME}/main"
    PUSH_TARGET="${REMOTE_NAME}/main (new branch)"
  elif git rev-parse --verify "${REMOTE_NAME}/master" &>/dev/null; then
    BASE="${REMOTE_NAME}/master"
    PUSH_TARGET="${REMOTE_NAME}/master (new branch)"
  else
    emit "ask" "Pre-Push Review: ${BRANCH} → (no remote base found)

Could not determine remote base for comparison.
Proceed with caution — unable to generate diff summary."
  fi
fi

# --- Gather commit info ---
AHEAD_COUNT=$(git rev-list --count "${BASE}..HEAD" 2>/dev/null || echo "0")

if [[ "$AHEAD_COUNT" -eq 0 ]]; then
  emit "ask" "Pre-Push Review: ${BRANCH} → ${PUSH_TARGET}

No new commits to push. Branch is up to date with remote."
fi

COMMIT_LOG=$(git log --oneline --no-decorate "${BASE}..HEAD" 2>/dev/null || echo "(unable to read log)")

# --- Gather diff stats ---
DIFF_STAT=$(git diff --stat "${BASE}..HEAD" 2>/dev/null || echo "(unable to read diff)")
DIFF_STAT_SUMMARY=$(echo "$DIFF_STAT" | tail -1)

# Count files by category
SOURCE_FILES=0
SOURCE_ADD=0
SOURCE_DEL=0
TEST_FILES=0
TEST_ADD=0
TEST_DEL=0
CONFIG_FILES=0
CONFIG_ADD=0
CONFIG_DEL=0
TOTAL_FILES=0

while IFS= read -r line; do
  # Parse numstat: additions deletions filename
  ADD=$(echo "$line" | awk '{print $1}')
  DEL=$(echo "$line" | awk '{print $2}')
  FILE=$(echo "$line" | awk '{print $3}')

  # Skip binary files (shown as -)
  [[ "$ADD" == "-" ]] && ADD=0
  [[ "$DEL" == "-" ]] && DEL=0

  TOTAL_FILES=$((TOTAL_FILES + 1))

  if [[ "$FILE" =~ ^tests?/ ]] || [[ "$FILE" =~ /tests?/ ]] || [[ "$FILE" =~ _test\. ]] || [[ "$FILE" =~ test_[^/]*$ ]] || [[ "$FILE" =~ \.test\. ]] || [[ "$FILE" =~ \.spec\. ]]; then
    TEST_FILES=$((TEST_FILES + 1))
    TEST_ADD=$((TEST_ADD + ADD))
    TEST_DEL=$((TEST_DEL + DEL))
  elif [[ "$FILE" =~ \.(json|toml|yaml|yml|ini|cfg|conf|env|lock)$ ]] || [[ "$FILE" =~ (Makefile|Dockerfile|docker-compose|\.github/) ]]; then
    CONFIG_FILES=$((CONFIG_FILES + 1))
    CONFIG_ADD=$((CONFIG_ADD + ADD))
    CONFIG_DEL=$((CONFIG_DEL + DEL))
  else
    SOURCE_FILES=$((SOURCE_FILES + 1))
    SOURCE_ADD=$((SOURCE_ADD + ADD))
    SOURCE_DEL=$((SOURCE_DEL + DEL))
  fi
done < <(git diff --numstat "${BASE}..HEAD" 2>/dev/null)

# --- Risk analysis ---
RISKS=""
RISK_COUNT=0

# Check for large diffs (>500 lines in a single file)
LARGE_FILES=$(git diff --numstat "${BASE}..HEAD" 2>/dev/null | awk '$1 != "-" && $1 > 500 {print $3}' || true)
if [[ -n "$LARGE_FILES" ]]; then
  RISK_COUNT=$((RISK_COUNT + 1))
  RISKS="${RISKS}  ⚠ Large diffs (>500 lines added): $(echo "$LARGE_FILES" | tr '\n' ', ' | sed 's/,$//')
"
fi

# Exclude documentation from pattern checks — these cause false positives
# when docs discuss secrets, debugging, or use TODO in checklists
DOC_EXCLUDE=(':!*.md' ':!*.txt' ':!*.rst' ':!*.adoc' ':!*.html')

# Check for sensitive patterns in added lines — excludes docs
SENSITIVE=$(git diff "${BASE}..HEAD" -- . "${DOC_EXCLUDE[@]}" 2>/dev/null | grep -E '^\+[^+]' | grep -iE '(API_KEY|SECRET|PASSWORD|PRIVATE.?KEY|CONNECTION.?STRING|:[^/]{2}@)' | head -5 || true)
if [[ -n "$SENSITIVE" ]]; then
  RISK_COUNT=$((RISK_COUNT + 1))
  RISKS="${RISKS}  🔴 Sensitive patterns detected in added lines (API_KEY, SECRET, PASSWORD, etc.)
"
fi

# Check for debug leftovers — excludes docs
DEBUG=$(git diff "${BASE}..HEAD" -- . "${DOC_EXCLUDE[@]}" 2>/dev/null | grep -E '^\+[^+]' | grep -E '(print\(|console\.log|breakpoint\(\)|debugger|pdb\.set_trace|import pdb|import ipdb)' | head -5 || true)
if [[ -n "$DEBUG" ]]; then
  RISK_COUNT=$((RISK_COUNT + 1))
  DEBUG_COUNT=$(git diff "${BASE}..HEAD" -- . "${DOC_EXCLUDE[@]}" 2>/dev/null | grep -E '^\+[^+]' | grep -cE '(print\(|console\.log|breakpoint\(\)|debugger|pdb\.set_trace|import pdb|import ipdb)' || true)
  RISKS="${RISKS}  ⚠ Debug leftovers found (${DEBUG_COUNT} instances): print(), console.log, breakpoint, debugger
"
fi

# Check for TODO/FIXME/HACK — excludes docs
TODOS=$(git diff "${BASE}..HEAD" -- . "${DOC_EXCLUDE[@]}" 2>/dev/null | grep -E '^\+[^+]' | grep -iE '(TODO|FIXME|HACK|XXX)' | head -5 || true)
if [[ -n "$TODOS" ]]; then
  RISK_COUNT=$((RISK_COUNT + 1))
  TODO_COUNT=$(git diff "${BASE}..HEAD" -- . "${DOC_EXCLUDE[@]}" 2>/dev/null | grep -E '^\+[^+]' | grep -ciE '(TODO|FIXME|HACK|XXX)' || true)
  RISKS="${RISKS}  ℹ TODO/FIXME/HACK comments added (${TODO_COUNT} instances)
"
fi

# Check for new source files without corresponding tests
NEW_SRC_FILES=$(git diff --name-status "${BASE}..HEAD" 2>/dev/null | awk '$1=="A"' | awk '{print $2}' | grep -E '\.(py|ts|js|tsx|jsx)$' | grep -vE '(test_|_test\.|\.test\.|\.spec\.|/tests?/)' || true)
if [[ -n "$NEW_SRC_FILES" ]]; then
  MISSING_TESTS=""
  while IFS= read -r src_file; do
    # Check if a corresponding test file was also added
    base_name=$(basename "$src_file" | sed 's/\.\(py\|ts\|js\|tsx\|jsx\)$//')
    if ! git diff --name-status "${BASE}..HEAD" 2>/dev/null | awk '$1=="A"{print $2}' | grep -qE "(test_${base_name}|${base_name}_test|${base_name}\.test|${base_name}\.spec)"; then
      MISSING_TESTS="${MISSING_TESTS}    ${src_file}
"
    fi
  done <<< "$NEW_SRC_FILES"
  if [[ -n "$MISSING_TESTS" ]]; then
    RISK_COUNT=$((RISK_COUNT + 1))
    RISKS="${RISKS}  ℹ New source files without corresponding tests:
${MISSING_TESTS}"
  fi
fi

# --- Determine verdict ---
if [[ $RISK_COUNT -eq 0 ]]; then
  VERDICT="CLEAN"
elif echo "$RISKS" | grep -q "🔴"; then
  VERDICT="CAUTION"
else
  VERDICT="REVIEW RECOMMENDED"
fi

# --- Format risk section ---
if [[ -z "$RISKS" ]]; then
  RISK_SECTION="Risk Flags: None found"
else
  RISK_SECTION="Risk Flags (${RISK_COUNT}):
${RISKS}"
fi

# --- Build file breakdown ---
FILE_BREAKDOWN=""
if [[ $SOURCE_FILES -gt 0 ]]; then
  FILE_BREAKDOWN="  Source: ${SOURCE_FILES} files (+${SOURCE_ADD}/-${SOURCE_DEL})"
fi
if [[ $TEST_FILES -gt 0 ]]; then
  [[ -n "$FILE_BREAKDOWN" ]] && FILE_BREAKDOWN="${FILE_BREAKDOWN} | "
  FILE_BREAKDOWN="${FILE_BREAKDOWN}Tests: ${TEST_FILES} files (+${TEST_ADD}/-${TEST_DEL})"
fi
if [[ $CONFIG_FILES -gt 0 ]]; then
  [[ -n "$FILE_BREAKDOWN" ]] && FILE_BREAKDOWN="${FILE_BREAKDOWN} | "
  FILE_BREAKDOWN="${FILE_BREAKDOWN}Config: ${CONFIG_FILES} files (+${CONFIG_ADD}/-${CONFIG_DEL})"
fi

# --- Assemble summary ---
SUMMARY="Pre-Push Review: ${BRANCH} → ${PUSH_TARGET}

Commits (${AHEAD_COUNT} ahead):
$(echo "$COMMIT_LOG" | sed 's/^/  /')

Changes: ${TOTAL_FILES} files | ${DIFF_STAT_SUMMARY}
${FILE_BREAKDOWN}

${RISK_SECTION}
Verdict: ${VERDICT}"

emit "ask" "$SUMMARY"
