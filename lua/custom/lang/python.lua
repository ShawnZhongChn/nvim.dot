--- @module custom.lang.python
--- Python workflow profile boundary.

local M = {}

function M.profile()
  return {
    name = 'python',
    filetypes = { 'python' },
    lsp_servers = { 'basedpyright', 'ruff' },
    formatter_policy = 'ruff-or-lsp-fallback',
    linter_policy = 'ruff',
    test_adapters = { 'neotest-python' },
    debug_adapters = { 'debugpy' },
    keymaps = {},
    notes = { 'Supports project-local typing policy via custom.config.' },
  }
end

function M.setup(bufnr)
  bufnr = bufnr or 0
  vim.bo[bufnr].shiftwidth = 4
  vim.bo[bufnr].tabstop = 4
  vim.bo[bufnr].softtabstop = 4
  vim.bo[bufnr].expandtab = true
  vim.opt_local.colorcolumn = '88'
end

return M
