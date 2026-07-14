--- @module custom.debug
--- Debug workflow boundary and adapters.

local M = {}

function M.keys()
  return {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: Continue' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'DAP: Step Into' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'DAP: Step Over' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'DAP: Step Out' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'DAP: UI' },
  }
end

function M.setup()
  local dap = require 'dap'
  local dapui = require 'dapui'

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
end

return M
