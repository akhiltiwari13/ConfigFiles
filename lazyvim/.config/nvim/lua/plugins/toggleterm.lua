-- @TODO: set this up with updated config params esp. for floating terminal
-- refer: https://github.com/akinsho/toggleterm.nvim
return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({})

      -- Define keybindings AFTER setup()
      local toggleterm = require("toggleterm")

      -- Toggle the default terminal
      -- vim.api.nvim_set_keymap('n', '<C-t>', '<cmd>ToggleTerm<CR>', {noremap = true, silent = true})

      -- Toggle specific named terminals (if you defined them)
      -- vim.api.nvim_set_keymap('n', '<leader>mt', '<cmd>ToggleTerm mytop<CR>', {noremap = true, silent = true})
      -- vim.api.nvim_set_keymap('n', '<leader>ld', '<cmd>ToggleTerm lazydocker<CR>', {noremap = true, silent = true})

      -- Example:  Splitting the terminal (vertical, horizontal, window)
      vim.api.nvim_set_keymap('n', '<leader>mw', '<cmd>ToggleTerm direction=window<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>mf', '<cmd>ToggleTerm direction=float<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>mv', '<cmd>ToggleTerm direction=vertical<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>mh', '<cmd>ToggleTerm direction=horizontal<CR>', {noremap = true, silent = true})
      -- Send text to the terminal (useful for sending commands)
      -- vim.api.nvim_set_keymap('n', '<leader>ms', '<cmd>ToggleTermSendCurrentLine<CR>', {noremap = true, silent = true})
      -- vim.api.nvim_set_keymap('v', '<leader>ms', '<cmd>ToggleTermSendVisualSelection<CR>', {noremap = true, silent = true})
    end,
  },
}
