" neovim configurations.
" author akhil.
"
" vim-plug is the plugin manager I've decide to go with initially.
" All vim-plug plugin mentions should happend between #begin and #end.
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-commentary'
Plug 'ctrlpvim/ctrlp.vim'

" COC stands for conquerer of completion.
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }


call plug#end()
" vim-plug section ends here.

let mapleader=";"
set shell=/bin/bash 
set number
set hidden                        " Hides warning when switching with a hidden buffer.
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.

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

" NERDTree toggle.
nnoremap <silent> <Space> :NERDTreeToggle<CR>

" Includes file types for Vim Commentary 
autocmd FileType apache setlocal commentstring=#\ %s

