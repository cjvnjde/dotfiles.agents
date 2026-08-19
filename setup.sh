#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

resolve_script_path() {
  local path="$1"

  if command -v realpath >/dev/null 2>&1; then
    realpath "$path" 2>/dev/null && return
  fi

  if command -v readlink >/dev/null 2>&1; then
    readlink -f "$path" 2>/dev/null && return
  fi

  local dir
  dir="$(cd -P "$(dirname "$path")" && pwd)"
  printf '%s/%s\n' "$dir" "$(basename "$path")"
}

SCRIPT_PATH="$(resolve_script_path "${BASH_SOURCE[0]}")"
MODULE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
ROOT_DIR="$(cd "$MODULE_DIR/.." && pwd -P)"
SKILLS_DIR="$MODULE_DIR/skills"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
STATE_FILE="$STATE_DIR/agents-skills"
TARGET_AGENTS=(
  pi
  codex
  claude-code
  zed
  universal
)
LEGACY_DEST_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
)

source "$ROOT_DIR/setup/lib.sh"

require_npx() {
  if ! command -v npx >/dev/null 2>&1; then
    error "npx is required to install agent skills"
    return 1
  fi
}

collect_skills() {
  local skill_dir

  for skill_dir in "$SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue

    if [ ! -f "$skill_dir/SKILL.md" ]; then
      warn "Skipping directory without SKILL.md: $skill_dir" >&2
      continue
    fi

    basename "$skill_dir"
  done
}

is_legacy_managed_link() {
  local path="$1"
  local target
  local relative

  [ -L "$path" ] || return 1
  target="$(readlink "$path")" || return 1

  case "$target" in
    "$SKILLS_DIR"/*)
      relative="${target#"$SKILLS_DIR"/}"
      case "$relative" in
        ""|*/*) return 1 ;;
        *) return 0 ;;
      esac
      ;;
    *) return 1 ;;
  esac
}

remove_legacy_links() {
  local dest_dir
  local path

  for dest_dir in "${LEGACY_DEST_DIRS[@]}"; do
    [ -d "$dest_dir" ] || continue

    while IFS= read -r -d '' path; do
      is_legacy_managed_link "$path" || continue
      rm -f "$path"
      success "Removed legacy link → $path"
    done < <(find "$dest_dir" -mindepth 1 -maxdepth 1 -type l -print0)
  done
}

remove_skills() {
  [ "$#" -gt 0 ] || return 0

  require_npx
  npx --yes skills@latest remove --global --yes "$@"
}

enable() {
  local skill
  local current_skill
  local found
  local -a current_skills=()
  local -a previous_skills=()
  local -a stale_skills=()

  require_npx
  mapfile -t current_skills < <(collect_skills)

  if [ "${#current_skills[@]}" -eq 0 ]; then
    warn "No skills found in $SKILLS_DIR"
    return 0
  fi

  if [ -f "$STATE_FILE" ]; then
    mapfile -t previous_skills < <(sed '/^[[:space:]]*$/d' "$STATE_FILE")
  fi

  for skill in "${previous_skills[@]}"; do
    found=0
    for current_skill in "${current_skills[@]}"; do
      if [ "$skill" = "$current_skill" ]; then
        found=1
        break
      fi
    done
    [ "$found" -eq 1 ] || stale_skills+=("$skill")
  done

  remove_legacy_links
  remove_skills "${stale_skills[@]}"

  npx --yes skills@latest add "$MODULE_DIR" \
    --global \
    --skill '*' \
    --agent "${TARGET_AGENTS[@]}" \
    --yes

  mkdir -p "$STATE_DIR"
  printf '%s\n' "${current_skills[@]}" > "$STATE_FILE"
}

disable() {
  local -a installed_skills=()

  remove_legacy_links

  if [ -f "$STATE_FILE" ]; then
    mapfile -t installed_skills < <(sed '/^[[:space:]]*$/d' "$STATE_FILE")
    remove_skills "${installed_skills[@]}"
    rm -f "$STATE_FILE"
    rmdir "$STATE_DIR" 2>/dev/null || true
  fi
}

case "${1:-}" in
  enable)
    enable
    ;;
  disable)
    disable
    ;;
  *)
    error "Usage: bash $MODULE_DIR/setup.sh <enable|disable>"
    exit 1
    ;;
esac
