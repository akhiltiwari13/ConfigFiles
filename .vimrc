"akhil's .vimrc

syntax enable                     " Turn on syntax highlighting.
runtime macros/matchit.vim
filetype plugin indent on

let mapleader="\<space>"                 " Maps space-bar as the leader key.

set nrformats=
set shiftwidth=4 softtabstop=4 expandtab
set showcmd                       " Display incomplete commands.
set noshowmode                    " Show mode unnecessary because it is visble in airline.
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
set signcolumn=yes

" open all folds by default.  
autocmd BufRead * normal zR 

" Install vim-plug if it's not already installed. Use PlugInstall to install all the below plugins post that. (only works for *inx/cygwin).
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.github.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins installations using vim-plug.
call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-plug'

" Editing 
Plug 'mbbill/undotree'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'jiangmiao/auto-pairs'

" Aesthetics
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'luochen1990/rainbow'

" Search & Navigation
Plug 'mhinz/vim-grepper'
Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'

" Programming
Plug 'majutsushi/tagbar'
Plug 'janko/vim-test'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'dense-analysis/ale'

" LanguageCLient-neovim & it's complementary plugins!
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
Plug 'Shougo/echodoc.vim' "for viewing function signatures.



call plug#end()

" ****PLUGIN CONFIGURATIONS.****

" ============================
"Mapping for undotree. 
" ============================
nnoremap <F5> :UndotreeToggle<CR>

" ============================
" Use gruvbox as colorscheme.
" ============================
colorscheme gruvbox
set background=dark    " Setting dark mode
" set background=light    " Setting light mode

" ============================
" echoDoc's settings for viewing function signature in neovim.
" ============================
" Or, you could use neovim's floating text feature.
" let g:echodoc#enable_at_startup = 1
" let g:echodoc#type = 'floating'
" To use a custom highlight for the float window,
" change Pmenu to your highlight group
" highlight link EchoDocFloat Pmenu

" To use echodoc, you must increase 'cmdheight' value.
set cmdheight=2
let g:echodoc_enable_at_startup = 1
let g:echodoc#type = 'signature'


" ============================
"Mapping for tagbar (as specified by it's author)
" ============================
nmap <F8> :TagbarToggle<CR>

" ============================
"Default configuration for rainbow.
" ============================
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

"  ========================================
" Grepper mappings.
"  ========================================
let g:grepper = {}
let g:grepper.tools = [ 'ack', 'rg', 'grep', 'git']

" Fires search tools.
nnoremap <leader>ga :Grepper -tool ack<cr>
nnoremap <leader>gr :Grepper -tool rg<cr>
nnoremap <leader>gg :Grepper -tool grep<cr>

" Search for the current word
nnoremap <leader>g* :Grepper -cword -noprompt<CR>

" Search for the current selection
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

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

"Whats it's use?
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

let g:fzf_nvim_statusline = 0 " disable statusline overwriting

nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fw :Windows<CR>
nnoremap <silent> <leader>f; :BLines<CR>
nnoremap <silent> <leader>ft :BTags<CR>
nnoremap <silent> <leader>fO :Tags<CR>
nnoremap <silent> <leader>f? :History<CR>

imap <C-x><C-f> <plug>(fzf-complete-file-ag)
imap <C-x><C-l> <plug>(fzf-complete-line)

" vim commentory comment configuration for cmake.
autocmd FileType cmake setlocal commentstring=#\ %s


"NEOVIM ONLY Keybinding for terminal mode.
if has('nvim')
    "Keybindings for Terminal Mode.
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-]> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif

" ========================================
" ALE settings and mappings.
" ========================================
nnoremap <leader>e :ALELint<CR>
nnoremap <leader>ef :ALEFix<CR>

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0

" Set this variable to 1 to fix files when you save them.
" let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1

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


" ========================================
" ALE-LightLine Integration.
" ========================================
" let g:lightline = {}

" let g:lightline.component_expand = {
"             \  'linter_checking': 'lightline#ale#checking',
"             \  'linter_infos': 'lightline#ale#infos',
"             \  'linter_warnings': 'lightline#ale#warnings',
"             \  'linter_errors': 'lightline#ale#errors',
"             \  'linter_ok': 'lightline#ale#ok',
"             \ }

" let g:lightline.component_type = {
"             \     'linter_checking': 'right',
"             \     'linter_infos': 'right',
"             \     'linter_warnings': 'warning',
"             \     'linter_errors': 'error',
"             \     'linter_ok': 'right',
"             \ }

" let g:lightline.active = { 'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ]] }


" ========================================
" LSP/LanguageClient and autocompletion related settings.
" ========================================
"deoplete default config.
let g:deoplete#enable_at_startup = 1
" configures completion options for deoplete.
call deoplete#custom#option('sources', {
            \ '_': ['ale', 'LanguageClient'],
            \})

" LanguageClient-neovim configurations and mappings (works with vim-8 too)
set completefunc=LanguageClient#complete

let g:LanguageClient_serverCommands = {
            \ 'cpp': ['clangd-9'],
            \ 'c': ['clangd-9'],
            \ 'python': ['pyls'],
            \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
            \ }

function! SetLSPShortcuts()
    nnoremap <leader>ld :call LanguageClient#textDocument_definition()<cr>
    nnoremap <leader>lr :call LanguageClient#textDocument_rename()<cr>
    nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<cr>
    nnoremap <leader>lx :call LanguageClient#textDocument_references()<cr>
    nnoremap <leader>le :call LanguageClient_workspace_applyEdit()<cr>
    nnoremap <leader>lc :call LanguageClient#textDocument_completion()<cr>
    nnoremap <leader>lh :call LanguageClient#textDocument_hover()<cr>
    nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<cr>
    nnoremap <leader>lm :call LanguageClient_contextMenu()<cr>
endfunction()

augroup LSP
    autocmd!
    autocmd FileType cpp,c,python,rust call SetLSPShortcuts()
    " autocmd FileType cpp,c,python,rust,cmake,go call SetLSPShortcuts()
augroup END



" Incase LSP for cpp needs to be changed!
" \ 'c':   ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],
" \ 'cpp': ['ccls', '--log-file=/tmp/vim-cquery.log', '--init={"cacheDirectory":"$HOME/.cquery-cache"}'],
