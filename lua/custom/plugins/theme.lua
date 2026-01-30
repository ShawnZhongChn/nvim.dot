--- @Note: GitHub Monochrome 颜色方案 - 极简黑白配置
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- 获取插件基础配置
--- @return table
local _get_opts = function()
  return {
    -- 可以在此处添加插件支持的自定义选项
  }
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- 针对特定 UI 组件的微调
local _apply_custom_highlights = function()
  -- 预留位置用于处理与 Lualine 或其他插件的兼容性
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- 整合与初始化
--- @param opts table
local _setup = function(_, opts)
  local theme = require 'github-monochrome'
  theme.setup(opts)

  _apply_custom_highlights()

  -- 设置背景并激活 dark 变体
  vim.o.background = 'dark'
  vim.cmd.colorscheme 'github-monochrome-dark'
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'idr4n/github-monochrome.nvim',
  priority = 1000,
  lazy = false,
  opts = _get_opts(),
  config = _setup,
}
