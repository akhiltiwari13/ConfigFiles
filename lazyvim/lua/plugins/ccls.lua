return {
  -- explaination of ccls.nvim's config
  -- Explanation:
  --     Plugin Declaration: The return statement is used to declare the plugin. The first element is the plugin name ("ccls").
  --     Filetypes: The ft key specifies the filetypes for which the plugin should be loaded.
  --     Options: The opts table contains the configuration for the plugin. This includes the filetypes, lsp server configuration, and other settings like disable_capabilities, disable_diagnostics, etc.
  {
    "ranjithshegde/ccls.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "opencl" },
    opts = {
      filetypes = { "c", "cpp", "objc", "objcpp", "opencl" },
      lsp = {
        server = {
          filetypes = { "c", "cpp", "objc", "objcpp", "opencl" },
          init_options = {
            cache = {
              directory = vim.fs.normalize "~/.cache/ccls/",
            },
          },
          name = "ccls",
          cmd = { "ccls" },
          offset_encoding = "utf-32",
          root_dir = vim.fs.dirname(
            vim.fs.find({ "compile_commands.json", "compile_flags.txt", ".git" }, { upward = true })[1]
          ),
        },
        disable_capabilities = {
          completionProvider = true,
          documentFormattingProvider = true,
          documentRangeFormattingProvider = true,
          documentHighlightProvider = true,
          documentSymbolProvider = true,
          workspaceSymbolProvider = true,
          renameProvider = true,
          hoverProvider = true,
          codeActionProvider = true,
        },
        disable_diagnostics = true,
        disable_signature = true,
        codelens = { enable = true },
      },
    },
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


