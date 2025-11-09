return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }),
  -- keys = {
  --   {
  --     "<leader>fp",
  --     function() require("oil").Oil{ } cwd = require("lazy.core.config").options.root }) end,
  --     desc = "Find Plugin File",
  --   },
  -- },
}
