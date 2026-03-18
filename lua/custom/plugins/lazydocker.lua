--- @Note: Lazydocker 配置
--- 提供容器化管理工具的浮窗集成。

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note: 定义快捷键映射
--- @return table
local _setup_keymaps = function()
  return {
    { '<leader>ld', function() require('lazydocker').open() end, desc = 'LazyDocker' },
  }
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note 插件初始化逻辑与 Lazy.nvim 规格定义
--- @return table
local _build_spec = function()
  return {
    'mgierada/lazydocker.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'akinsho/toggleterm.nvim',
    },
    opts = {
      -- 可以在此添加自定义配置
    },
    keys = _setup_keymaps(),
  }
end

return _build_spec()
