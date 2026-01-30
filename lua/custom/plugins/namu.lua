--------------------------------------------------------------------------------
-- Header: File Purpose & Description
--------------------------------------------------------------------------------
--- @file namu.lua
--- @desc 配置 namu.nvim，提供类似 Zed 的符号导航与模糊查找功能。
---       包含 UI 定制、LSP 符号跳转及键位增强。
--- @author Custom Config Generator

--------------------------------------------------------------------------------
-- Options Components: Private Configuration Functions
--------------------------------------------------------------------------------

--- 获取插件的核心配置选项
--- @Note 定义 namu.nvim 的外观与行为参数
local function _get_opts()
  return {
    -- 全局配置
    namu_symbols = {
      enable_client_config = true,
      debug = false,

      -- 核心行为配置
      options = {

        display = {
          mode = 'icon', -- 显示图标
          format = 'indent', -- 视觉风格: "indent" (缩进层级) 或 "prefix" (前缀文本)
        },
        movement = {
          next = { '<C-n>', '<Down>' },
          prev = { '<C-p>', '<Up>' },
          close = { '<Esc>' },
          select = { '<CR>' },
        },
      },
    },
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods: Logic & Keymaps
--------------------------------------------------------------------------------

--- 设置插件专用键位映射
--- @Note 仅在插件加载时触发，避免键位污染
local function _set_keymaps()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true, desc = '' }

  -- 核心功能：LSP 符号导航
  opts.desc = 'Namu: Jump to LSP Symbol'
  map('n', '<leader>cs', ':Namu symbols<CR>', opts)

  -- 变体：按类型过滤符号 (例如仅显示函数)
  -- opts.desc = "Namu: Jump to Functions"
  -- map("n", "<leader>sf", ":Namu symbols kind=Function<CR>", opts)
end

--------------------------------------------------------------------------------
-- Core Logic: Integration & Initialization
--------------------------------------------------------------------------------

--- 执行插件初始化逻辑
--- @Note 整合 opts 与 keymaps，并调用 setup
--- @param opts table 插件配置表
local function _setup(_, opts)
  local namu = require 'namu'

  -- 初始化插件
  namu.setup(opts)

  -- 应用增强功能
  _set_keymaps()

  -- 可选：设置高亮组或其他自动命令
  -- vim.api.nvim_set_hl(0, "NamuPreview", { link = "NormalFloat" })
end

--------------------------------------------------------------------------------
-- Plugin Spec: Lazy.nvim Definition
--------------------------------------------------------------------------------

return {
  'bassamsdata/namu.nvim',
  event = 'VeryLazy', -- 延迟加载以优化启动速度

  dependencies = {
    'nvim-lua/plenary.nvim',
  },

  -- 注入配置选项
  opts = _get_opts(),

  config = _setup,
}
