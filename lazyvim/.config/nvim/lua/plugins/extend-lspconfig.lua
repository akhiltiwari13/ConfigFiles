-- Clone the WezTerm types repository to a local directory
local wezterm_types_path = vim.fn.expand("~/.config/wezterm/types")
if not vim.loop.fs_stat(wezterm_types_path) then
  os.execute("git clone https://github.com/justinsgithub/wezterm-types.git " .. wezterm_types_path)
end

-- Configure the Lua LSP in LazyVim
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sumneko_lua = {
          settings = {
            Lua = {
              workspace = {
                library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), { wezterm_types_path }),
              },
            },
          },
        },
      },
    },
  },
}
