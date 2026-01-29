-----
--- @Note: Kanagawa 色彩方案
--- 已修复 overrides 类型错误，并针对 4K 屏幕与 Hyprland 透明背景优化。
---

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note 获取 Kanagawa 的核心配置
--- @return table
local _get_opts = function()
  return {
    compile = true,
    undercurl = true,
    commentStyle = { italic = false },
    functionStyle = {},
    keywordStyle = { italic = false },
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = true, -- 适配 Hyprland 透明度
    dimInactive = true,
    terminalColors = true,
    theme = 'wave', -- 针对大屏优化的深色变体
  }
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note 初始化色彩方案
--- @param opts table
local _setup = function(_, opts)
  local kanagawa = require 'kanagawa'

  kanagawa.setup(opts)

  -- 正式应用主题变体
  vim.cmd 'colorscheme kanagawa-wave'
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'rebelot/kanagawa.nvim',
  priority = 1000,
  lazy = false,
  opts = _get_opts(),
  config = _setup,
}
