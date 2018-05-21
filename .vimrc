

"=====================.VIMRC BEGINS===========================================
set nocompatible
" Must come first because it changes other options.
"Initializes vim in a non compatible mode with the vi editor.


"=========VUNDLE==========

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

" plugin on GitHub repo

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" Plugin 'jiangmiao/auto-pairs'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-scripts/Conque-GDB'
Plugin 'tpope/vim-fugitive'
Plugin 'majutsushi/tagbar'
Plugin 'godlygeek/tabular'
Plugin 'tpope/vim-commentary'
Plugin 'luochen1990/rainbow'
Plugin 'Rip-Rip/clang_complete'
Plugin 'alpertuna/vim-header'
Plugin 'davidhalter/jedi-vim'
Plugin 'lifepillar/vim-mucomplete'








" plugin from http://vim-scripts.org/vim/scripts.html
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

"=========VUNDLE==========

syntax enable                     " Turn on syntax highlighting.
filetype plugin indent on         " Turn on file type detection.

runtime macros/matchit.vim        " Load the matchit plugin.

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

"setting visualbell causes wiered gui flashing on my ubuntu-linux.
"set visualbell                    " No beeping.

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.

set softtabstop=5

"turning the hidden mode ON!
set hidden

"Color scheme to be used.
"colorscheme vividchalk

"shortcut keys defined for the tab operations.
" Tab mappings.
map <leader>tt :tabnew<cr>
map <leader>te :tabedit<cr>
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>
map <leader>tf :tabfirst<cr>
map <leader>tl :tablast<cr>
map <leader>tm :tabmove<cr>

"Key Mapping for NERDTree
map <leader>nt :NERDTree<cr>

"Key Mapping for FuzzyFinder
map <leader>ff :FufFile<cr>
map <leader>fb :FufBuffer<cr>
map <leader>fd :FufDir<cr>
map <leader>fl :FufLine<cr>
map <leader>fq :FufQuickfix<cr>

"Key Mapping for ConqueGdb
map <leader>bv :ConqueTermVSplit bash<cr>
map <leader>b :breakpoint

"Key Mapping for tagbar
nmap <leader>tag :TagbarToggle<cr>

"Enabling Rainbow Paranthesis
let g:rainbow_active = 1 

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
let g:syntastic_cpp_compiler_options = ' -std=c++11 -O2 -Wall -Wextra'
let g:syntastic_cpp_check_header = 1

"For C
let g:syntastic_c_compiler = 'gcc'
let g:syntastic_c_compiler_options = ' -Wall -Wextra'
let g:syntastic_c_check_header = 1

"Settings for clangcomplete.
" Setting clan_library_path to the directory where libclang.so is located.
let g:clang_library_path='/usr/lib/'

"Settings and Key Mapping for vim-header.
let g:header_auto_add_header = 0
let g:header_field_author = 'akhil'
let g:header_field_author_email = 'akhiltiwari.13@gmail.com'
map <leader>gl :AddGNULicense<cr>
map <leader>h :AddHeader<cr>

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
map <leader>cp :r ~/.vim/initial_code_snippet.cpp<cr>

" Mappings for switching between split windows. alt+arrow-keys are used for
" this motion.
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Settings for mucomplete
set completeopt+=menuone
"set completeopt+=noselect
"set completeopt+=noinsert
"set shortmess+=c   " Shut off completion messages
"set belloff+=ctrlg " If Vim beeps during completion
