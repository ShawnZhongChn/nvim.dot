--- @module custom.ui.statusline.context
--- Builds the state object consumed by statusline components.

local M = {}
local lib = require 'custom.lib'

function M.current()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
  local fname = vim.api.nvim_buf_get_name(0)
  local file_path = fname
  if vim.bo.buftype ~= '' and vim.bo.buftype ~= 'help' then
    file_path = vim.bo.ft
  end

  return {
    bufnr = bufnr,
    winid = vim.g.statusline_winid or 0,
    file_path = file_path,
    raw_file_path = fname,
    root = (vim.bo.buftype == '' and lib.get_path_root(fname)) or nil,
    width = vim.api.nvim_win_get_width(0),
    buftype = vim.bo.buftype,
    filetype = vim.bo.ft,
  }
end

return M
