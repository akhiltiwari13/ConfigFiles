"akhil's .vimrc

syntax enable                     " Turn on syntax highlighting.
runtime macros/matchit.vim
filetype plugin indent on

let mapleader="\<space>"                 " Maps space-bar as the leader key.

set nrformats=                    "This will cause Vim to treat all numerals as decimal, regardless of whether they are padded with zeros(would be treated octal otherwise).

set shiftwidth=4 softtabstop=4 expandtab
set showcmd                       " Display incomplete commands.
set noshowmode                    " Show mode unnecessary because it is visble in airline.
set backspace=indent,eol,start    " Intuitive backspacing.
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
set hidden                        
set encoding=utf-8
set signcolumn=yes
set foldmethod=indent
set clipboard=unnamed



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
Plug 'tpope/vim-obsession'
Plug 'jiangmiao/auto-pairs'

" Aesthetics
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'

" Search & Navigation
Plug 'mhinz/vim-grepper'
Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'

" Programming
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'editorconfig/editorconfig-vim'


" LSP and Autocompletion.
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'


call plug#end()

"  =============================
" ****PLUGIN CONFIGURATIONS.****
"  =============================

"Mapping for undotree. 
nnoremap <F5> :UndotreeToggle<CR>

" Use gruvbox for colorscheme.
colorscheme gruvbox
set background=dark    


"Mapping for tagbar (as specified by it's author)
nmap <F8> :TagbarToggle<CR> 

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

" =================================
"Configurations from Practical Vim.
" =================================

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
nnoremap <silent> <leader>fl :BLines<CR>
nnoremap <silent> <leader>fO :BTags<CR>
nnoremap <silent> <leader>ft :Tags<CR>
nnoremap <silent> <leader>f: :History:<CR>
nnoremap <silent> <leader>f/ :History/<CR>
nnoremap <silent> <leader>fc :Commands<CR>

imap <C-x><C-f> <plug>(fzf-complete-file-ag)
imap <C-x><C-l> <plug>(fzf-complete-line)

" vim-commentary comment configuration for cmake.
autocmd FileType cmake setlocal commentstring=#\ %s

" Key bindings for switching windows.
" Normal mode
nnoremap <M-h> <c-w>h
nnoremap <M-j> <c-w>j
nnoremap <M-k> <c-w>k
nnoremap <M-l> <c-w>l

" Insert mode (changes authored by self)
inoremap <M-h> <c-[><c-w>h
inoremap <M-j> <c-[><c-w>j
inoremap <M-k> <c-[><c-w>k
inoremap <M-l> <c-[><c-w>l

" Visual mode (changes authored by self)
vnoremap <m-h> <c-w>h
vnoremap <m-j> <c-w>j
vnoremap <m-k> <c-w>k
vnoremap <m-l> <c-w>l

if has('nvim')
    tnoremap <M-h> <c-\><c-n><c-w>h
    tnoremap <M-j> <c-\><c-n><c-w>j
    tnoremap <M-k> <c-\><c-n><c-w>k
    tnoremap <M-l> <c-\><c-n><c-w>l
endif


"NEOVIM ONLY Keybinding for terminal mode.
if has('nvim')
    "Keybindings for Terminal Mode.
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-]> <C-\><C-n>

    "<c-v><Esc> for sending Esc key to the program running in Terminal mode.
    tnoremap <C-v><Esc> <Esc> 

    "terminal-cursor is marked in red when changing to normal mode.
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15 
endif

nnoremap <leader>ld :LspDefinition<cr>
nnoremap <leader>pd :LspPeekDefinition<cr>
nnoremap <leader>lx :LspDeclaration<cr>
nnoremap <leader>px :LspPeekDeclaration<cr>
nnoremap <leader>lr :LspRename<cr>
nnoremap <leader>lw :LspReferences<cr>
nnoremap <leader>lh :LspHover<cr>
nnoremap <leader>la :LspCodeAction<cr>
nnoremap <leader>ls :LspDocumentSymbol<cr>
nnoremap <leader>lf :LspDocumentFormat<cr>
nnoremap <leader>lp :LspWorkspaceSymbol<cr>
nnoremap <leader>l] :LspNextError <cr>
nnoremap <leader>l[ :LspPreviousError <cr>

" lightline configuration from :h lightline (docs)


