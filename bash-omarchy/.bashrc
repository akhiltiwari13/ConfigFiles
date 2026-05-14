# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Default Omarchy aliases and functions (Arch-only path; guarded for Ubuntu remote)
# Don't edit these directly — override them below.
[ -f ~/.local/share/omarchy/default/bash/rc ] && source ~/.local/share/omarchy/default/bash/rc
[ -f ~/.config/cocoEd.sh ] && source ~/.config/cocoEd.sh
# Point at the systemd-user ssh-agent socket (Arch/omarchy and Ubuntu both use this path).
# Prereq once per machine: systemctl --user enable --now ssh-agent.socket
[ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket" ] &&
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"

# Add your own exports, aliases, and functions here.
# Make an alias for invoking commands you use constantly
# alias p='python'

# Drop into a persistent tmux session on the qomp remote — survives disconnects.
# `-A` attaches if "main" exists, else creates it. `-t` allocates a TTY.
alias quompt='ssh -t quompt "tmux new-session -A -s muxy-qblr"'

# Per-app GUI forwarding from uburemote via xpra. Spawns a virtual display on
# the server, launches one app into it, forwards the window over SSH. Persistent
# across SSH disconnects, reattachable from a different client. All four helpers
# share display :100 so xrejoin from any machine finds the same session.
if command -v xpra >/dev/null 2>&1; then
  xrun()    { xpra start ssh://quompt/100 --start="${*:?usage: xrun <command> [args...]}" --exit-with-children=no; }
  xrejoin() { xpra attach ssh://quompt/100; }
  xls()     { xpra list ssh://quompt/; }
  xstop()   { xpra stop ssh://quompt/100; }
fi

# Ensure ~/.local/bin is on PATH first — mise, zoxide, starship symlinks, fd/bat shims live here.
# Must come before the `command -v mise` check below or mise activation silently no-ops.
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Toolchain activation — each guard avoids breaking shell startup if the tool isn't installed yet
[ -f "$HOME/.local/share/../bin/env" ] && . "$HOME/.local/share/../bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.config/composer/vendor/bin" ] && export PATH="$HOME/.config/composer/vendor/bin:$PATH"
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# fzf keybinds (Arch and Ubuntu ship them at different paths)
for _fzf_kb in /usr/share/fzf/key-bindings.bash /usr/share/doc/fzf/examples/key-bindings.bash; do
  [ -f "$_fzf_kb" ] && source "$_fzf_kb" && break
done
unset _fzf_kb

# shell wrapper for yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# rga inherits rg's RIPGREP_CONFIG_PATH (color flags etc). See ~/.ripgreprc.
[ -f "$HOME/.ripgreprc" ] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# bs <query> — search the ebook library with rga, pick a hit in fzf,
# open it in zathura at the matching page (PDFs) or page 1 (EPUBs).
# Override the search root with $BOOKS_ROOT.
bs() {
  local root="${BOOKS_ROOT:-$HOME/Work/books/book-inventory/readables}"
  case "${1-}" in
    ''|-h|--help)
      cat <<'EOF'
bs — book search: rga | fzf | zathura

USAGE
  bs <query> [rga-flags...]
  BOOKS_ROOT=<dir> bs <query>

EXAMPLES
  bs concurrency                       # full-text search readables/
  bs -F "Bjarne Stroustrup"            # fixed-string (no regex)
  bs -i memory                         # case-insensitive
  bs -t pdf "lock free"                # restrict to PDFs
  BOOKS_ROOT=~/Work/books/for-elaeocarpus bs networking

KEYS (in fzf picker)
  Enter  open match in zathura at the matching page (PDFs)
  Esc    cancel

ENV
  BOOKS_ROOT   search root (default: ~/Work/books/book-inventory/readables)

NOTES
  • Cache lives at ~/.cache/ripgrep-all/. First search is slow.
  • Append --rga-no-cache to bypass the cache for one call.
  • Colors / --smart-case live in ~/.ripgreprc.
EOF
      return 0 ;;
  esac
  command -v rga >/dev/null || { echo "rga not installed" >&2; return 127; }
  command -v fzf >/dev/null || { echo "fzf not installed" >&2; return 127; }

  local sel
  sel=$(rga --no-heading -H --color=always "$@" "$root" 2>/dev/null |
    fzf --ansi \
        --delimiter=: \
        --tiebreak=begin \
        --preview-window='right:60%:wrap' \
        --preview='
          file=$(printf "%s" {} | sed -E "s/\x1b\[[0-9;]*m//g" | cut -d: -f1)
          page=$(printf "%s" {} | sed -E "s/\x1b\[[0-9;]*m//g" | grep -oE "Page [0-9]+" | head -1 | grep -oE "[0-9]+")
          case "$file" in
            *.pdf) pdftotext -f "${page:-1}" -l "${page:-1}" "$file" - 2>/dev/null | head -200 ;;
            *)     printf "%s\n" {} ;;
          esac') || return 130

  local clean file page
  clean=$(sed -E 's/\x1b\[[0-9;]*m//g' <<<"$sel")
  file=$(cut -d: -f1 <<<"$clean")
  page=$(grep -oE 'Page [0-9]+' <<<"$clean" | head -1 | grep -oE '[0-9]+')
  [ -z "$file" ] && return 1
  if [ -n "$page" ]; then
    zathura -P "$page" "$file" >/dev/null 2>&1 &
  else
    zathura "$file" >/dev/null 2>&1 &
  fi
  disown
}
