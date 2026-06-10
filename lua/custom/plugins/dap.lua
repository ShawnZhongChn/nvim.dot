--- @Note: DAP 配置 (调试适配器协议)
--- @url: https://github.com/mfussenegger/nvim-dap

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end,          desc = 'DAP: Continue' },
      { '<leader>di', function() require('dap').step_into() end,         desc = 'DAP: Step Into' },
      { '<leader>do', function() require('dap').step_over() end,         desc = 'DAP: Step Over' },
      { '<leader>dO', function() require('dap').step_out() end,          desc = 'DAP: Step Out' },
      { '<leader>du', function() require('dapui').toggle() end,          desc = 'DAP: UI' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
