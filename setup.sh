#!/usr/bin/env bash
# Link mstack's skills into Claude Code and Codex. Safe to run again.
#
# The skills are symlinks into this clone, so `git pull` updates them. Run
# this again after a pull adds or removes a skill. A file or folder already in
# the way is moved to <harness dir>/mstack-backup/<timestamp>/, never deleted.
# A link in the way is replaced. remove.sh takes the links out.
#
# The global instructions and the settings are personal, so they are left
# alone unless asked for:
#   --apply-instructions  link global/AGENTS.md in as the global instructions
#   --apply-settings      merge claude/settings-overrides.json into Claude
#                         Code's settings.json, which stays a regular file and
#                         is copied to the backup folder before it changes
#   --all                 both of the above
#   --dry-run             print what a run would do and change nothing

set -euo pipefail

apply_instructions=false
apply_settings=false
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --apply-instructions) apply_instructions=true ;;
    --apply-settings) apply_settings=true ;;
    --all) apply_instructions=true; apply_settings=true ;;
    --dry-run) dry_run=true ;;
    *) echo "Usage: setup.sh [--apply-instructions] [--apply-settings] [--all] [--dry-run]" >&2; exit 2 ;;
  esac
done

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
    $dry_run || rm "$target"
  elif [ -e "$target" ]; then
    local backup="$home/mstack-backup/$stamp/${target#"$home"/}"
    $dry_run || { mkdir -p "$(dirname "$backup")"; mv "$target" "$backup"; }
    echo "  backup  $target -> $backup"
  fi
  $dry_run || { mkdir -p "$(dirname "$target")"; ln -s "$source" "$target"; }
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
        "$repo"/skills/*) $dry_run || rm "$entry"; echo "  removed $entry (skill no longer in mstack)" ;;
      esac
    fi
  done
}

# merge_settings <harness dir>
merge_settings() {
  local home="$1" result
  if $dry_run; then
    echo "  merge   $home/settings.json (a dry run does not compare it)"
    return
  fi
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
  if $apply_settings && ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is needed to merge the settings overrides." >&2
    exit 1
  fi
  echo "Claude Code ($claude_home)"
  if $apply_instructions; then link "$repo/global/AGENTS.md" "$claude_home/CLAUDE.md" "$claude_home"; fi
  if $apply_settings; then merge_settings "$claude_home"; fi
  link_skills "$claude_home"
else
  echo "Claude Code: not installed, skipped. Run this again once it is."
fi

if installed codex "$codex_home"; then
  echo "Codex ($codex_home)"
  if $apply_instructions; then link "$repo/global/AGENTS.md" "$codex_home/AGENTS.md" "$codex_home"; fi
  link_skills "$codex_home"
else
  echo "Codex: not installed, skipped. Run this again once it is."
fi

if ! $apply_instructions; then
  echo "Your global instructions were not touched. To link global/AGENTS.md in as them, run this with --apply-instructions."
fi
if ! $apply_settings; then
  echo "Claude Code's settings.json was not touched. To merge claude/settings-overrides.json into it, run this with --apply-settings."
fi
if $dry_run; then
  echo "Dry run: nothing was changed. The lines above are what a real run would do."
else
  echo "Done. New sessions pick this up. Sessions already running keep what they loaded."
fi
