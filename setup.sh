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
DEST_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
)

source "$ROOT_DIR/setup/lib.sh"

prepare_destination() {
  local dest_dir="$1"

  if [ -d "$dest_dir" ]; then
    return 0
  fi

  if [ -e "$dest_dir" ] || [ -L "$dest_dir" ]; then
    warn "Skills destination is not a directory; leaving unchanged: $dest_dir"
    return 1
  fi

  mkdir -p "$dest_dir"
  success "Created → $dest_dir"
}

is_exact_link_to() {
  local source="$1"
  local destination="$2"

  [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]
}

is_managed_link() {
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

remove_managed_links() {
  local dest_dir="$1"
  local mode="$2"
  local path
  local target

  [ -d "$dest_dir" ] || return 0

  while IFS= read -r -d '' path; do
    is_managed_link "$path" || continue
    target="$(readlink "$path")"

    if [ "$mode" = "stale" ] && [ -f "$target/SKILL.md" ]; then
      continue
    fi

    rm -f "$path"
    success "Unlinked → $path"
  done < <(find "$dest_dir" -mindepth 1 -maxdepth 1 -type l -print0)
}

link_skill() {
  local skill_dir="$1"
  local dest_dir="$2"
  local skill_name
  local dest

  skill_name="$(basename "$skill_dir")"
  dest="$dest_dir/$skill_name"

  if is_exact_link_to "$skill_dir" "$dest"; then
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    warn "Skill already exists; leaving unchanged: $dest"
    return 0
  fi

  ln -s "$skill_dir" "$dest"
  success "Linked → $dest"
}

enable() {
  local dest_dir
  local skill_dir
  local failed=0

  for dest_dir in "${DEST_DIRS[@]}"; do
    if ! prepare_destination "$dest_dir"; then
      failed=1
      continue
    fi

    remove_managed_links "$dest_dir" stale

    for skill_dir in "$SKILLS_DIR"/*; do
      [ -d "$skill_dir" ] || continue

      if [ ! -f "$skill_dir/SKILL.md" ]; then
        warn "Skipping directory without SKILL.md: $skill_dir"
        continue
      fi

      link_skill "$skill_dir" "$dest_dir"
    done
  done

  return "$failed"
}

disable() {
  local dest_dir

  for dest_dir in "${DEST_DIRS[@]}"; do
    remove_managed_links "$dest_dir" all
  done
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
