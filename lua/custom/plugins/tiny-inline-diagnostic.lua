local diagnostics = require 'custom.ui.diagnostics'

---@Note: Configuration for tiny-inline-diagnostic.nvim
---Provides a modernized, inline diagnostic display with visual enhancements.

return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'LspAttach',
  priority = 1000,
  opts = diagnostics.inline_opts(),
  keys = diagnostics.keys(),
  config = function(_, opts)
    diagnostics.setup_inline(opts)
  end,
}
