-- @TODO: set this up with updated config params esp. for floating terminal
-- refer: https://github.com/akinsho/toggleterm.nvim
return{
{
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      -- Default configuration (you can customize these)
      size = 0.5, -- Percentage of screen to use
      -- open_mapping = '<C-/>', -- Key to open/close the terminal
      open_mapping = '<leader>mt', -- Key to open/close the terminal
      hide_numbers = false, -- Hide line numbers in the terminal
      shade_terminals = true, -- Shade the terminal when it's not focused
      shade_filetypes = {}, -- Filetypes to shade the terminal in
      --persistent_mode = true, -- Keep the terminal open even when closing Neovim (experiment)
      direction = 'float', -- 'float', 'vertical', 'horizontal', 'window'
      close_on_exit = true, -- Close the terminal when the process exits
      shell = '/bin/zsh', -- Use Neovim's default shell
      -- shell = vim.fn.shell(), -- Use Neovim's default shell
       -- OR explicitly set it: shell = '/bin/bash',
      -- OR use a function for more complex logic:
      -- shell = function() return vim.fn.executable('zsh') == 1 and 'zsh' or 'bash' end,
      float_opts = {
        border = 'rounded',  -- Or 'single', 'double', 'shadow'
        -- Other float options if needed
      },
       -- You can have multiple named terminals
      -- [[
      -- Example:
        terminals = {
          htop = { cmd = "htop" },
          bottom = { cmd = "btm" },
          lazydocker = { cmd = "lazydocker" },
          lazygit = { cmd = "lazygit" },
        }
      -- ]]
    }


    -- Define keybindings AFTER setup()
    local toggleterm = require('toggleterm')

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
    vim.api.nvim_set_keymap('n', '<leader>ms', '<cmd>ToggleTermSendCurrentLine<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('v', '<leader>ms', '<cmd>ToggleTermSendVisualSelection<CR>', {noremap = true, silent = true})



  end,
}
} 
-- Explanation of Key Changes for LazyVim
--
--     Plugin Declaration:
--         The return statement is used to declare the plugin. The first element is the plugin name ("akinsho/toggleterm.nvim").
--         The version = "*" ensures that the latest version of the plugin is used.
--
--     Configuration Function:
--         The config function is used to set up the plugin. Inside this function, we call require("toggleterm").setup() with the configuration options.
--
--     Size Function:
--         The size option is set to a function that dynamically adjusts the terminal size based on its direction (horizontal or vertical).
--
--     Open Mapping:
--         The open_mapping is set to <c-\> (Ctrl + ), which is a common keybinding for opening the terminal.
--
--     Highlights:
--         The highlights section allows you to customize the appearance of the terminal window. You can set the background color (guibg) and border colors (guifg, guibg).
--
--     Float Options:
--         The float_opts section configures the appearance of the floating terminal. You can set the border style, width, height, position, and transparency.
--
--     Winbar:
--         The winbar section allows you to enable or disable the terminal name in the winbar (top bar of the window).
--
--     Responsiveness:
--         The responsiveness section allows you to set a breakpoint for when terminals should stack vertically instead of horizontally.
--
-- Additional Features
--
--     Auto Scroll: The auto_scroll option ensures that the terminal automatically scrolls to the bottom when new output is generated.
--     Persist Size and Mode: The persist_size and persist_mode options ensure that the terminal size and mode are remembered across sessions.
--     Close on Exit: The close_on_exit option ensures that the terminal window closes when the process exits.
--
