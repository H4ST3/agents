#!/usr/bin/env bash
# Self-healing symlink check for claude-9 managed files.
# Runs on UserPromptSubmit. Fast path: ~0ms if symlinks are healthy.
set -euo pipefail

# Fast path: if a known symlink resolves, plugin hasn't moved
[[ -L "$HOME/.claude/SOUL.md" && -e "$HOME/.claude/SOUL.md" ]] && exit 0

# Symlink broken or missing — attempt repair
MANIFEST="$HOME/.claude/.soul-manifest.json"
[[ -f "$MANIFEST" ]] || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Re-create all symlinks from manifest
FILES=$(python3 -c "import json; [print(f) for f in json.load(open('$MANIFEST')).get('files', [])]" 2>/dev/null || exit 0)

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    src="$CURRENT_ROOT/$file"
    dest="$HOME/.claude/$file"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
    fi
done <<< "$FILES"

# Update manifest with new plugin root
python3 -c "
import json, sys
m = json.load(open('$MANIFEST'))
m['plugin_root'] = '$CURRENT_ROOT'
json.dump(m, open('$MANIFEST', 'w'), indent=2)
" 2>/dev/null || true
