--- @Note: 一个基于原生 API 和逻辑构建的高效、响应式状态栏配置。
--- 遵循结构化布局规范：Options -> Enhancement -> Core -> Spec

local M = {}

-- =============================================================================
-- Options Components (私有配置与静态定义)
-- =============================================================================

local api, fn, bo = vim.api, vim.fn, vim.bo
local get_opt = api.nvim_get_option_value

local PAD = ' '
local SEP = '%='
local SBAR = { '▔', '🮂', '🬂', '🮃', '▀', '▄', '▃', '🬭', '▂', '▁' }

--- @return table 状态栏渲染顺序定义
local _ORDER = {
  'pad',
  'path',
  'venv',
  'mod',
  'ro',
  'sep',
  'diag',
  'fileinfo',
  'pad',
  'scrollbar',
  'pad',
}

--- @return table 预处理后的图标与高亮映射
local function _get_icons()
  local icons = tools.ui.icons
  local HL_DEFS = {
    branch = { 'DiagnosticOk', icons.branch },
    file = { 'NonText', icons.node },
    fileinfo = { 'Function', icons.document },
    nomodifiable = { 'DiagnosticWarn', icons.bullet },
    modified = { 'DiagnosticError', icons.bullet },
    readonly = { 'DiagnosticWarn', icons.lock },
    error = { 'DiagnosticError', icons.error },
    warn = { 'DiagnosticWarn', icons.warning },
  }

  local processed = {}
  for k, v in pairs(HL_DEFS) do
    processed[k] = tools.hl_str(v[1], v[2])
  end
  return processed
end

-- =============================================================================
-- Enhancement Methods (逻辑增强函数)
-- =============================================================================

--- 字符串转义处理
local function _esc_str(str)
  return str:gsub('([%(%)%%%+%-%*%?%[%]%^%$])', '%%%1')
end

--- 路径与 Git 信息组件
local function _path_widget(root, fname, ICON)
  local mini_icons = require 'mini.icons'
  local file_name = fn.fnamemodify(fname, ':t')
  local icon, hl = mini_icons.get('file', file_name)

  if fname == '' then
    file_name = '[No Name]'
  end
  local path = tools.hl_str(hl, icon) .. file_name

  if bo.buftype == 'help' then
    return ICON.file .. path
  end

  local dir_path = fn.fnamemodify(fname, ':h') .. '/'
  if dir_path == './' then
    dir_path = ''
  end

  local remote = tools.get_git_remote_name(root)
  local branch = tools.get_git_branch(root)
  local repo_info = ''

  if remote and branch then
    dir_path = dir_path:gsub('^' .. _esc_str(root) .. '/', '')
    repo_info = string.format('%s %s @ %s ', ICON.branch, remote, branch)
  end

  -- 响应式宽度裁剪
  local win_w = api.nvim_win_get_width(0)
  if win_w < (#repo_info + #dir_path + #path + 5) then
    dir_path = ''
  end
  if win_w < (#repo_info + #path) then
    repo_info = ''
  end

  return repo_info .. ICON.file .. ' ' .. dir_path .. path .. ' '
end

--- 诊断信息组件
local function _diag_widget(ICON)
  if not tools.diagnostics_available() then
    return ''
  end
  local count = vim.diagnostic.count()
  return string.format(
    '%s %s  %s %s  ',
    ICON.error,
    tools.hl_str('DiagnosticError', string.format('%-3d', count[1] or 0)),
    ICON.warn,
    tools.hl_str('DiagnosticWarn', string.format('%-3d', count[2] or 0))
  )
end

--- 滚动条组件
local function _scrollbar_widget()
  local cur = api.nvim_win_get_cursor(0)[1]
  local total = api.nvim_buf_line_count(0)
  local idx = math.floor((cur - 1) / total * #SBAR) + 1
  return tools.hl_str('Substitute', SBAR[idx]:rep(2))
end

-- =============================================================================
-- Core Logic (整合与初始化)
-- =============================================================================

--- 渲染核心函数
--- @return string 最终的 statusline 字符串
function M.render()
  local ICON = _get_icons()
  local fname = api.nvim_buf_get_name(0)
  local root = (bo.buftype == '' and tools.get_path_root(fname)) or nil
  if bo.buftype ~= '' and bo.buftype ~= 'help' then
    fname = bo.ft
  end

  local buf = api.nvim_win_get_buf(vim.g.statusline_winid or 0)

  local parts = {
    pad = PAD,
    path = _path_widget(root, fname, ICON),
    sep = SEP,
    diag = _diag_widget(ICON),
    scrollbar = _scrollbar_widget(),
    mod = get_opt('modifiable', { buf = buf }) and (get_opt('modified', { buf = buf }) and ICON.modified or ' ') or ICON.nomodifiable,
    ro = get_opt('readonly', { buf = buf }) and ICON.readonly or '',
    -- 其他组件可按需在此调用私有 widget 函数...
  }

  local out = {}
  for _, k in ipairs(_ORDER) do
    if parts[k] and parts[k] ~= '' then
      table.insert(out, parts[k])
    end
  end
  return table.concat(out, ' ')
end

-- =============================================================================
-- Plugin Spec (Lazy.nvim 插件定义)
-- =============================================================================

--- @return table 插件 Spec
function M.spec()
  return {
    'echasnovski/mini.icons', -- 依赖图标库
    lazy = false,
    config = function()
      -- 注册全局调用接口
      _G.statusline_render = M.render
      vim.o.statusline = '%!v:lua.statusline_render()'
    end,
  }
end

return M.spec()
