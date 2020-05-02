"====================================VIMRC BEGINS=================================================
syntax enable                     " Turn on syntax highlighting.
runtime macros/matchit.vim
filetype plugin indent on

let mapleader="\<space>"                 " Maps space-bar as the leader key.

set nrformats=
set shiftwidth=4 softtabstop=4 expandtab
set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
"set wildmode=longest,list        " Complete files like a shell.
set wildmenu			  " Complete files like a z-shell.
set wildmode=full
set history=1000
set ignorecase                    " Case-insensitive searching.
set infercase                     " Smart Keyword autocompletion.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set number                        " Show line numbers.
set ruler                         " Show cursor position.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.
set wrap                          " Turn on line wrapping.
set scrolloff=3                   " Show 3 lines of context around the cursor.
set title                         " Set the terminal's title
set nobackup                      " Don't make a backup before overwriting
set nowritebackup                 " And again.
set cursorline
set encoding=utf-8
set foldmethod=indent


autocmd BufRead * normal zR //opens all folds by default.

" Install vim-plug if it's not already installed. Use PlugInstall to install all the below plugins post that. (only works for *inx/cygwin).
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.github.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set tags=tags; " Look for a tags file recursively in parent directories(semicolon lets vim know to check for the tags file recursively in parent directorie.

" Plugins installations using vim-plug.
call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-plug'
Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plug 'junegunn/fzf.vim'
Plug 'janko/vim-test'
Plug 'easymotion/vim-easymotion'
Plug 'itchyny/lightline.vim'
Plug 'mileszs/ack.vim'
Plug 'majutsushi/tagbar'
Plug 'sjl/gundo.vim'
Plug 'luochen1990/rainbow'
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'mhinz/vim-grepper'
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale'
Plug 'autozimu/LanguageClient-neovim', {
	    \ 'branch': 'next',
	    \ 'do': 'bash install.sh',
	    \ }
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

" Use gruvbox as colorscheme.
colorscheme gruvbox
set background=dark    " Setting dark mode

"Mapping for tagbar (as specified by it's author)
nmap <F8> :TagbarToggle<CR>

"Default configuration for rainbow.
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle


" ============================
"Configurations from Practical Vim.
" ============================
"Ex Commands mapping from practical vim.
"Mapping for :edit %:h<Tab> //Practical vim Tip #41.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"Normal Mode key mappings from practical vim.
nnoremap <f3> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --exclude=.git .<CR>
noremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

"Tab mappings.
map <leader>tt :tabnew<cr>
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>

"Settings for visual selection search
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch()
    let temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
    let @s = temp
endfunction
"Settings for visual selection search ==ENDS

"Mapping & key to repeat last substitution WITH flags in normal and visual mode.
nnoremap & :&&<CR>
xnoremap & :&&<CR>

"Vim-Script to use :Qargs to populate argument-list with quickfix-list.
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
    let buffer_numbers = {}
    for quickfix_item in getqflist()
	let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
    endfor
    return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction


" ============================
"Configurations from Modern Vim.
" ============================
"Keybinding for FZF plugin
nnoremap <C-p> :<C-u>FZF<CR>
" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

inoremap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
	    \ 'prefix': '^.*$',
	    \ 'source': 'rg -n ^ --color always',
	    \ 'options': '--ansi --delimiter : --nth 3..',
	    \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '')  } 
	    \ } ) ) 

" vim commentory configurations
autocmd FileType cmake setlocal commentstring=#\ %s


"NEOVIM ONLY Keybinding for terminal mode.
if has('nvim')
    "Keybindings for Terminal Mode.
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-]> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif

" ALE settings and mappings.
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0

let g:ale_linters = {
	    \
	    \ 'javascript': ['eslint'],
	    \ 'cpp': ['cppcheck', 'clang'],
	    \ 'python': ['pylint'],
	    \ }

let g:ale_fixers = {
	    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
	    \ 'javascript': ['eslint', 'prettier'],
	    \ 'cpp': ['clangtidy', 'clang-format','uncrustify'],
	    \ 'python': ['black','autopep8','isort','yapf'],
	    \}

" Grepper mappings.
let g:grepper = {}
let g:grepper.tools = ['grep', 'git', 'rg']
" Search for the current word
nnoremap <Leader>* :Grepper -cword -noprompt<CR>
" Search for the current selection
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)


" ========================================
" LSP and autocompletion related settings.
" ========================================
"deoplete default config.
let g:deoplete#enable_at_startup = 1

" LanguageClient-neovim configurations and mappings (works with vim-8 too)
set completefunc=LanguageClient#complete

let g:LanguageClient_serverCommands = {
	    \ 'c':   ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],
	    \ 'cpp': ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],
	    \ 'python': ['pyls'],
	    \ }

function! SetLSPShortcuts()
    nnoremap <leader>ld :call LanguageClient#textDocument_definition()<cr>
    nnoremap <leader>lr :call LanguageClient#textDocument_rename()<cr>
    nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<cr>
    nnoremap <leader>lx :call LanguageClient#textDocument_references()<cr>
    nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<cr>
    nnoremap <leader>lc :call LanguageClient#textDocument_completion()<cr>
    nnoremap <leader>lh :call LanguageClient#textDocument_hover()<cr>
    nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<cr>
    nnoremap <leader>lm :call LanguageClient_contextMenu()<cr>
endfunction()

augroup LSP
    autocmd!
    autocmd FileType cpp,c,python call SetLSPShortcuts()
augroup END



" Commented out LSP commands for C++; I use them @ whim. :-|)
" \ 'cpp': ['clangd-9'],
" \ 'c': ['clangd-9'],
" \ 'c':   ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],
" \ 'cpp': ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],


