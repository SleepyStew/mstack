#!/usr/bin/env python3
"""Merge mstack's settings overrides into a Claude Code settings.json.

Usage: merge_settings.py <overrides.json> <settings.json> <backup-dir>

Objects merge key by key. Any other value in the overrides, lists included,
replaces the one in settings.json. Keys the overrides do not name are kept.
The previous file is copied to <backup-dir> before a changed one is written.
"""

import json
import shutil
import sys
from pathlib import Path


def merge(base, overrides):
    merged = dict(base)
    for key, value in overrides.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = merge(merged[key], value)
        else:
            merged[key] = value
    return merged


def apply(overrides_path, settings_path, backup_dir):
    """Return "ok", "created" or "merged"."""
    overrides = json.loads(overrides_path.read_text(encoding="utf-8"))
    # Writing through a dangling link would create a file at its target.
    dangling = settings_path.is_symlink() and not settings_path.exists()
    existed = settings_path.exists()
    base = {}
    if existed:
        try:
            base = json.loads(settings_path.read_text(encoding="utf-8"))
        except ValueError as error:
            raise SystemExit(f"{settings_path} is not valid JSON ({error}). Fix it, then run setup again.")
        if not isinstance(base, dict):
            raise SystemExit(f"{settings_path} does not hold a JSON object. Fix it, then run setup again.")
    merged = merge(base, overrides)
    if merged == base and not dangling:
        return "ok"
    if dangling:
        settings_path.unlink()
    elif existed:
        backup_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(settings_path, backup_dir / settings_path.name)
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    settings_path.write_text(json.dumps(merged, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return "merged" if existed else "created"


if __name__ == "__main__":
    print(apply(*(Path(arg) for arg in sys.argv[1:4])))
