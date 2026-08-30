#!/usr/bin/env bash
# link_omarchy_nvim_theme.sh — point Neovim's colorscheme at the Omarchy theme state.
#
# Omarchy's contract is that ~/.config/nvim/lua/plugins/theme.lua is a symlink to
# ~/.local/state/omarchy/current/theme/neovim.lua. `omarchy theme set` restages that
# target, and lazy.nvim's reloader (which stats through symlinks) fires User LazyReload,
# which lua/plugins/omarchy-theme-hotreload.lua turns into a live colorscheme swap.
#
# Because ~/.config/nvim/lua is a single stow symlink to this repo, the physical file
# lives in the lazyvim package — so the link is created there. It is absolute (a
# relative one would resolve against the repo, not $HOME) and therefore machine
# specific, which is why .gitignore untracks it.
#
# Usage:
#   ./link_omarchy_nvim_theme.sh            # create/repair the link
#   ./link_omarchy_nvim_theme.sh --dry-run  # preview without changes
#
# No-op on non-Omarchy hosts, so bootstrap.sh can call it unconditionally.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

readonly OMARCHY_STATE_DIR="${HOME}/.local/state/omarchy"
readonly STATE_TARGET="${OMARCHY_STATE_DIR}/current/theme/neovim.lua"
readonly LINK_PATH="${REPO_DIR}/lazyvim/nvim/.config/nvim/lua/plugins/theme.lua"

usage() {
  sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
  exit 1
}

log() {
  echo "  [nvim-theme] $*"
}

warn_if_unstaged() {
  [ -e "$STATE_TARGET" ] && return 0

  log "warning: $STATE_TARGET does not exist yet"
  log "         stage it with: omarchy-theme-refresh"
}

main() {
  local mode="real"

  case "${1:-}" in
    --dry-run) mode="dry" ;;
    "") ;;
    *) echo "unknown flag: $1" >&2; usage ;;
  esac

  if [ ! -d "$OMARCHY_STATE_DIR" ]; then
    log "not an Omarchy host ($OMARCHY_STATE_DIR missing) — skipping"
    return 0
  fi

  if [ -L "$LINK_PATH" ] && [ "$(readlink "$LINK_PATH")" = "$STATE_TARGET" ]; then
    log "already linked → $STATE_TARGET"
    warn_if_unstaged
    return 0
  fi

  if [ "$mode" = "dry" ]; then
    if [ -f "$LINK_PATH" ] && [ ! -L "$LINK_PATH" ]; then
      log "would back up regular file → ${LINK_PATH}.bak"
    fi
    log "would link $LINK_PATH → $STATE_TARGET"
    warn_if_unstaged
    return 0
  fi

  if [ -f "$LINK_PATH" ] && [ ! -L "$LINK_PATH" ]; then
    mv -f "$LINK_PATH" "${LINK_PATH}.bak"
    log "backed up regular file → ${LINK_PATH}.bak"
  fi

  ln -sfn "$STATE_TARGET" "$LINK_PATH"
  log "linked $LINK_PATH → $STATE_TARGET"
  warn_if_unstaged
}

main "$@"
