--- @Note: Rust 文件专属设置
--- @url: https://github.com/mrcjkb/rustaceanvim

vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.wo.colorcolumn = '100'

-- 开启 inlay hints (Neovim 0.10+)
vim.lsp.inlay_hint.enable(true, { bufnr = 0 })

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = 0, silent = true, desc = desc })
end

-- rustaceanvim 命令
map('<leader>re', function() vim.cmd.RustLsp('explainError') end,   'Explain Error')
map('<leader>rj', function() vim.cmd.RustLsp('joinLines') end,      'Join Lines')
map('<leader>rc', function() vim.cmd.RustLsp('openCargo') end,      'Open Cargo.toml')
map('<leader>rg', function() vim.cmd.RustLsp('crateGraph') end,     'Crate Graph')

-- LSP 通用
map('gd', vim.lsp.buf.definition,     'Go to Definition')
map('gD', vim.lsp.buf.declaration,    'Go to Declaration')
map('gi', vim.lsp.buf.implementation, 'Go to Implementation')
map('gr', vim.lsp.buf.references,     'References')
map('<leader>rn', vim.lsp.buf.rename, 'Rename')

-- Inlay hints 切换
vim.keymap.set('n', '<leader>uh', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { buffer = 0, desc = 'Toggle Inlay Hints' })
