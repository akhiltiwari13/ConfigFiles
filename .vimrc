"====================================VIMRC BEGINS=================================================
packadd minpac
call minpac#init()

call minpac#add('tpope/vim-unimpaired')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-commentary')
call minpac#add('vim-airline/vim-airline')
call minpac#add('junegunn/fzf')
call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('tmhedberg/matchit', {'type': 'opt'})

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()

syntax enable                     " Turn on syntax highlighting.
runtime macros/matchit.vim


let mapleader='\'                 " Maps ; (Back-Slash) as the leader key.

set nrformats=
set shiftwidth=4 softtabstop=4 expandtab
set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
"set wildmode=longest,list         " Complete files like a shell.

"Complete files like a z-shell.
set wildmenu
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
set hidden                        " Turning the hidden mode ON!
"set complete+=k                   " Adds words from dictionary to generic keyword autocompletion.

"Ex Commands mapping from practical vim.
"Mapping for :edit %:h<Tab> //Practical vim Tip #41.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>


"Normal Mode key mappings from practical vim.
nnoremap <f5> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --exclude=.git .<CR>  
"Search related mappings.
noremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

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

"Tab mappings.
map <leader>tt :tabnew<cr>
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
"Setting to map buffer movements similar to vim-unimpaired.
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

"Mapping & key to repeat last substitution WITH flags in normal and visual mode.
nnoremap & :&&<CR>
xnoremap & :&&<CR>

"Vim-Script to user :Qargs to populate argument-list with quickfix-list.
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
    let buffer_numbers = {}
    for quickfix_item in getqflist()
        let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
    endfor
    return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction


"Keybindings from Modern Vim.
"Keybinding for FZF plugin
nnoremap <C-p> :<C-u>FZF<CR>

"Settings for vim-airline.
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1


if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" vim commentory configurations
autocmd FileType cmake setlocal commentstring=#\ %s

"NEOVIM ONLY Keybinding
if has('nvim')
    "Keybindings for Terminal Mode.
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-]> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif


