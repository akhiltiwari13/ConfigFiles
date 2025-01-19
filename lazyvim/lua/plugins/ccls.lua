return {
  {
    "ranjithshegde/ccls.nvim"
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ccls = {
          init_options = {
            cache = {
              directory = "./.ccls-cache"
            },
            clang = {
              extraArgs = {"-std=c++20"},
            },
          },
          index = {
            threads = 8,
          },
        },
      },
    },
  },
}
