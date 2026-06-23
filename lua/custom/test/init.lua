--- @module custom.test
--- Test workflow boundary and adapters.

local M = {}

function M.keys()
  return {
    { '<leader>tr', function() require('neotest').run.run() end, desc = 'Neotest: Run Nearest' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Neotest: Run File' },
    { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Neotest: Debug Nearest' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Neotest: Summary' },
    { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Neotest: Output' },
  }
end

function M.adapters()
  return {
    require('rustaceanvim.neotest'),
  }
end

function M.setup()
end

return M
