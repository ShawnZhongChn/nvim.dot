--- @module custom.lib.diagnostics
--- Diagnostic availability and count helpers.

local M = {}

--- @param bufnr integer|nil
--- @return boolean
function M.available(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr or 0 }
  local method = vim.lsp.protocol.Methods.textDocument_publishDiagnostics
  for _, client in pairs(clients) do
    if client:supports_method(method) then
      return true
    end
  end
  return false
end

--- @param bufnr integer|nil
--- @return table
function M.count(bufnr)
  local counts = {
    [vim.diagnostic.severity.ERROR] = 0,
    [vim.diagnostic.severity.WARN] = 0,
    [vim.diagnostic.severity.INFO] = 0,
    [vim.diagnostic.severity.HINT] = 0,
  }

  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr or 0)) do
    counts[diagnostic.severity] = (counts[diagnostic.severity] or 0) + 1
  end

  return counts
end

return M
