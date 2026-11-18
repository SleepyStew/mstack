#!/usr/bin/env bash
# Link mstack into Claude Code and Codex. Safe to run again.
#
# Everything is a symlink into this clone, so `git pull` updates it. Run this
# again only after a pull adds or removes a skill. Anything already in the way
# is moved to <harness dir>/mstack-backup/<timestamp>/, never deleted.

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
  if [ -e "$target" ] || [ -L "$target" ]; then
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

# installed <command> <harness dir>
installed() {
  command -v "$1" >/dev/null 2>&1 || [ -d "$2" ]
}

claude_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
codex_home="${CODEX_HOME:-$HOME/.codex}"

if installed claude "$claude_home"; then
  echo "Claude Code ($claude_home)"
  link "$repo/global/AGENTS.md" "$claude_home/CLAUDE.md" "$claude_home"
  link "$repo/claude/settings.json" "$claude_home/settings.json" "$claude_home"
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
