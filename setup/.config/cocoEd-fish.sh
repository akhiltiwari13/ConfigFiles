#my utility scripts.

set -gx files "$HOME/files"
set -gx projects "$files/projects"
set -gx learn "$files/learn"
set -gx books "$files/books n docs"
set -gx notes "$files/notes"

alias files="cd \$files"
alias proj="cd \$projects"
alias learn="cd \$learn"
alias loki="cd \$learn/loki-lib"
alias notes="cd \$notes"
alias books="cd \"\$books\""
alias ll="ls -larth"
alias cfg="cd \$projects/ConfigFiles"
alias indica="cd \$projects/Indica"
alias cassia="cd \$projects/CassiaFistula"
alias phyl="cd \$projects/phyllanthus_emblica"
alias elaeo="cd \$projects/Elaeocarpus"
alias epi="cd \$projects/EPIJudge"
alias tmc="cd \$projects/The-Modern-Cpp-Challenge"
alias cctx="cd \$projects/Elaeocarpus/tools/scripts/codectx"
alias cctxo="cd \$learn/codectx_out"

# work setup
alias pqr="cd \$projects/pqr"
alias plat="cd \$projects/platform"
alias platref="cd \$projects/platform_reference"
alias aqprodlg="cd \$files/aqprodlogs/"

if command -v neofetch >/dev/null 2>&1
  neofetch
else if command -v fastfetch >/dev/null 2>&1
  fastfetch
else
  echo "Fastfetch/Neofetch missing."
end
alias cocomessage="echo \"I love my dearest nephew, \"Coco\". He is the sweetest kid. He is very smart and creative. I wish him all the happiness. Lots of love.-Shivu Chachu\""

#***********************
# catppuccin theme setup
#***********************
# set -gx FZF_DEFAULT_OPTS "\
# --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
# --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
# --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
# --color=selected-bg:#45475A \
# --color=border:#313244,label:#CDD6F4"

set -gx FZF_DEFAULT_OPTS "\
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
#********************
# work specific setup.
#********************
