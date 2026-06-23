--- @module custom.lib.system
--- Platform helpers for opening files and URLs.

local M = {}

local config = require 'custom.config'

--- @param cmd string
--- @return boolean
function M.executable(cmd)
  return vim.fn.executable(cmd) == 1
end

--- @param path string
--- @return table
local function _reveal_command(path)
  local override = config.get_value({ 'env', 'file_reveal_cmd' }, nil)
  if override and override ~= '' then
    return { override, path }
  end

  if vim.fn.has 'mac' == 1 then
    return { 'open', '-R', path }
  end

  if vim.fn.has 'win32' == 1 then
    return { 'explorer.exe', '/select,', vim.fn.toascii(path) }
  end

  return { 'xdg-open', vim.fn.fnamemodify(path, ':h') }
end

--- @param path string
--- @return nil
function M.reveal_in_file_manager(path)
  local target = path and vim.fn.expand(path) or ''
  if target == '' then
    return
  end

  vim.system(_reveal_command(target), { detach = true })
end

--- @param url string
--- @return nil
function M.open_url(url)
  local target = url or ''
  if target == '' then
    return
  end

  local override = config.get_value({ 'env', 'system_open_cmd' }, nil)
  if override and override ~= '' then
    vim.system({ override, target }, { detach = true })
    return
  end

  if vim.fn.has 'mac' == 1 then
    vim.system({ 'open', target }, { detach = true })
  elseif vim.fn.has 'win32' == 1 then
    vim.system({ 'cmd', '/c', 'start', '', target }, { detach = true })
  else
    vim.system({ 'xdg-open', target }, { detach = true })
  end
end

return M
