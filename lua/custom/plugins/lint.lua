local registry = require 'custom.lint.registry'

--- @note 静态检查工具配置 (Linting)
--- 专门用于非 LSP 支持的文件类型（Markdown, JSON 等）的语法错误检测

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('lint').linters_by_ft = registry.linters_by_ft()
    registry.setup_autocmds()
  end,
}
