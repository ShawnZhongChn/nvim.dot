--- @Note 静态检查工具配置 (Linting)
--- 专门用于非 LSP 支持的文件类型（Markdown, JSON 等）的语法错误检测

--------------------------------------------------------------------------------
-- [Options Components]
--------------------------------------------------------------------------------

local _get_linters = function()
  return {
    markdown = { 'markdownlint-cli2' },
    json = { 'jsonlint' },
    dockerfile = { 'hadolint' },
  }
end

--------------------------------------------------------------------------------
-- [Enhancement Methods]
--------------------------------------------------------------------------------

--- @Note 安全触发检查
local _try_lint_safely = function()
  local lint = require 'lint'
  -- 只有在可修改的正常缓冲区中才运行，避免在插件浮窗、备忘录中报错
  if vim.bo.modifiable and vim.bo.buftype == '' then
    lint.try_lint()
  end
end

--------------------------------------------------------------------------------
-- [Core Logic]
--------------------------------------------------------------------------------

local _setup_autocmds = function()
  local lint_augroup = vim.api.nvim_create_augroup('lint_logic', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = _try_lint_safely,
  })
end

--------------------------------------------------------------------------------
-- [Plugin Spec]
--------------------------------------------------------------------------------

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('lint').linters_by_ft = _get_linters()
    _setup_autocmds()
  end,
}
