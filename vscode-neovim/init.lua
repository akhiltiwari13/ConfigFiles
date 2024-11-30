-- Basic settings
vim.g.mapleader = " "
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugins (using Packer)
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'junegunn/vim-easy-align'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  }
end)

-- Automatically run PackerCompile when plugins.lua is updated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

if packer_bootstrap then
  require('packer').sync()
end

-- Key mappings
-- Files
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find files in the project" })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Search for text in the project" })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "List and switch between buffers" })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Find help tags" })

-- Git
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<cr>', { desc = "Show Git status" })
vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = "List Git branches" })
vim.keymap.set('n', '<leader>gc', '<cmd>Telescope git_commits<cr>', { desc = "List Git commits (current branch)" })
vim.keymap.set('n', '<leader>gC', '<cmd>Telescope git_bcommits<cr>', { desc = "List Git commits (current buffer)" })

-- LSP
vim.keymap.set('n', '<leader>lr', '<cmd>Telescope lsp_references<cr>', { desc = "Find references to the symbol under the cursor" })
vim.keymap.set('n', '<leader>li', '<cmd>Telescope lsp_implementations<cr>', { desc = "Find implementations of the symbol under the cursor" })
vim.keymap.set('n', '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>', { desc = "Find document symbols (outline)" })
vim.keymap.set('n', '<leader>lw', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = "Find workspace symbols" })
vim.keymap.set('n', '<leader>ld', '<cmd>Telescope diagnostics<cr>', { desc = "Show diagnostics for the current buffer" })

-- Search
vim.keymap.set('n', '<leader>sp', '<cmd>Telescope grep_string<cr>', { desc = "Search for the word under the cursor in the project" })
vim.keymap.set('n', '<leader>sr', '<cmd>Telescope oldfiles<cr>', { desc = "Open recently used files" })

-- Commands
vim.keymap.set('n', '<leader>cm', '<cmd>Telescope commands<cr>', { desc = "Find Neovim commands" })
vim.keymap.set('n', '<leader>mp', '<cmd>Telescope keymaps<cr>', { desc = "Find Neovim key mappings" })
vim.keymap.set('n', '<leader>co', '<cmd>Telescope colorscheme<cr>', { desc = "Change colorscheme" })

-- Registers
vim.keymap.set('n', '<leader>rg', '<cmd>Telescope registers<cr>', { desc = "List and preview registers" })

-- Marks and Jumps
vim.keymap.set('n', '<leader>ma', '<cmd>Telescope marks<cr>', { desc = "List marks" })
vim.keymap.set('n', '<leader>ju', '<cmd>Telescope jumplist<cr>', { desc = "List and jump to locations in the jumplist" })
vim.keymap.set('n', '<leader>qs', '<cmd>Telescope quickfix<cr>', { desc = "Show the quickfix list" })
vim.keymap.set('n', '<leader>ql', '<cmd>Telescope loclist<cr>', { desc = "Show the location list" })

-- Sessions
vim.keymap.set('n', '<leader>ss', '<cmd>Telescope sessions<cr>', { desc = "List available sessions (requires session plugin)" })

-- File Browser (requires `telescope-file-browser` plugin)
vim.keymap.set('n', '<leader>fe', '<cmd>Telescope file_browser<cr>', { desc = "File browser" })

-- Buffers and Windows
vim.keymap.set('n', '<leader>bb', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = "Fuzzy search in the current buffer" })
vim.keymap.set('n', '<leader>wa', '<cmd>Telescope windows<cr>', { desc = "List windows (requires window-picker plugin)" })

-- Tags
vim.keymap.set('n', '<leader>tt', '<cmd>Telescope tags<cr>', { desc = "Find tags (ctags)" })
vim.keymap.set('n', '<leader>st', '<cmd>Telescope current_buffer_tags<cr>', { desc = "Find tags in the current buffer" })

-- Media (requires plugins like `telescope-media-files`)
vim.keymap.set('n', '<leader>md', '<cmd>Telescope media_files<cr>', { desc = "Preview media files (requires telescope-media-files)" })

-- Search and Replace (requires `telescope-live-grep-args`)
vim.keymap.set('n', '<leader>rl', '<cmd>Telescope live_grep_args<cr>', { desc = "Search and replace using live grep args" })

-- Easy Align
vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')
vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')

-- Custom functions
vim.api.nvim_create_user_command('Vscode', function()
  vim.notify('Hello from Neovim in VSCode!')
end, {})

-- VSCode-specific settings
if vim.g.vscode then
  -- VSCode extension
  vim.keymap.set('n', '<leader>e', '<Cmd>call VSCodeNotify("workbench.action.toggleSidebarVisibility")<CR>')
  vim.keymap.set('n', '<leader>f', '<Cmd>call VSCodeNotify("workbench.action.quickOpen")<CR>')
  vim.keymap.set('n', '<leader>w', '<Cmd>call VSCodeNotify("workbench.action.files.save")<CR>')
else
  -- Ordinary Neovim
  vim.keymap.set('n', '<leader>e', '<cmd>Ex<cr>')
end
