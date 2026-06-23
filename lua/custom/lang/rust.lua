--- @module custom.lang.rust
--- Rust workflow profile boundary.

local M = {}

function M.profile()
  return {
    name = 'rust',
    filetypes = { 'rust' },
    lsp_servers = { 'rustaceanvim' },
    formatter_policy = 'rustfmt',
    linter_policy = 'clippy',
    test_adapters = { 'rustaceanvim.neotest' },
    debug_adapters = { 'codelldb' },
    keymaps = {
      { mode = 'n', lhs = '<leader>re', rhs = function() vim.cmd.RustLsp('explainError') end, desc = 'Explain Error' },
      { mode = 'n', lhs = '<leader>rj', rhs = function() vim.cmd.RustLsp('joinLines') end, desc = 'Join Lines' },
      { mode = 'n', lhs = '<leader>rc', rhs = function() vim.cmd.RustLsp('openCargo') end, desc = 'Open Cargo.toml' },
      { mode = 'n', lhs = '<leader>rg', rhs = function() vim.cmd.RustLsp('crateGraph') end, desc = 'Crate Graph' },
      { mode = 'n', lhs = 'gd', rhs = vim.lsp.buf.definition, desc = 'Go to Definition' },
      { mode = 'n', lhs = 'gD', rhs = vim.lsp.buf.declaration, desc = 'Go to Declaration' },
      { mode = 'n', lhs = 'gi', rhs = vim.lsp.buf.implementation, desc = 'Go to Implementation' },
      { mode = 'n', lhs = 'gr', rhs = vim.lsp.buf.references, desc = 'References' },
      { mode = 'n', lhs = '<leader>rn', rhs = vim.lsp.buf.rename, desc = 'Rename' },
      { mode = 'n', lhs = '<leader>uh', rhs = function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      end, desc = 'Toggle Inlay Hints' },
    },
    notes = { 'Keeps rustaceanvim-specific actions but delegates platform behavior to custom.debug/custom.test.' },
  }
end

function M.setup()
  vim.bo.shiftwidth = 4
  vim.bo.tabstop = 4
  vim.bo.softtabstop = 4
  vim.bo.expandtab = true
  vim.wo.colorcolumn = '100'
  vim.lsp.inlay_hint.enable(true, { bufnr = 0 })

  for _, spec in ipairs(M.profile().keymaps) do
    vim.keymap.set(spec.mode, spec.lhs, spec.rhs, { buffer = 0, silent = true, desc = spec.desc })
  end
end

return M
