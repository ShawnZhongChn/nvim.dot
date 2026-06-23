--- @module custom.ui.statusline.components
--- Statusline component renderers.

local M = {}
local lib = require 'custom.lib'

local api, fn = vim.api, vim.fn
local get_opt = api.nvim_get_option_value
local SCROLLBAR = { '▔', '🮂', '🬂', '🮃', '▀', '▄', '▃', '🬭', '▂', '▁' }

local function _esc_str(str)
  return str:gsub('([%(%)%%%+%-%*%?%[%]%^%$])', '%%%1')
end

function M.path(ctx, icon)
  local mini_icons = require 'mini.icons'
  local file_name = fn.fnamemodify(ctx.file_path, ':t')
  local file_icon, hl = mini_icons.get('file', file_name)

  if ctx.file_path == '' then
    file_name = '[No Name]'
  end

  local path = lib.hl_str(hl, file_icon) .. file_name
  if ctx.buftype == 'help' then
    return icon.file .. path
  end

  local dir_path = fn.fnamemodify(ctx.file_path, ':h') .. '/'
  if dir_path == './' then
    dir_path = ''
  end

  local remote = lib.get_git_remote_name(ctx.root)
  local branch = lib.get_git_branch(ctx.root)
  local repo_info = ''

  if remote and branch and ctx.root then
    dir_path = dir_path:gsub('^' .. _esc_str(ctx.root) .. '/', '')
    repo_info = string.format('%s %s @ %s ', icon.branch, remote, branch)
  end

  if ctx.width < (#repo_info + #dir_path + #path + 5) then
    dir_path = ''
  end
  if ctx.width < (#repo_info + #path) then
    repo_info = ''
  end

  return repo_info .. icon.file .. ' ' .. dir_path .. path .. ' '
end

function M.diagnostics(icon)
  if not lib.diagnostics_available() then
    return ''
  end
  local count = lib.diagnostics.count()
  return string.format(
    '%s %s  %s %s  ',
    icon.error,
    lib.hl_str('DiagnosticError', string.format('%-3d', count[vim.diagnostic.severity.ERROR] or 0)),
    icon.warn,
    lib.hl_str('DiagnosticWarn', string.format('%-3d', count[vim.diagnostic.severity.WARN] or 0))
  )
end

function M.scrollbar()
  local current = api.nvim_win_get_cursor(0)[1]
  local total = api.nvim_buf_line_count(0)
  local index = math.floor((current - 1) / total * #SCROLLBAR) + 1
  return lib.hl_str('Substitute', SCROLLBAR[index]:rep(2))
end

function M.modified(ctx, icon)
  return get_opt('modifiable', { buf = ctx.bufnr }) and (get_opt('modified', { buf = ctx.bufnr }) and icon.modified or ' ') or icon.nomodifiable
end

function M.readonly(ctx, icon)
  return get_opt('readonly', { buf = ctx.bufnr }) and icon.readonly or ''
end

return M
