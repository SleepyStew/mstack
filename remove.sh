#!/usr/bin/env bash
# Take mstack's links out of Claude Code and Codex. Safe to run again.
#
# Only links that point into this clone are removed. settings.json keeps any
# overrides that setup merged, since it may have changed since and putting an
# old copy back would lose that. The mstack-backup folders stay, so their
# contents can be put back by hand.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# unlink <harness dir> <instructions file name>
unlink_all() {
  local home="$1" entry
  [ -d "$home" ] || return 0
  echo "$home"
  for entry in "$home/$2" "$home"/skills/*; do
    if [ -L "$entry" ]; then
      case "$(readlink "$entry")" in
        "$repo"/global/AGENTS.md | "$repo"/skills/*) rm "$entry"; echo "  removed $entry" ;;
      esac
    fi
  done
  if [ -d "$home/mstack-backup" ]; then
    echo "  What setup moved aside is still in $home/mstack-backup"
  fi
}

unlink_all "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" CLAUDE.md
unlink_all "${CODEX_HOME:-$HOME/.codex}" AGENTS.md

echo "Done. settings.json was not touched. Sessions already running keep what they loaded."
