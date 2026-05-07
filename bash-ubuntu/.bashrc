# =============================================================================
# bash-ubuntu/.bashrc — for headless Ubuntu remote (atiwari@dev.passonwords.com)
# Stowed by bootstrap.sh's `ubuntu` profile.
#
# Top section: Ubuntu /etc/skel/.bashrc verbatim (history, prompt, ls aliases,
# bash-completion). Bottom section: shared toolchain activation (mise, zoxide,
# fzf, yazi) plus ssh-agent socket. Omarchy-specific paths are intentionally
# absent — see bash-omarchy/.bashrc for those.
# =============================================================================

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions in ~/.bash_aliases (optional)
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# =============================================================================
# Shared toolchain activation (kept aligned with bash-omarchy/.bashrc)
# =============================================================================

# cocoEd.sh — repo's portable alias/function pack (linked from setup/ stow package)
[ -f ~/.config/cocoEd.sh ] && source ~/.config/cocoEd.sh

# Point at the systemd-user ssh-agent socket. Prereq once per machine:
#   systemctl --user enable --now ssh-agent.socket
[ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket" ] \
  && export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"

# Ensure ~/.local/bin is on PATH first — mise, zoxide, fd/bat shims live here.
# Must come before the `command -v mise` check or activation silently no-ops.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Toolchain activation — guards keep shell startup clean if a tool isn't installed yet
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.config/composer/vendor/bin" ] && export PATH="$HOME/.config/composer/vendor/bin:$PATH"
command -v mise >/dev/null && eval "$(mise activate bash)"
# zoxide rebinds `cd` itself (not just `z`) — cd <partial> jumps to most-frecent match
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)"

# eza replaces ls — overrides the /etc/skel ls aliases set above
if command -v eza >/dev/null; then
  alias ls='eza'
  alias ll='eza -lah --git --group-directories-first'
  alias la='eza -A'
  alias l='eza -CF'
  alias tree='eza --tree'
fi

# fzf keybinds (Ubuntu ships them under /usr/share/doc/fzf/)
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && \
  source /usr/share/doc/fzf/examples/key-bindings.bash

# shell wrapper for yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
