#!/bin/bash
# prefer-openspec.sh - Soft gate on EnterPlanMode recommending OpenSpec workflow.
# Uses "ask" permission decision to let the user choose.
set -euo pipefail

cat > /dev/null

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: "The OpenSpec workflow (/openspec:ff or /openspec:new) is generally superior to native plan mode but may not be right in this instance. Approve to use EnterPlanMode, or deny to use OpenSpec instead."
  }
}'
exit 0
