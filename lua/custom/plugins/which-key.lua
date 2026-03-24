---
--- @Note: Which-key 快捷键辅助提示插件
--- 采用中央管理模式，确保 UI 触发响应并解决组名显示问题
---

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note 获取基础视觉与交互配置
--- @return table
local _get_base_opts = function()
  return {
    delay = 0,
    preset = 'helix', -- 适合 4K 屏幕
    triggers = {
      { '<auto>', mode = 'nxso' },
    },
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {} or {
        Up = 'UP ',
        Down = 'DN ',
        Left = 'LT ',
        Right = 'RT ',
        C = 'C-',
        M = 'M-',
        D = 'D-',
        S = 'S-',
        CR = 'RET ',
        Esc = 'ESC ',
        Tab = 'TAB ',
        BS = 'BACK ',
        Space = 'SPC ',
      },
    },
    win = {
      border = 'rounded',
      padding = { 1, 2 },
      wo = { winblend = 5 }, -- 呼应你的 Hyprland 风格
    },
  }
end

--- @Note 定义全局组名映射 (Spec)
--- @return table
local _get_wk_spec = function()
  return {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>cd', group = '[D]iagnostic' },
    { '<leader>cdd', group = 'Document Diagnostics' },
    { '<leader>cdp', group = 'Project Diagnostics' },
    { '<leader>cq', group = 'Quickfix List' },
    { '<leader>cw', group = 'Workspace Diagnostics' },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>n', group = '[N]otices' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>o', group = '[O]bsidian' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>f', group = '[F]iles / Oil', icon = '󰉓 ' },
    { '<leader>l', group = '[L]azy', icon = '󰊢 ' },
    { '<leader>q', proxy = '<c-w>', group = '[W]indows' },
    { '<leader>fs', group = '[S]cratch Pad', icon = '󰄱 ' },
  }
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note 核心管理逻辑
--- 使用 wk.add 确保在插件加载后立即注入组名映射
local _apply_management = function()
  local wk = require 'which-key'
  wk.add(_get_wk_spec())
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note 插件初始化
--- @param opts table
local _setup = function(_, opts)
  local wk = require 'which-key'
  wk.setup(opts)
  _apply_management() -- 确保映射表被正确加载
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = _get_base_opts(),
  config = _setup,
}
