"akhil's neovim  configuration

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
Plug 'rose-pine/neovim'
" replace airline with lualine for neovim config
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim',{'tag':'*'}
Plug 'chentoast/marks.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}


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
Plug 'chentoast/marks.nvim'


" LSP and Autocompletion.
Plug 'neovim/nvim-lspconfig'    " Collection of configurations for built-in LSP client
Plug 'hrsh7th/nvim-cmp'         " Autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp'     " LSP source for nvim-cmp
Plug 'saadparwaiz1/cmp_luasnip' " Snippets source for nvim-cmp
Plug 'L3MON4D3/LuaSnip'         " Snippets plugin

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

" let g:material_style="lighter"
" colorscheme material
set background=dark
colorscheme gruvbox


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
nnoremap <leader>fi  <cmd>Telescope builtin theme=dropdown<cr>
nnoremap <leader>ff <cmd>Telescope find_files hidden=true theme=dropdown<cr>
nnoremap <leader>fg <cmd>Telescope live_grep theme=dropdown<cr>
nnoremap <leader>fs <cmd>Telescope grep_string theme=dropdown<cr>
nnoremap <leader>fb <cmd>Telescope buffers theme=dropdown<cr>
nnoremap <leader>fh <cmd>Telescope help_tags theme=cursor<cr>
nnoremap <leader>ft <cmd>Telescope tags theme=cursor<cr>
nnoremap <leader>fc <cmd>Telescope commands theme=cursor<cr>
nnoremap <leader>fk <cmd>Telescope man_pages theme=dropdown<cr>
nnoremap <leader>f' <cmd>Telescope marks theme=dropdown<cr>
nnoremap <leader>fy <cmd>Telescope colorscheme theme=dropdown<cr>
nnoremap <leader>fr <cmd>Telescope registers hidden=true theme=ivy<cr>
nnoremap <leader>fo <cmd>Telescope spell_suggest theme=cursor<cr>
nnoremap <leader>fm <cmd>Telescope keymaps theme=ivy<cr>
nnoremap <leader>sc <cmd>Telescope command_history theme=ivy<cr>
nnoremap <leader>sh <cmd>Telescope search_history theme=ivy<cr>
nnoremap <leader>sr <cmd>Telescope lsp_references theme=cursor<cr>
nnoremap <leader>sd <cmd>Telescope lsp_definitions theme=cursor<cr>
nnoremap <leader>si <cmd>Telescope lsp_implementation theme=cursor<cr>
nnoremap <leader>st <cmd>Telescope lsp_type_definitions theme=cursor<cr>
nnoremap <leader>ss <cmd>Telescope lsp_document_symbols theme=ivy<cr>
nnoremap <leader>sw <cmd>Telescope lsp_workspace_symbols theme=ivy<cr>
nnoremap <leader>sW <cmd>Telescope lsp_dynamic_workspace_symbols theme=ivy<cr>
nnoremap <leader>so <cmd>Telescope diagnostics bufnr=0 theme=ivy<cr>

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

"NvimTreeToggle
nnoremap <leader>nt :NvimTreeToggle<cr>
tnoremap <leader>nt :NvimTreeToggle<cr>

" This was causing a lot of lag in neovim when opening large files, sometimes
" causing neovim to hang.
" set foldmethod=expr
"   \ foldexpr=lsp#ui#vim#folding#foldexpr()
"   \ foldtext=lsp#ui#vim#folding#foldtext()

" Obsession key mappings
nnoremap <leader>o :Obsess<cr>
nnoremap <leader>O :Obsess!<cr>

let g:blamer_enabled = 1

lua << EOF
-- ***Lualine setup
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'gruvbox',
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
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

-- ***nvimtree setup
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
-- empty setup using defaults
require("nvim-tree").setup()

-- ***nvim-treesitter setup
require("nvim-treesitter").setup{}

-- ***bufferline.nvim setup
require("bufferline").setup{}

-- ***marks.nvim setup
require'marks'.setup {
    -- whether to map keybinds or not. default true
    default_mappings = true,
    -- which builtin marks to show. default {}
    builtin_marks = { ".", "<", ">", "^" },
    -- whether movements cycle back to the beginning/end of buffer. default true
    cyclic = true,
    -- whether the shada file is updated after modifying uppercase marks. default false
    force_write_shada = false,
    -- how often (in ms) to redraw signs/recompute mark positions. 
    -- higher values will have better performance but may cause visual lag, 
    -- while lower values may cause performance penalties. default 150.
    refresh_interval = 250,
    -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
    -- marks, and bookmarks.
    -- can be either a table with all/none of the keys, or a single number, in which case
    -- the priority applies to all marks.
    -- default 10.
    sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
    -- disables mark tracking for specific filetypes. default {}
    excluded_filetypes = {},
    -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
    -- sign/virttext. Bookmarks can be used to group together positions and quickly move
    -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
    -- default virt_text is "".
    bookmark_0 = {
        sign = "⚑",
        virt_text = "hello world",
        -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
        -- defaults to false.
        annotate = false,
    },
    mappings = {}
}

-- ***nvim-lspconfig setup
-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}
lspconfig.cmake.setup {}
lspconfig.vimls.setup {}
lspconfig.pyright.setup {}
lspconfig.lua_ls.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.textlsp.setup({})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<leader>xx', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>xd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>xh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>xi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>xs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>xt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>xr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>xz', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>xf', function()
    vim.lsp.buf.format { async = true }
    end, opts)
    end,
})

EOF


lua << EOF
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', "textlsp" }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        -- on_attach = my_custom_on_attach,
        capabilities = capabilities,
    }
    end

    -- luasnip setup
    local luasnip = require 'luasnip'

    -- nvim-cmp setup
    local cmp = require 'cmp'
    cmp.setup {
        snippet = {
            expand = function(args)
            luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
        ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
        -- C-b (back) C-f (forward) for snippet placeholder navigation.
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            fallback()
            end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
                end
                end, { 'i', 's' }),
        }),
        sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
    }
EOF

