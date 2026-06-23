--- @module custom.ui
--- UI namespace and top-level boundary.

local M = {}

M.statusline = require 'custom.ui.statusline'
M.noice = require 'custom.ui.noice'
M.diagnostics = require 'custom.ui.diagnostics'
M.picker = require 'custom.ui.picker'
M.explorer = require 'custom.ui.explorer'

function M.setup()
end

return M
