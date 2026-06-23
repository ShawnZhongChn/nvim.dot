local test = require 'custom.test'

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
    keys = test.keys(),
    opts = function()
      return {
        adapters = test.adapters(),
      }
    end,
    config = function(_, opts)
      require('neotest').setup(opts)
    end,
  },
}
