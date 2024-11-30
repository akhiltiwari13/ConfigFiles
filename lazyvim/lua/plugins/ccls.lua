return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ccls = {
          init_options = {
            cache = {
              directory = "./.ccls"
            },
            clang = {
              extraArgs = {"-std=c++20"},
            },
          },
        },
      },
    },
  },
}
