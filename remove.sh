#!/usr/bin/env bash
# Take mstack's links out of Claude Code and Codex. Safe to run again.
#
# Only links that point into this clone are removed. Where setup moved a file
# or folder aside to make room for a link, the newest copy in mstack-backup is
# moved back. settings.json keeps any overrides that setup merged, since it
# may have changed since and putting an old copy back would lose that.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# unlink <harness dir> <instructions file name>
unlink_all() {
  local home="$1" entry backup newest
  [ -d "$home" ] || return 0
  echo "$home"
  for entry in "$home/$2" "$home"/skills/*; do
    [ -L "$entry" ] || continue
    case "$(readlink "$entry")" in
      "$repo"/global/AGENTS.md | "$repo"/skills/*) ;;
      *) continue ;;
    esac
    rm "$entry"
    echo "  removed  $entry"
    # Backup folders are named by timestamp, so the last match is the newest.
    newest=""
    for backup in "$home"/mstack-backup/*/"${entry#"$home"/}"; do
      if [ -e "$backup" ] || [ -L "$backup" ]; then newest="$backup"; fi
    done
    if [ -n "$newest" ]; then
      mv "$newest" "$entry"
      echo "  restored $entry (from $newest)"
    fi
  done
}

unlink_all "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" CLAUDE.md
unlink_all "${CODEX_HOME:-$HOME/.codex}" AGENTS.md

echo "Done. settings.json was not touched, and its earlier copies are in mstack-backup. Sessions already running keep what they loaded."
