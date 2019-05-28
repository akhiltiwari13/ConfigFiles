"============================================================ VIMRC BEGINS ===============================================================
set nocompatible
" Must come first because it changes other options.
"Initializes vim in a non compatible mode with the vi editor.
"============================================================ VUNDLE =====================================================================
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" plugin on GitHub repo
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-commentary'
Plugin 'Valloric/YouCompleteMe'
Plugin 'alpertuna/vim-header'
Plugin 'vim-syntastic/syntastic'
Plugin 'fatih/vim-go'
Plugin 'FuzzyFinder'
Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"============================================================ VUNDLE =====================================================================
syntax enable                     " Turn on syntax highlighting.
filetype plugin indent on         " Turn on file type detection.
set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set number                        " Show line numbers.
set ruler                         " Show cursor position.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.
set wrap                          " Turn on line wrapping.
set scrolloff=3                   " Show 3 lines of context around the cursor.
set title                         " Set the terminal's title
set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set softtabstop=5
"turning the hidden mode ON!
set hidden
" Tab mappings.
map <leader>tt :tabnew<cr>
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>
map <leader>tf :tabfirst<cr>
map <leader>tl :tablast<cr>
map <leader>tm :tabmove<cr>
" Setting to auto match the brackets.
ino " ""<left>
ino ' ''<left>
ino ( ()<left>
ino [ []<left>
ino { {}<left>
ino {<CR> {<CR>}<ESC>O
ino {;<CR> {<CR>};<ESC>O
" Settings for moving between split windows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
" For inserting code snippet for my .cpp files.
" map <leader>cp :r ~/.vim/initial_code_snippet.cpp<cr>
" Mappings for switching between split windows. alt+arrow-keys are used for this motion.
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
"Key Mapping for NERDTree
map <leader>nt :NERDTree<cr>
map <leader>nm :NERDTreeMirror<cr>
"Key Mapping for FuzzyFinder
map <leader>ff :FufFile<cr>
map <leader>fb :FufBuffer<cr>
map <leader>fm :FufBookmarkFile<cr>
map <leader>fd :FufDir<cr>
map <leader>fl :FufLine<cr>
map <leader>fq :FufQuickfix<cr>
map <leader>fc :FufCoverageFile<cr> 
"===========================SYNTASTIC CONFIGURATION========================= 
"Syntastic configurations as per it's gitHub page.
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list            = 1
let g:syntastic_check_on_open            = 1
let g:syntastic_check_on_wq              = 0
"Syntastic Checkers
let g:syntastic_cpp_checkers = ['clang_check', 'clang_tidy', 'gcc']
let g:syntastic_c_checkers = ['clang_check', 'clang_tidy', 'gcc']
"Other Syntastic Settings
"For C++
let g:syntastic_cpp_compiler = 'g++'
let g:syntastic_cpp_compiler_options = '-std=c++11 -O2 -Wall -Wextra -Weffc++'
let g:syntastic_cpp_check_header = 1
"For C
let g:syntastic_c_compiler = 'gcc'
let g:syntastic_c_compiler_options = '-std=c11 -Wall -Wextra'
let g:syntastic_c_check_header = 1
"===========================SYNTASTIC CONFIGURATION========================= 
"Settings and Key Mapping for vim-header.
let g:header_auto_add_header = 0
let g:header_field_author = 'akhil'
let g:header_field_author_email = 'akhil@deqode.com'
map <leader>gl :AddGNULicense<cr>
map <leader>h :AddHeader<cr>
map <leader>ml :AddMITLicense<cr>
" Settings for using ctags with vim
set tags=tags
" Settings for taglist : opens taglist on pressing f8
let Tlist_Ctags_Cmd =  "/usr/bin/ctags"
let Tlist_Display_Prototype = 1
nnoremap <silent> <F8> :TlistToggle<CR>
" =====================cscope settings and mappings==========================
if has("cscope")
	set csprg=/usr/local/bin/cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
endif
" Following scheme is, inspired by Vim/Cscope tutorial from Cscope Home Page (http://cscope.sourceforge.net/)
nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>a :cs find a <C-R>=expand("<cword>")<CR><CR>
" Using 'CTRL-spacebar' then a search type makes the vim window
" split horizontally, with search result displayed in
" the new window.
nmap <C-Space>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-Space>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-Space>d :scs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space>a :scs find a <C-R>=expand("<cword>")<CR><CR>
" Hitting CTRL-space *twice* before the search type does a vertical
" split instead of a horizontal one
nmap <C-Space><C-Space>s
			\:vert scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>g
			\:vert scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>c
			\:vert scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>t
			\:vert scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>e
			\:vert scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>i
			\:vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-Space><C-Space>d
			\:vert scs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-Space><C-Space>a
			\:vert scs find a <C-R>=expand("<cword>")<CR><CR>

