--- @module custom.ui.diagnostics
--- Diagnostic UI boundary.

local M = {}

function M.inline_opts()
  return {
    preset = 'powerline',
    transparent_background = false,
    show_source = true,
    show_message = true,
    overflow = { mode = 'wrap' },
    break_line = { enabled = false, chunk_size = 20 },
  }
end

function M.copy_line_and_diagnostic()
  local current_line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = row })

  if #diags == 0 then
    vim.notify('当前行无诊断信息', vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', current_line .. '\n' .. diags[1].message)
  vim.notify('已复制行与诊断信息', vim.log.levels.INFO)
end

function M.keys()
  return {
    { '<leader>xp', M.copy_line_and_diagnostic, desc = 'Copy Line & Diagnostic' },
  }
end

function M.setup_inline(opts)
  vim.diagnostic.config { virtual_text = false }
  require('tiny-inline-diagnostic').setup(opts or M.inline_opts())
end

return M
