return {
  -- Add Firenvim plugin
  {
    "glacambre/firenvim",
    build = function()
      -- vim.fn
    end,
    -- Load Firenvim only when started by Firenvim
    cond = not not vim.g.started_by_firenvim,
    -- Optional: Additional configuration
    config = function()
      -- Your Firenvim configuration goes here
      vim.g.firenvim_config = {
        localSettings = {
          [".*"] = {
            takeover = "never",  -- Disable Firenvim by default
          },
          ["https?://github\\.com/.*"] = {
            takeover = "always", -- Enable on GitHub
          },
        },
      }

      -- Set options when running inside Firenvim
      if vim.g.started_by_firenvim then
        vim.opt.laststatus = 0
        vim.opt.number = false
        -- Add any other settings you prefer
      end
    end,
  },
}
