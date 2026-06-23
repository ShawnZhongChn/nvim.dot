--- @module custom.lang.frontend
--- Frontend workflow profile boundary.

local M = {}

function M.profile()
  return {
    name = 'frontend',
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'css', 'json', 'jsonc' },
    lsp_servers = { 'vtsls', 'tailwindcss', 'biome' },
    formatter_policy = 'project-aware-biome-or-prettier',
    linter_policy = 'project-aware-eslint-or-biome',
    test_adapters = { 'neotest-jest', 'neotest-vitest', 'playwright' },
    debug_adapters = { 'node', 'chrome' },
    keymaps = {},
    notes = { 'Supports Biome, ESLint, Prettier, and package-script driven projects.' },
  }
end

function M.setup(bufnr)
  bufnr = bufnr or 0
  vim.bo[bufnr].shiftwidth = 2
  vim.bo[bufnr].tabstop = 2
  vim.bo[bufnr].softtabstop = 2
  vim.bo[bufnr].expandtab = true
  vim.opt_local.colorcolumn = '100'
end

return M
