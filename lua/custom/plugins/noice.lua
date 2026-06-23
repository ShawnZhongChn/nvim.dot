local config = require 'custom.config'
local noice = require 'custom.ui.noice'

--- @Note: Noice 配置 - 将 CMD, Messages, Popupmenu UI 化

return {
  'folke/noice.nvim',
  lazy = false,
  priority = 1000,
  enabled = config.get_value({ 'ui', 'noice_enabled' }, true),
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = noice.keys(),
  opts = noice.opts(),
  config = function(_, opts)
    noice.setup(opts)
  end,
}
