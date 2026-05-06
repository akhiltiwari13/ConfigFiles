# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Default Omarchy aliases and functions (Arch-only path; guarded for Ubuntu remote)
# Don't edit these directly — override them below.
[ -f ~/.local/share/omarchy/default/bash/rc ] && source ~/.local/share/omarchy/default/bash/rc
[ -f ~/.config/cocoEd.sh ] && source ~/.config/cocoEd.sh
# Point at the systemd-user ssh-agent socket (Arch/omarchy and Ubuntu both use this path).
# Prereq once per machine: systemctl --user enable --now ssh-agent.socket
[ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket" ] \
  && export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"

# Add your own exports, aliases, and functions here.
# Make an alias for invoking commands you use constantly
# alias p='python'

# Toolchain activation — each guard avoids breaking shell startup if the tool isn't installed yet
[ -f "$HOME/.local/share/../bin/env" ] && . "$HOME/.local/share/../bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.config/composer/vendor/bin" ] && export PATH="$HOME/.config/composer/vendor/bin:$PATH"
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v starship >/dev/null && eval "$(starship init bash)"
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
