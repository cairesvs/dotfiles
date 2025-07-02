-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- File operations
map("n", "<leader>q", ":q<cr>", { desc = "Quit" })
map("n", "<leader>Q", ":qa<cr>", { desc = "Quit all" })
map("n", "<leader>w", ":w<cr>", { desc = "Save" })

-- Clear search highlighting
map("n", "<leader>h", ":nohl<cr>", { desc = "Clear search highlight" })
