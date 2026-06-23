--- @module custom.ui.statusline.palette
--- Statusline highlight and icon palette.

local M = {}
local lib = require 'custom.lib'

local HL_DEFS = {
  branch = { 'DiagnosticOk', lib.ui.icons.branch },
  file = { 'NonText', lib.ui.icons.node },
  fileinfo = { 'Function', lib.ui.icons.document },
  nomodifiable = { 'DiagnosticWarn', lib.ui.icons.bullet },
  modified = { 'DiagnosticError', lib.ui.icons.bullet },
  readonly = { 'DiagnosticWarn', lib.ui.icons.lock },
  error = { 'DiagnosticError', lib.ui.icons.error },
  warn = { 'DiagnosticWarn', lib.ui.icons.warning },
}

function M.icons()
  local processed = {}
  for key, value in pairs(HL_DEFS) do
    processed[key] = lib.hl_str(value[1], value[2])
  end
  return processed
end

return M
