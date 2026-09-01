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
# On the omarchy profile, this also runs
# scripts/link_omarchy_nvim_theme.sh after stowing, which points Neovim's
# colorscheme at the Omarchy theme state.
#
# Pre-reqs: git, stow installed. First-time setup: run `stow stow` once
# manually to seed ~/.stowrc; then this script handles everything else.
# For deps install, see scripts/deps_install.sh.

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
  bash-omarchy btop ccls clangd claudecode conan ghostty gitconfig
  lazydocker lazygit lazyvim mise opencode ripgrep-all setup
  ssh tmux vimium
  # Omarchy-specific (Wayland/Hyprland stack + omarchy-* infra)
  # herdr + omarchy-shell are Omarchy 4 ("quattro") tools; waybar and
  # omarchy-themes retired to dumpyard/ when quickshell replaced waybar.
  alacritty fastfetch foot gwq herdr omarchy-hyprland omarchy-overrides omarchy-shell
  rofi starship voxtype vpn wallpapers zathura
)

readonly MACAIR_PKGS=(
  # cross-platform core (Mac is zsh-only — bash-omarchy intentionally excluded)
  btop ccls clangd claudecode conan ghostty gitconfig
  lazydocker lazygit lazyvim mise opencode ripgrep-all setup
  ssh tmux vimium zathura
  # macOS-specific
  wezterm zsh
)

usage() {
  sed -n '2,23p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
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

# Stow may only ever run from the PRIMARY worktree.
#
# Every live symlink in $HOME (~/.bashrc, ~/.config/hypr, ~/.config/foot/foot.ini,
# ~/.stowrc itself) holds an ABSOLUTE path into whichever tree was stowed last.
# Stowing from a parallel-agent worktree silently repoints $HOME at that worktree;
# deleting it afterwards then breaks the shell, Hyprland and the terminal. And
# `stow --adopt` from a worktree pulls live files in, reverting tracked config.
#
# The test is path-independent: in the primary worktree the per-worktree gitdir and
# the shared object store are the same directory; in a linked worktree the gitdir is
# <common>/worktrees/<name>. See "Parallel worktrees" in AGENTS.md.
require_primary_worktree() {
  git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1 || return 0  # not a repo: nothing to guard

  local gitdir common
  gitdir="$(git -C "$REPO_DIR" rev-parse --absolute-git-dir)"
  common="$(cd "$REPO_DIR" && realpath "$(git rev-parse --git-common-dir)")"
  [ "$gitdir" = "$common" ] && return 0

  cat >&2 <<EOF
error: refusing to stow from a linked worktree.

  this tree : $REPO_DIR
  primary   : $(dirname "$common")

Stowing here would repoint your live \$HOME symlinks (~/.bashrc, ~/.config/hypr,
~/.config/foot/foot.ini, ~/.stowrc) at this worktree. Deleting the worktree would
then break your shell, window manager and terminal.

Worktrees are edit-and-commit only. Merge into main, then stow from the primary:

  cd $(dirname "$common") && ./scripts/bootstrap.sh $*
EOF
  exit 1
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

  # Guard runs for --dry-run too: the dry-run is the rehearsal, so it must fail
  # in the same place the real thing would. --list exited above and stays usable
  # from anywhere, since listing touches nothing.
  require_primary_worktree "$profile" "${2:-}"

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

  # Omarchy owns the Neovim colorscheme via a symlink stow cannot create.
  if [ "$profile" = "omarchy" ]; then
    echo ""
    if [ "$mode" = "dry" ]; then
      "${SCRIPT_DIR}/link_omarchy_nvim_theme.sh" --dry-run
    else
      "${SCRIPT_DIR}/link_omarchy_nvim_theme.sh"
    fi
  fi

  echo ""
  echo "✓ done"
}

main "$@"
