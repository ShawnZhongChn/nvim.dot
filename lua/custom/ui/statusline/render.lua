--- @module custom.ui.statusline.render
--- Composes statusline components into the final string.

local M = {}
local palette = require 'custom.ui.statusline.palette'
local components = require 'custom.ui.statusline.components'

local ORDER = { 'pad', 'path', 'venv', 'mod', 'ro', 'sep', 'diag', 'fileinfo', 'pad', 'scrollbar', 'pad' }

function M.render_with_context(ctx)
  local icon = palette.icons()
  local parts = {
    pad = ' ',
    path = components.path(ctx, icon),
    sep = '%=',
    diag = components.diagnostics(icon),
    scrollbar = components.scrollbar(),
    mod = components.modified(ctx, icon),
    ro = components.readonly(ctx, icon),
  }

  local out = {}
  for _, key in ipairs(ORDER) do
    if parts[key] and parts[key] ~= '' then
      table.insert(out, parts[key])
    end
  end
  return table.concat(out, ' ')
end

return M
