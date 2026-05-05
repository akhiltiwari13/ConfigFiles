-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Alt-hjkl: vim-motion split resize (mirrors tmux M-hjkl resize)
vim.keymap.set("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "Resize split left" })
vim.keymap.set("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "Resize split right" })
vim.keymap.set("n", "<M-j>", "<cmd>resize -2<cr>", { desc = "Resize split down" })
vim.keymap.set("n", "<M-k>", "<cmd>resize +2<cr>", { desc = "Resize split up" })
