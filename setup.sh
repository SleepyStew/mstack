#!/usr/bin/env bash
# Link mstack into Claude Code and Codex. Safe to run again.
#
# The instructions and skills are symlinks into this clone, so `git pull`
# updates them. Claude Code's settings.json stays a regular file, and the keys
# in claude/settings-overrides.json are merged into it. Run this again after a
# pull adds or removes a skill or changes the overrides. A file or folder
# already in the way is moved to <harness dir>/mstack-backup/<timestamp>/,
# never deleted, and settings.json is copied there before it changes. A link
# in the way is replaced.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
stamp="$(date +%Y%m%d-%H%M%S)"

# link <source> <target> <harness dir>
link() {
  local source="$1" target="$2" home="$3"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "  ok      $target"
    return
  fi
  if [ -L "$target" ]; then
    # A link pointing somewhere else. Removing a link leaves its target alone.
    rm "$target"
  elif [ -e "$target" ]; then
    local backup="$home/mstack-backup/$stamp/${target#"$home"/}"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    echo "  backup  $target -> $backup"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "  linked  $target"
}

# Link every skill, then drop links to skills this clone no longer has.
link_skills() {
  local home="$1" skill entry
  for skill in "$repo"/skills/*/; do
    skill="${skill%/}"
    link "$skill" "$home/skills/$(basename "$skill")" "$home"
  done
  for entry in "$home"/skills/*; do
    if [ -L "$entry" ] && [ ! -e "$entry" ]; then
      case "$(readlink "$entry")" in
        "$repo"/skills/*) rm "$entry"; echo "  removed $entry (skill no longer in mstack)" ;;
      esac
    fi
  done
}

# merge_settings <harness dir>
merge_settings() {
  local home="$1" result
  result="$(python3 "$repo/claude/merge_settings.py" "$repo/claude/settings-overrides.json" \
    "$home/settings.json" "$home/mstack-backup/$stamp")"
  printf '  %-7s %s\n' "$result" "$home/settings.json"
}

# installed <command> <harness dir>
installed() {
  command -v "$1" >/dev/null 2>&1 || [ -d "$2" ]
}

claude_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
codex_home="${CODEX_HOME:-$HOME/.codex}"

if installed claude "$claude_home"; then
  # Checked before the first change, so a machine without it is not left half set up.
  command -v python3 >/dev/null 2>&1 || { echo "python3 is needed to merge the settings overrides." >&2; exit 1; }
  echo "Claude Code ($claude_home)"
  link "$repo/global/AGENTS.md" "$claude_home/CLAUDE.md" "$claude_home"
  merge_settings "$claude_home"
  link_skills "$claude_home"
else
  echo "Claude Code: not installed, skipped. Run this again once it is."
fi

if installed codex "$codex_home"; then
  echo "Codex ($codex_home)"
  link "$repo/global/AGENTS.md" "$codex_home/AGENTS.md" "$codex_home"
  link_skills "$codex_home"
else
  echo "Codex: not installed, skipped. Run this again once it is."
fi

echo "Done. New sessions pick this up. Sessions already running keep what they loaded."
