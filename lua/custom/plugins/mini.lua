--- @Note Collection of various small independent plugins/modules (mini.nvim)
--------------------------------------------------------------------------

--- @return table
--- @Note 获取 mini.ai 配置：增强 Around/Inside 文本对象
local _get_ai_opts = function()
  return { n_lines = 500 }
end

--- @return table
--- @Note 获取 mini.statusline 配置
local _get_statusline_opts = function()
  return { use_icons = vim.g.have_nerd_font }
end

--------------------------------------------------------------------------

--- @Note 对 statusline 进行格式增强
local _enhance_statusline = function()
  local statusline = require 'mini.statusline'
  -- 自定义位置栏格式为 LINE:COLUMN
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return '%2l:%-2v'
  end
end

--------------------------------------------------------------------------

--- @Note 核心初始化逻辑
local _setup_core = function()
  -- 1. Around/Inside textobjects
  require('mini.ai').setup(_get_ai_opts())

  -- 2. Add/delete/replace surroundings
  require('mini.surround').setup()

  -- 3. Simple and easy statusline
  require('mini.statusline').setup(_get_statusline_opts())
  _enhance_statusline()
end

--------------------------------------------------------------------------

--- @return table
--- @Note 返回 Lazy.nvim 插件定义
return {
  'echasnovski/mini.nvim',
  config = _setup_core,
}
