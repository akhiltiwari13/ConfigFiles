# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

# for scaling in i3wm
# export QT_AUTO_SCREEN_SCALE_FACTOR=0
# export QT_SCREEN_SCALE_FACTORS=2 
# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5

# Use Neovim as "preferred editor"
export VISUAL=nvim

# Use Neovim instead of Vim or Vi
alias vim=nvim
alias vi=nvim

# fzf related variables.
# export PATH=$PATH:/home/akhil/files/projects/vim_plugins/bundle/start/fzf/bin
export PATH=$PATH:/home/akhil/.vim/plugged/fzf/bin
export FZF_DEFAULT_COMMAND='rg --files'

# makes history unlimited.
HISTSIZE=
HISTFILESIZE=

# Technique from Drew Neil's Modern Vim.
# Changes bash's prompt when opened inside neovim's terminal buffer.
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] ➽ '
	if [ -x "$(command -v nvr)" ]; then
		alias nvim='echo "NO NESTING! use nvr instead."'
	else
		alias nvim='echo "NO NESTING!"'
	fi
fi

unset rc

