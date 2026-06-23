--- @module custom.lsp.diagnostics
--- Diagnostic policy for LSP-backed buffers.

local M = {}

--- @return table
function M.opts()
  return {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = false,
  }
end

function M.setup()
  vim.diagnostic.config(M.opts())
end

return M
