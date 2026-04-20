local M = {}

local _handlers = {
  python = function()
    return require 'custom.folding.languages.python'
  end,
}

local _apply_for_buffer = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].buftype ~= '' or not vim.bo[bufnr].modifiable then
    return
  end

  local load_handler = _handlers[vim.bo[bufnr].filetype]
  if not load_handler then
    return
  end

  local handler = load_handler()
  if type(handler) ~= 'table' or type(handler.apply) ~= 'function' then
    return
  end

  handler.apply(bufnr)
end

function M.setup()
  if M._did_setup then
    return
  end

  M._did_setup = true

  local augroup = vim.api.nvim_create_augroup('custom-folding', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter', 'BufWritePost', 'LspAttach' }, {
    group = augroup,
    callback = function(args)
      vim.schedule(function()
        _apply_for_buffer(args.buf)
      end)
    end,
  })
end

return M
