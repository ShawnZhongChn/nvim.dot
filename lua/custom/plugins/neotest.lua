--- @Note: Neotest 配置 (单元测试)
--- @url: https://github.com/nvim-neotest/neotest

return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'mrcjkb/rustaceanvim',
    },
    keys = {
      { '<leader>tr', function() require('neotest').run.run() end,                      desc = 'Neotest: Run Nearest' },
      { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end,    desc = 'Neotest: Run File' },
      { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end,  desc = 'Neotest: Debug Nearest' },
      { '<leader>ts', function() require('neotest').summary.toggle() end,               desc = 'Neotest: Summary' },
      { '<leader>to', function() require('neotest').output.open({ enter = true }) end,  desc = 'Neotest: Output' },
    },
    opts = function()
      return {
        adapters = {
          require('rustaceanvim.neotest'),
        },
      }
    end,
    config = function(_, opts)
      require('neotest').setup(opts)
    end,
  },
}
