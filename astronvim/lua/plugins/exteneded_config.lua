return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { -- add a new dependency to telescope that is our new plugin
      "nvim-telescope/telescope-media-files.nvim",
    },
    -- the first parameter is the plugin specification
    -- the second is the table of options as set up in Lazy with the `opts` key
    config = function(plugin, opts)
      -- run the core AstroNvim configuration function with the options table
      require "astronvim.plugins.configs.telescope"(plugin, opts)

      -- require telescope and load extensions as necessary
      require("telescope").load_extension "media_files"
      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Find command history" })
      vim.keymap.set("n", "<leader>fm", builtin.man_pages, { desc = "Find man pages" })
      vim.keymap.set("n", "<leader>flr", builtin.lsp_references, { desc = "Find lsp references" })
      vim.keymap.set("n", "<leader>fld", builtin.lsp_definitions, { desc = "Find lsp definitions" })
      vim.keymap.set("n", "<leader>flc", builtin.lsp_incoming_calls, { desc = "Find lsp incoming calls" })
      vim.keymap.set("n", "<leader>flo", builtin.lsp_outgoing_calls, { desc = "Find lsp outgoing calls" })
      vim.keymap.set("n", "<leader>fli", builtin.lsp_implementations, { desc = "Find lsp implementations" })
      vim.keymap.set("n", "<leader>fls", builtin.lsp_document_symbols, { desc = "Find lsp document symbols" })
      vim.keymap.set("n", "<leader>flt", builtin.lsp_type_definitions, { desc = "Find lsp type definitions" })
      vim.keymap.set("n", "<leader>flw", builtin.lsp_workspace_symbols, { desc = "Find lsp workspace symbols" })
      vim.keymap.set("n", "<leader>fll", builtin.lsp_dynamic_workspace_symbols, { desc = "Find list all lsps" })
      vim.keymap.set("n", "<leader>flx", builtin.diagnostics, { desc = "find diagnostics" })
    end,
  },
}
