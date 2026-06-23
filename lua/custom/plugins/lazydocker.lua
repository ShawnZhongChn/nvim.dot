--- @note LazyDocker 插件适配器

local lazydocker = require 'custom.terminal.lazydocker'

return {
  'akinsho/toggleterm.nvim',
  event = 'VeryLazy',
  opts = {
    autochdir = false,
  },
  keys = lazydocker.keys(),
  config = function()
    -- adapter only; the terminal behavior lives in custom.terminal.lazydocker
  end,
}
