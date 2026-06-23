local debug = require 'custom.debug'

--- @Note: DAP 配置 (调试适配器协议)
--- @url: https://github.com/mfussenegger/nvim-dap

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = debug.keys(),
    config = function()
      debug.setup()
    end,
  },
}
