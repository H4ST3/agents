#!/usr/bin/env python3
"""
Validate marketplace.json integrity for the h4st3/agents curated fork.

Checks:
1. No phantom plugins (marketplace entry without directory)
2. Uncurated plugin count (directories not in marketplace — expected in a fork)
"""

import json
import sys
from pathlib import Path


def main():
    root = Path(__file__).parent.parent
    marketplace_json = root / ".claude-plugin" / "marketplace.json"
    plugins_dir = root / "plugins"

    errors = []
    warnings = []

    # Load marketplace.json
    try:
        with open(marketplace_json) as f:
            marketplace = json.load(f)
    except FileNotFoundError:
        print("❌ .claude-plugin/marketplace.json not found")
        return 1
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON in marketplace.json: {e}")
        return 1

    # Get plugins from marketplace
    marketplace_plugins = {p["name"]: p for p in marketplace.get("plugins", [])}

    # Get actual plugin directories
    if not plugins_dir.exists():
        print("❌ plugins/ directory not found")
        return 1

    plugin_dirs = {
        d.name: d
        for d in plugins_dir.iterdir()
        if d.is_dir() and not d.name.startswith(".")
    }

    # Check 1: Phantom plugins (in marketplace but missing directory)
    phantom = set(marketplace_plugins.keys()) - set(plugin_dirs.keys())
    if phantom:
        for name in sorted(phantom):
            errors.append(f"Phantom plugin: '{name}' listed in marketplace.json but directory missing")

    # Check 2: Uncurated plugins (directory exists but not in marketplace)
    # This is expected in a curated fork — upstream has more plugins than we curate.
    uncurated = set(plugin_dirs.keys()) - set(marketplace_plugins.keys())
    uncurated_count = len(uncurated)

    # Report results
    print()
    if errors:
        print("ERRORS:")
        for error in errors:
            print(f"  - {error}")
        print()
        print("Fix errors before committing.")
        return 1

    print(f"Marketplace validation passed.")
    print(f"  {len(marketplace_plugins)} curated plugins, all present on disk.")
    print(f"  {uncurated_count} uncurated upstream plugins on disk (expected).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
