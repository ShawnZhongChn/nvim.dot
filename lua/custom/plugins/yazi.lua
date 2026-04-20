--- @Note: yazi.nvim 插件配置
--- 提供基于 Rust 编写的高性能文件管理器集成，支持原生图片预览和分栏导航。

local M = {}

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note: 获取 Yazi 的主要配置项
--- @return table
local _get_opts = function()
  return {
    -- 悬浮窗配置，匹配项目整体风格
    floating_window_options = {
      border = 'rounded',
      relative = 'editor',
    },
    -- 让 Yazi 接管目录打开行为（如 nvim . / :edit .）
    open_for_directories = true,
    -- 启用 Git 集成
    set_keymaps = false, -- 我们在下面手动定义
    yazi_floating_window_winblend = 0,

    -- @Note: 实现 H/L 导航 (类似 Oil.nvim 的肌肉记忆)
    set_keymappings_function = function(buffer)
      vim.keymap.set('t', 'H', 'h', { buffer = buffer, remap = true })
      vim.keymap.set('t', 'L', 'l', { buffer = buffer, remap = true })
    end,
  }
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note: 配置 Yazi 的全局快捷键
local _setup_keymaps = function()
  -- 替代原有的 Oil 快捷键
  vim.keymap.set('n', '-', '<cmd>Yazi<cr>', { desc = 'Yazi: Open at current file' })
  vim.keymap.set('n', '<space>-', '<cmd>Yazi toggle<cr>', { desc = 'Yazi: Toggle window' })
  vim.keymap.set('n', '<leader>cw', '<cmd>Yazi cwd<cr>', { desc = 'Yazi: Open at CWD' })
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note: 核心初始化逻辑
local _setup_core = function()
  require('yazi').setup(_get_opts())
  _setup_keymaps()
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'mikavilpas/yazi.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = _setup_core,
}
