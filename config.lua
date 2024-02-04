-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.plugins = {
  {
    'smoka7/hop.nvim',
    version = "*",
    opts = {},
    config = function()
      require("hop").setup()
    end,
  },
  {
    "nacro90/numb.nvim",
    event = "BufRead",
    config = function()
      require("numb").setup {
        show_numbers = true,    -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      }
    end,
  },
  {
    "kevinhwang91/nvim-bqf",
    event = { "BufRead", "BufNew" },
    config = function()
      require("bqf").setup({
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
        },
        func_map = {
          vsplit = "",
          ptogglemode = "z,",
          stoggleup = "",
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      })
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      require("gitblame").setup { enabled = true }
    end,
  },
  {
    "mrjones2014/nvim-ts-rainbow",
  },
  {
    "rmagatti/goto-preview",
    config = function()
      require('goto-preview').setup {
        width = 120,              -- Width of the floating window
        height = 25,              -- Height of the floating window
        default_mappings = false, -- Bind default mappings
        debug = false,            -- Print debug information
        opacity = nil,            -- 0-100 opacity level of the floating window where 100 is fully transparent.
        post_open_hook = nil      -- A function taking two arguments, a buffer and a window to be ran as a hook.
      }
    end
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require "lsp_signature".on_attach() end,
  },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require('symbols-outline').setup()
    end
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
          '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    config = function()
      require("persistence").setup {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
      }
    end,
  },
  { "github/copilot.vim" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround", },
  { "catppuccin/nvim",    name = "catppuccin", priority = 1000 },
}

-- Telescope settings
lvim.builtin.telescope.theme = "center"


lvim.builtin.which_key.mappings["t"] = {
  name = "Telescope",
  t = { "<cmd>Telescope<cr>", "Telescope" },
  f = { "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = true})<cr>", "Find files", },
  a = { "<cmd>Telescope find_files hidden=true<cr>", "Find all files" },
  g = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text/Grep" },
  s = { "<cmd>Telescope grep_string theme=ivy<cr>", "Find String" },
  p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
  b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
  B = { "<cmd>Telescope buffers<cr>", "Find Buffers" },
  c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
  h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
  M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
  r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
  R = { "<cmd>Telescope registers<cr>", "Registers" },
  k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
  C = { "<cmd>Telescope commands<cr>", "Commands" },
  H = { "<cmd>Telescope command_history<cr>", "History of :Commands" },
}

-- colorscheme setup
lvim.colorscheme = "catppuccin-macchiato"

-- hop.vim keybappings
lvim.builtin.which_key.mappings["<leader>"] = {
  name = "Hop.nvim",
  h = { "<cmd>HopChar1<cr>", "Hop character in buffer" },
  w = { "<cmd>HopWord<cr>", "Hop word in buffer" },
}

-- enable treesitter integration
lvim.builtin.treesitter.matchup.enable = true

lvim.builtin.which_key.mappings["S"] = {
  name = "Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

-- LSP settings
lvim.lsp.installer.setup.automatic_installation = true

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'

-- Check if the ccls server configuration exists and if not, set it up
if not configs.ccls then
  configs.ccls = {
    default_config = {
      cmd = { "ccls" },
      filetypes = { "c", "cpp", "objc", "objcpp" },
      root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
      init_options = {
        compilationDatabaseDirectory = "build",
        index = {
          threads = 0,
        },
        clang = {
          excludeArgs = { "-frounding-math" },
        },
      },
    },
  }
end

-- Scala LSP setup
-- Metals configuration for Scala
-- Ensure that you have Metals installed via coursier

-- if not lspconfig.configs.metals then
--   lspconfig.configs.metals = {
--     default_config = {
--       cmd = { "metals" },
--       filetypes = { "scala", "sbt" },
--       root_dir = lspconfig.util.root_pattern("build.sbt", ".git"),
--       settings = {
--         showImplicitArguments = true,
--         showInferredType = true,
--       }
--     },
--   }
-- end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'ccls', 'metals' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    on_exit = require("lvim.lsp").common_on_exit,
    capabilities = require("lvim.lsp").common_capabilities(),
  }
end
