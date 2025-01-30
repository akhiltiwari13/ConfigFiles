#! /bin/sh
# my utility scripts.

export files="${HOME}/files"
export projects="${files}/projects"
export learn="${files}/learn"
export books="${files}/books"
export notes="${files}/notes"

alias files='cd ${files}'
alias proj='cd ${projects}'
alias learn='cd ${learn}'
alias loki='cd ${learn}/loki-lib'
alias notes='cd ${notes}'
alias ll='ls -larth'
alias remproj62='cd ${projects}/remproj62'
alias cfg='cd ${projects}/ConfigFiles'
alias indica='cd ${projects}/Indica'
alias cassia='cd ${projects}/CassiaFistula'
alias phyl='cd ${projects}/phyllanthus_emblica'
alias elaeo='cd ${projects}/Elaeocarpus'
alias epi='cd ${projects}/EPIJudge'
alias tmc='cd ${projects}/The-Modern-Cpp-Challenge'
alias cctx='cd ${projects}/Elaeocarpus/tools/scripts/codectx'
alias cctxo='cd ${learn}/codectx_out'

# pertaining to AQ setup.
alias pqr='cd ${projects}/pqr'
alias plat='cd ${projects}/platform'
alias pqralt='cd ${projects}/plat_alternate_work/pqr'
alias platalt='cd ${projects}/plat_alternate_work/platform'
alias prodlg='cd ${learn}/prodlogs/'
alias prscp="echo 'scp prod@192.168.113.15:/home/prod/backup_logs/bidding/<date>/engine_<102|105>/platform_<date>.log.gz'"
alias mcxp7='ssh prod@192.168.113.7'
alias mcxp12='ssh prod@192.168.113.12'
alias mcxp15='ssh prod@192.168.113.15'
alias mcxp16='ssh prod@192.168.113.16'
alias nsep114='ssh prod@192.168.101.114'
alias nsep168='ssh prod@192.168.101.168'
# runs archiver for mcx in prod.
alias mcxp14='ssh prod@192.168.113.14'
# mcx test server (has gdb to debug it)
alias mcxt='ssh -Yv prod@132.1.16.192'
# devserver
alias dev132='ssh -Yv akhil@132.1.16.132'
alias dev62='ssh -Yv akhil@132.1.16.62'
alias rsyncplat='rsync -avz ${projects}/platform/ akhil@132.1.16.132:/home/akhil/files/projects/platform/'
alias rsyncpqr='rsync -avz ${projects}/pqr/ akhil@132.1.16.132:/home/akhil/files/projects/pqr/'
alias rsyncplatalt='rsync -avz ${projects}/plat_alternate_work/platform/ akhil@132.1.16.132:/home/akhil/files/projects/plat_alternate_work/platform/'
alias rsyncpqralt='rsync -avz ${projects}/plat_alternate_work/pqr/ akhil@132.1.16.132:/home/akhil/files/projects/plat_alternate_work/pqr/'

# cmake aliases
alias cmktmc="cmake -G 'Unix Makefiles' -DOPENSSL_ROOT_DIR=/opt/homebrew/Cellar/openssl@3/3.0.5/ -DOPENSSL_INCLUDE_DIR=/opt/homebrew/Cellar/openssl@3/3.0.5/include/ -DBUILD_TESTING=OFF -DBUILD_CURL_EXE=OFF -DUSE_MANUAL=OFF -DBOOST_FILESYSTEM=ON -DBOOST_OPTIONAL=ON -DBOOST_INCLUDE_DIR=/opt/homebrew/Cellar/boost/1.79.0_1/include/boost/ -DBOOST_LIB_DIR=/opt/homebrew/Cellar/boost/1.79.0_1/lib/ .."
alias cmkepi="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=True -DCMAKE_BUILD_TYPE=Debug ../epi_judge_cpp"

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
alias cores='cd /Cores/'

# aliases for reading
alias readepi='open -a Preview ${books}/Competitive\ Programming\ \&\ Interviews/Adnan\ Aziz,\ Tsung-Hsien\ Lee,\ Amit\ Prakash\ -\ Elements\ of\ Programming\ Interviews_\ The\ Insiders’\ Guide\ \(2015\).pdf'
alias readtmc='open -a Preview ${books}/C++/The\ Modern\ C++\ Challenge\ Become\ an\ expert\ programmer\ by\ solving\ real-world\ problems\ by\ Marius\ Bancila\ \(z-lib.org\).pdf'
alias book='open -a Preview ${books}/Competitive\ Programming\ \&\ Interviews/\(Undergraduate\ Topics\ in\ Computer\ Science\)\ Antti\ Laaksonen\ -\ Guide\ to\ Competitive\ Programming_\ Learning\ and\ Improving\ Algorithms\ Through\ Contests\ \(Undergraduate\ Topics\ in\ Computer\ Science\)-Springer\ \(2.pdf'

# export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

alias python='python3'
alias pip='pip3'

#********************
# work specific setup.
#********************
