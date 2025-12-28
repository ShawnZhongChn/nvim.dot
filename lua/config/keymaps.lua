-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 插入模式
vim.keymap.set("i", "jk", "<C-\\><C-n>", { noremap = true })
-- 终端模式
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { noremap = true })
-- 可选：连键时间
vim.o.timeoutlen = 300
