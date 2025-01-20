-- @TODO: set this up with updated config params esp. for floating terminal
-- refer: https://github.com/akinsho/toggleterm.nvim
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {},
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
