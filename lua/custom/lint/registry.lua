--- @module custom.lint.registry
--- Lint policy registry used by nvim-lint.

local M = {}

--- @return table<string, string[]>
function M.linters_by_ft()
  return {
    markdown = { 'markdownlint-cli2' },
    dockerfile = { 'hadolint' },
  }
end

function M.setup_autocmds()
  local lint_augroup = vim.api.nvim_create_augroup('lint_logic', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      local lint = require 'lint'
      if vim.bo.modifiable and vim.bo.buftype == '' then
        lint.try_lint()
      end
    end,
  })
end

return M
