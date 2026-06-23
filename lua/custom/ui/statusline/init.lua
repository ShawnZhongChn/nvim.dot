--- @module custom.ui.statusline
--- Public statusline API.

local M = {}
local context = require 'custom.ui.statusline.context'
local render = require 'custom.ui.statusline.render'

function M.render()
  return render.render_with_context(context.current())
end

function M.render_with_context(ctx)
  return render.render_with_context(ctx)
end

function M.setup()
  _G.statusline_render = M.render
  vim.o.statusline = '%!v:lua.statusline_render()'
end

return M
