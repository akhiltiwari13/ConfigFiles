" akhil's neovim configuration

runtime macros/matchit.vim
filetype plugin indent on

let mapleader="\<space>"                 " Maps space-bar as the leader key.
let g:python3_host_prog = "/opt/homebrew/bin/python3"

set nrformats=                           "This will cause Vim to treat all numerals as decimal, regardless of whether they are padded with zeros(would be treated octal otherwise).

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
set clipboard=unnamed
set guifont=monaco:h12

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
Plug 'ghifarit53/tokyonight-vim'
Plug 'marko-cerovac/material.nvim'
" replace airline with lualine for neovim config
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'chentoast/marks.nvim'


" Search & Navigation
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'easymotion/vim-easymotion'

" Programming
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'editorconfig/editorconfig-vim'
Plug 'APZelos/blamer.nvim'
Plug 'nvim-tree/nvim-tree.lua'


" LSP and Autocompletion.
" Plug 'neovim/nvim-lspconfig'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" File format specific
Plug 'chrisbra/csv.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

call plug#end()

"  =============================
" ****PLUGIN CONFIGURATIONS.****
"  =============================

"Mapping for undotree. 
nnoremap <F5> :UndotreeToggle<CR>

let g:material_style="lighter"
colorscheme material


"Mapping for tagbar (as specified by it's author)
nmap <leader>m :TagbarToggle<CR> 

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
"Keybinding for Telescope plugin
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>ft <cmd>Telescope tags<cr>

" vim-commentary comment configuration for cmake.
autocmd FileType cmake setlocal commentstring=#\ %s

" Key bindings for switching windows.
" Normal mode
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

tnoremap <Esc> <C-\><C-n>
tnoremap <C-]> <C-\><C-n>
"<c-v><Esc> for sending Esc key to the program running in Terminal mode.
tnoremap <C-v><Esc> <Esc> 
"terminal-cursor is marked in red when changing to normal mode.
highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15 

" terminal-mode
tnoremap <leader><leader>h <c-\><c-n><c-w>h
tnoremap <leader><leader>j <c-\><c-n><c-w>j
tnoremap <leader><leader>k <c-\><c-n><c-w>k
tnoremap <leader><leader>l <c-\><c-n><c-w>l

nnoremap <leader>xd :LspDefinition<cr>
nnoremap <leader>xp :LspPeekDefinition<cr>
nnoremap <leader>xx :LspDeclaration<cr>
nnoremap <leader>xc :LspPeekDeclaration<cr>
nnoremap <leader>xr :LspRename<cr>
nnoremap <leader>xw :LspReferences<cr>
nnoremap <leader>xh :LspHover<cr>
nnoremap <leader>xa :LspCodeAction<cr>
nnoremap <leader>xs :LspDocumentSymbol<cr>
nnoremap <leader>xf :LspDocumentFormat<cr>
nnoremap <leader>xp :LspWorkspaceSymbol<cr>
nnoremap <leader>x] :LspNextError <cr>
nnoremap <leader>x[ :LspPreviousError <cr>

"NimTreeToggle
nnoremap <leader>tx :NvimTreeToggle<cr>
tnoremap <leader>tx :NvimTreeToggle<cr>

" This was causing a lot of lag in neovim when opening large files, sometimes
" causing neovim to hang.
" set foldmethod=expr
"   \ foldexpr=lsp#ui#vim#folding#foldexpr()
"   \ foldtext=lsp#ui#vim#folding#foldtext()

" Obsession key mappings
nnoremap <leader>o :Obsess<cr>
nnoremap <leader>s :Obsess!<cr>

let g:blamer_enabled = 1

lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'material',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
-- empty setup using defaults
require("nvim-tree").setup()

END

