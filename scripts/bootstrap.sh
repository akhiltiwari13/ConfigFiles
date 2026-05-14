#!/usr/bin/env bash
# bootstrap.sh — stow the right subset of packages for a machine profile.
#
# Profile-aware stow runner. Run from anywhere; the script resolves the
# repo root via its own location.
#
# Usage:
#   ./bootstrap.sh <profile>            # stow the profile's packages
#   ./bootstrap.sh <profile> --dry-run  # preview without changes
#   ./bootstrap.sh <profile> --list     # just print the package list
#
# Profiles:
#   ubuntu   — headless remote (no GUI/Wayland packages)
#   omarchy  — Arch + Hyprland workstation (full set)
#   macair   — macOS Air (cross-platform + Mac-only apps)
#
# Pre-reqs: git, stow installed.
# First-time setup: run `stow stow` once manually to seed ~/.stowrc;
# then this script handles everything else. For deps install, see
# scripts/deps_install.sh.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Per-profile package lists. Source of truth for "what's installed where".
# Keep alphabetised within each section for diff-friendliness.

readonly UBUNTU_PKGS=(
  bash-ubuntu btop ccls clangd claudecode gitconfig
  lazydocker lazygit lazyvim mise opencode ripgrep-all setup
  ssh tmux
)

readonly OMARCHY_PKGS=(
  # cross-platform core
  bash-omarchy btop ccls clangd claudecode ghostty gitconfig
  lazydocker lazygit lazyvim mise opencode ripgrep-all setup
  ssh tmux vimium
  # Omarchy-specific (Wayland/Hyprland stack + omarchy-* infra)
  alacritty fastfetch omarchy-hyprland omarchy-overrides omarchy-themes
  rofi vpn wallpapers waybar zathura
)

readonly MACAIR_PKGS=(
  # cross-platform core
  bash-omarchy btop ccls clangd claudecode ghostty gitconfig
  lazydocker lazygit lazyvim mise opencode ripgrep-all setup
  ssh tmux vimium
  # macOS-specific
  wezterm zsh
)

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
  exit 1
}

resolve_pkgs() {
  case "$1" in
    ubuntu)  printf '%s\n' "${UBUNTU_PKGS[@]}" ;;
    omarchy) printf '%s\n' "${OMARCHY_PKGS[@]}" ;;
    macair)  printf '%s\n' "${MACAIR_PKGS[@]}" ;;
    *)
      echo "unknown profile: $1" >&2
      usage
      ;;
  esac
}

run_stow() {
  local pkg="$1"
  local mode="$2"  # "dry" or "real"
  local flags=(-v)
  [ "$mode" = "dry" ] && flags+=(-n)

  # Special case: lazyvim has intentional extra nesting; real stow is
  # `stow -d <repo>/lazyvim nvim`, not `stow lazyvim`.
  if [ "$pkg" = "lazyvim" ]; then
    cd "$REPO_DIR" && stow "${flags[@]}" -d "$REPO_DIR/lazyvim" nvim 2>&1 | sed "s/^/  [$pkg] /"
  else
    cd "$REPO_DIR" && stow "${flags[@]}" "$pkg" 2>&1 | sed "s/^/  [$pkg] /"
  fi
}

main() {
  local profile="${1:-}"
  local mode="real"
  [ -z "$profile" ] && usage

  case "${2:-}" in
    --dry-run) mode="dry" ;;
    --list)
      resolve_pkgs "$profile"
      exit 0
      ;;
    "") ;;
    *) echo "unknown flag: $2" >&2; usage ;;
  esac

  command -v stow >/dev/null 2>&1 || { echo "error: stow not installed" >&2; exit 1; }

  local pkgs=()
  while IFS= read -r line; do pkgs+=("$line"); done < <(resolve_pkgs "$profile")

  echo "profile: $profile (${#pkgs[@]} packages)"
  echo "repo:    $REPO_DIR"
  [ "$mode" = "dry" ] && echo "mode:    dry-run (no changes)"
  echo ""

  local pkg
  for pkg in "${pkgs[@]}"; do
    run_stow "$pkg" "$mode"
  done

  echo ""
  echo "✓ done"
}

main "$@"
