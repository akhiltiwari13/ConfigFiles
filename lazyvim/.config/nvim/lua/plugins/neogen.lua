return {
  -- ...
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup {
        enabled = true,
        languages = {
          cpp = {
            template = {
              annotation_convention = "doxygen",
            },
          },
        },
      }
    end,
    -- optional keymap
    keys = {
      { "<leader>cx", function() require("neogen").generate() end, desc = "Generate docstring" },
    },
  },
  -- ...
}
