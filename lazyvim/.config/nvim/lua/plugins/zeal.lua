return {
  "KabbAmine/zeavim.vim",
  keys = {
    { "<leader>zd", "<cmd>Zeavim<cr>", desc = "Open Zeal for current word" },
  },
  init = function()
    vim.g.zeal_options = {
      ["python"] = "python-3",  -- Example: Map filetype to Zeal docset
      ["lua"] = "lua-5.4",
    }
  end,
}
