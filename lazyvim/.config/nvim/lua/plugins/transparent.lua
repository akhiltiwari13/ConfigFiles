return {
  {
    "xiyaowong/transparent.nvim",
    opts = {},
    config = function()
      require("transparent").setup({
        enable = true, -- boolean: enable transparent mode
        extra_groups = { -- table/string: additional groups to clear
          "NormalFloat",
          "NvimTreeNormal",
        },
        exclude = {}, -- groups you don't want to clear
      })
    end,
  },
}
