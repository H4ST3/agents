#!/usr/bin/env python3
"""
Validate marketplace.json integrity.

Checks:
1. No phantom plugins (marketplace entry without directory)
2. No orphaned plugins (directory without marketplace entry)
3. No version fields in plugin.json files
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

    # Check 2: Orphaned plugins (directory exists but not in marketplace)
    orphaned = set(plugin_dirs.keys()) - set(marketplace_plugins.keys())
    if orphaned:
        for name in sorted(orphaned):
            warnings.append(f"Orphaned plugin: '{name}' has directory but not in marketplace.json")

    # Check 3: Version fields in plugin.json files
    plugins_with_version = []
    for plugin_name, plugin_dir in plugin_dirs.items():
        plugin_json = plugin_dir / ".claude-plugin" / "plugin.json"
        if plugin_json.exists():
            try:
                with open(plugin_json) as f:
                    data = json.load(f)
                if "version" in data:
                    plugins_with_version.append(plugin_name)
            except json.JSONDecodeError:
                warnings.append(f"Invalid JSON in {plugin_name}/.claude-plugin/plugin.json")

    if plugins_with_version:
        for name in sorted(plugins_with_version):
            errors.append(f"Version field found: '{name}/.claude-plugin/plugin.json' should not contain version")

    # Report results
    print()
    if not errors and not warnings:
        print("✅ Marketplace validation passed!")
        print(f"   {len(marketplace_plugins)} plugins, all checks passed")
        return 0

    if errors:
        print("❌ ERRORS:")
        for error in errors:
            print(f"   • {error}")
        print()

    if warnings:
        print("⚠️  WARNINGS:")
        for warning in warnings:
            print(f"   • {warning}")
        print()

    if errors:
        print("Fix errors before committing.")
        return 1
    else:
        print("Warnings should be addressed but won't block.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
