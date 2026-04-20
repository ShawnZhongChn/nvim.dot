--- @Note: Conform 代码格式化配置
--- 轻量级且强大的格式化工具，支持多种语言后端及 LSP 回退机制。
--- @url: https://github.com/stevearc/conform.nvim

--------------------------------------------------------------------------------
-- [Options Components]
--------------------------------------------------------------------------------

--- @Note: 定义各文件类型的格式化工具
--- @return table
local _get_formatters_by_ft = function()
  return {
    lua = { 'stylua' },
    javascript = { 'biome', stop_after_first = true },
    javascriptreact = { 'biome', stop_after_first = true },
    typescript = { 'biome', stop_after_first = true },
    typescriptreact = { 'biome', stop_after_first = true },
    css = { 'biome', stop_after_first = true },
    json = { 'biome', stop_after_first = true },
    jsonc = { 'biome', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
  }
end

--- @Note: 保存时格式化的逻辑判断
--- @param bufnr number
--- @return table|nil
local _get_save_opts = function(bufnr)
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
local _get_opts = function()
  return {
    notify_on_error = false,
    formatters_by_ft = _get_formatters_by_ft(),
    format_on_save = _get_save_opts,
  }
end

--------------------------------------------------------------------------------
-- [Enhancement Methods]
--------------------------------------------------------------------------------

--- @Note: 手动触发格式化的回调函数
local _manual_format = function()
  require('conform').format {
    async = true,
    lsp_format = 'fallback',
  }
end

--------------------------------------------------------------------------------
-- [Core Logic]
--------------------------------------------------------------------------------

--- @Note: 插件初始化
--- @param opts table
local _config = function(_, opts)
  require('conform').setup(opts)
end

--------------------------------------------------------------------------------
-- [Plugin Spec]
--------------------------------------------------------------------------------

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = _get_opts(),
  config = _config,
  keys = {
    {
      '<leader>cf',
      _manual_format,
      mode = { 'n', 'v' },
      desc = '[C]ode [F]ormat',
    },
  },
}
