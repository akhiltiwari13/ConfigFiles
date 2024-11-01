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
alias notes='cd ${notes}'
alias ll='ls -larth'
alias cfg='cd ${projects}/ConfigFiles'
alias indica='cd ${projects}/Indica'
alias cassia='cd ${projects}/CassiaFistula'
alias phyl='cd ${projects}/phyllanthus_emblica'
alias elaeo='cd ${projects}/Elaeocarpus'
alias epi='cd ${projects}/EPIJudge'
alias tmc='cd ${projects}/The-Modern-Cpp-Challenge'
alias cctx='cd ${projects}/myscripts/codectx'

# cmake aliases
alias cmktmc='cmake -G 'Unix Makefiles' -DOPENSSL_ROOT_DIR=/opt/homebrew/Cellar/openssl@3/3.0.5/ -DOPENSSL_INCLUDE_DIR=/opt/homebrew/Cellar/openssl@3/3.0.5/include/ -DBUILD_TESTING=OFF -DBUILD_CURL_EXE=OFF -DUSE_MANUAL=OFF -DBOOST_FILESYSTEM=ON -DBOOST_OPTIONAL=ON -DBOOST_INCLUDE_DIR=/opt/homebrew/Cellar/boost/1.79.0_1/include/boost/ -DBOOST_LIB_DIR=/opt/homebrew/Cellar/boost/1.79.0_1/lib/ ..'
alias cmkepi='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=True -DCMAKE_BUILD_TYPE=Debug ../epi_judge_cpp'

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

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

alias python='python3'
alias pip='pip3'

#********************
#work specific setup.
#********************

hostname=$(hostname)
desired_hostname="some workspace hostname"

if [ "$hostname" = "$desired_hostname" ]; then
    echo "initiating work setup"
    #start mutagen for workspace syncing.
    # mutagen daemon register # registers mutagen with launchd to start it on system start.
    # mutagen daemon start

    alias sshme='killall ssh-agent; ssh-add -s /usr/local/lib/opensc-pkcs11.so'

    #to enable look-up of packages installed via homebrew before their default couterparts. 
    export PATH="/Users/akhil.tiwari/files/projects/gemini/akhil/scripts/:$PATH"
    # export TERM=xterm-256color
    export EDITOR='nvim'

    # work specific alias.
    alias wsna="ssh  aws_dev"
    alias wsapac="ssh  aws_apac_dev"
    alias qa="ssh  gateway-qa100-001a.aws-qa.host.gem.link"
    alias qahub="ssh hub-admin-qa100-001.aws-qa.host.gem.link"
    alias qale="ssh trading-worker-qa100-006.aws-qa.host.gem.link"

    fssh() {
        # killall ssh-agent
        ssh-agent > ~/.ssh-agent
        source ~/.ssh-agent
        sleep 1
        ssh-add -s /usr/local/lib/opensc-pkcs11.so
    }

    if [ -f ~/.ssh-agent ]; then
        source ~/.ssh-agent
    fi
    #call fssh on shell start-up.
    fssh


else
    echo "hostname: $hostname" 
fi
