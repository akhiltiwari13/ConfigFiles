return {
  -- Telescope (lazy-loaded, only for Zotero)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- Only load when Telescope command is used
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Replace telescope-bibtex.nvim with:
      {
        "jmbuhr/telescope-zotero.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        config = function()
          require("telescope").load_extension("zotero")
        end,
      },
    },
    opts = {
      -- Minimal telescope config to avoid conflicts
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
      },
    },
  },
}
