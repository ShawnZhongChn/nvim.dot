-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 插入模式
-- Keep Insert mode as is (this is fine for text editing)
vim.keymap.set("i", "jk", "<C-\\><C-n>", { noremap = true })

-- CHANGE Terminal mode to use double Esc instead
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { noremap = true })
