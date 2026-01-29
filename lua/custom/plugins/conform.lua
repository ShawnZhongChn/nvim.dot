----------------- @Note: Conform 代码格式化配置
--- 轻量级且强大的格式化工具，支持多种语言后端及 LSP 回退机制。
--- @url: https://github.com/stevearc/conform.nvim

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- @Note: 定义各文件类型的格式化工具
--- @return table
local function _get_formatters_by_ft()
  return {
    lua = { 'stylua' },
    -- 常用 Web 开发配置 (预留)
    -- javascript = { "prettierd", "prettier", stop_after_first = true },
    -- typescript = { "prettierd", "prettier", stop_after_first = true },
    -- css = { "prettierd", "prettier", stop_after_first = true },
    -- html = { "prettierd", "prettier", stop_after_first = true },
    -- json = { "prettierd", "prettier", stop_after_first = true },
    -- python = { "isort", "black" },
  }
end

--- @Note: 保存时格式化的逻辑判断
--- @param bufnr number
--- @return table|nil
local function _get_save_opts(bufnr)
  -- 定义不启用自动格式化的文件类型 (如 C/C++ 往往没有统一标准)
  local disable_filetypes = { c = true, cpp = true }

  if disable_filetypes[vim.bo[bufnr].filetype] then
    return nil
  end

  return {
    timeout_ms = 500,
    lsp_format = 'fallback',
  }
end

--- @Note: 获取核心配置项
--- @return table
local function _get_opts()
  return {
    notify_on_error = false,
    formatters_by_ft = _get_formatters_by_ft(),
    format_on_save = _get_save_opts, -- 引用处理函数
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- @Note: 手动触发格式化的回调函数
--- @param _ nil 占位符
local function _manual_format(_)
  require('conform').format {
    async = true,
    lsp_format = 'fallback',
  }
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- @Note: 插件初始化
--- @param opts table
local function _config(_, opts)
  require('conform').setup(opts)
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = _get_opts(),
    config = _config,
    keys = {
      {
        '<leader>cf',
        _manual_format,
        mode = '',
        desc = 'Format: Current Buffer',
      },
    },
  },
}
