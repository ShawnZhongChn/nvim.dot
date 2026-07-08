--- @module custom.lang.java
--- Java workflow profile boundary.

local M = {}

function M.profile()
  return {
    name = 'java',
    filetypes = { 'java' },
    lsp_servers = { 'jdtls' },
    formatter_policy = 'google-java-format-or-lsp-fallback',
    linter_policy = nil,
    test_adapters = {},
    debug_adapters = {},
    keymaps = {},
    notes = {
      'Maven projects use pom.xml as the primary root marker.',
      'JDTLS is installed through Mason; Lombok support uses the lombok.jar shipped with Mason jdtls when present.',
      'JDK runtime is discovered from JAVA_HOME or PATH before jdtls starts.',
    },
  }
end

function M.setup(bufnr)
  bufnr = bufnr or 0
  vim.bo[bufnr].shiftwidth = 4
  vim.bo[bufnr].tabstop = 4
  vim.bo[bufnr].softtabstop = 4
  vim.bo[bufnr].expandtab = true
  vim.opt_local.colorcolumn = '120'
end

return M
