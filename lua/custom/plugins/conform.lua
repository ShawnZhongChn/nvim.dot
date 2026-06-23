local registry = require 'custom.format.registry'

--- @Note: Conform 代码格式化配置
--- @url: https://github.com/stevearc/conform.nvim

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    notify_on_error = false,
    formatters_by_ft = registry.formatters_by_ft(),
    format_on_save = function(bufnr)
      local result = registry.resolve(bufnr)
      if not result then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = result.lsp_format or 'fallback',
      }
    end,
  },
  config = function(_, opts)
    require('conform').setup(opts)
  end,
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = { 'n', 'v' },
      desc = '[C]ode [F]ormat',
    },
  },
}
