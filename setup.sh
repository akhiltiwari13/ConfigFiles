#! /bin/sh
# my utility scripts.

export files="${HOME}/files"
export projects="${files}/projects"
export learn="${files}/learn"
export books="${files}/books"

alias files='cd ${files}'
alias proj='cd ${projects}'
alias learn='cd ${learn}'
alias ll='ls -lart'
alias cfg='cd ${projects}/ConfigFiles'
alias indica='cd ${projects}/Indica'
alias cassia='cd ${projects}/CassiaFistula'
alias phyl='cd ${projects}/phyllanthus_emblica'
alias epi='cd ${projects}/EPIJudge'
alias tmc='cd ${projects}/The-Modern-Cpp-Challenge'

# project editing aliases
alias cfgedit='cfg && nvim .'
alias indicaedit='indica && nvim .'
alias cassiaedit='cassia && nvim .'
alias phyledit='phyl && nvim .'
alias epiedit='epi && nvim .'
alias tmcedit='tmc && nvim .'
# vscode aliases
alias cfgcode='cfg && code .'
alias indicacode='indica && code .'
alias cassiacode='cassia && code .'
alias phylcode='phyl && code .'
alias epicode='epi && code .'
alias tmccode='tmc && code .'
# neovide aliases
alias cfgneo='cfg && neovide .'
alias indicaneo='indica && neovide .'
alias cassianeo='cassia && neovide .'
alias phylneo='phyl && neovide .'
alias epineo='epi && neovide .'
alias tmcneo='tmc && neovide .'

# aliases for reading
alias readepi='open -a Preview ${books}/Competitive\ Programming\ \&\ Interviews/Adnan\ Aziz,\ Tsung-Hsien\ Lee,\ Amit\ Prakash\ -\ Elements\ of\ Programming\ Interviews_\ The\ Insiders’\ Guide\ \(2015\).pdf'
alias readtmc='open -a Preview ${books}/C++/The\ Modern\ C++\ Challenge\ Become\ an\ expert\ programmer\ by\ solving\ real-world\ problems\ by\ Marius\ Bancila\ \(z-lib.org\).pdf'
alias book='open -a Preview ${books}/Competitive\ Programming\ \&\ Interviews/\(Undergraduate\ Topics\ in\ Computer\ Science\)\ Antti\ Laaksonen\ -\ Guide\ to\ Competitive\ Programming_\ Learning\ and\ Improving\ Algorithms\ Through\ Contests\ \(Undergraduate\ Topics\ in\ Computer\ Science\)-Springer\ \(2.pdf'

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

