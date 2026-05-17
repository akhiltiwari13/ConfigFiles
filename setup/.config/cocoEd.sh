#! /bin/sh
# my utility scripts.

if [[ "$(hostname)" == "akhils-MacBook-Air.local" ]]; then
  export work="${HOME}/files"
else
  export work="${HOME}/Work"
fi

export projects="${work}/projects"
export learn="${work}/learn"
export books="${work}/books"
export notes="${work}/notes"

alias work='cd ${work}'
alias proj='cd ${projects}'
alias learn='cd ${learn}'
alias loki='cd ${learn}/loki-lib'
alias notes='cd ${notes}'
alias books='cd ${books}'
alias ll='ls -larth'
alias quompt='cd ${projects}/quomptrade/'
alias alkimi='cd ${projects}/alkimi/'
alias softsol='cd ${projects}/softsolutions/'
alias cfg='cd ${quompt}/configfiles'
alias elaeox86='cd ${quompt}/elaeocarpus-x86'
alias elaeoarm='cd ${quompt}/elaeocarpus-arm'
alias indica='cd ${learn}/Indica'
alias cassia='cd ${learn}/CassiaFistula'
alias phyl='cd ${learn}/phyllanthus_emblica'
alias epi='cd ${projects}/EPIJudge'
alias tmc='cd ${projects}/The-Modern-Cpp-Challenge'
# alias cctx='cd ${projects}/elaeocarpus-arm/tools/scripts/codectx'
# alias cctxo='cd ${learn}/codectx_out'
alias jptlearn='cd ${learn}/algo-trading && uv run jupyter lab'

# pertaining to AQ setup.
alias pqr='cd ${quompt}/pqr'
alias plat='cd ${quompt}/platform'
alias platref='cd ${quompt}/platform_reference'
# alias aqprodlg='cd ${work}/aqprodlogs/'

# if command -v neofetch >/dev/null 2>&1; then
#   neofetch
# else
#   echo "Neofetch missing."
# fi
#
alias cocomessage="echo \"I love my dearest nephew, \"Coco\". He is the sweetest kid. He is very smart and creative. I wish him all the happiness. Lots of love.-Shivu Chachu\""

# eza — canonical ls/lt/tree shared across omarchy, ubuntu, macair
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias tree='eza --tree'
fi

# zd: literal cd to a real path, else zoxide-jump (mirrors Omarchy's default zd).
# `z` is provided by `zoxide init` later in each shell rc (resolved lazily at
# call time). Guard: skip if zd already exists (omarchy's default rc defines it,
# sourced before this file) so we never override the native omarchy version.
if ! typeset -f zd >/dev/null 2>&1; then
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then echo "Error: Directory not found"; return 1; fi
      printf "\U000F17A9 "; pwd
    fi
  }
  alias cd=zd
fi

#***********************
# catppuccin theme setup
#***********************
# export FZF_DEFAULT_OPTS=" \
# --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
# --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
# --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
# --color=selected-bg:#45475A \
# --color=border:#313244,label:#CDD6F4"

#********************
# work specific setup.
#********************
