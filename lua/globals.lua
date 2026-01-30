-- https://www.compart.com/en/unicode to search Unicode

_G.tools = {
  ui = {
    icons = {
      branch = '',
      bullet = '•',
      open_bullet = '○',
      ok = '✔',
      d_chev = '∨',
      ellipses = '…',
      node = '╼',
      document = '≡',
      lock = '',
      r_chev = '>',
      warning = ' ',
      error = ' ',
      info = '󰌶 ',
    },
    kind_icons = {
      Array = ' 󰅪 ',
      BlockMappingPair = ' 󰅩 ',
      Boolean = '  ',
      BreakStatement = ' 󰙧 ',
      Call = ' 󰃷 ',
      CaseStatement = ' 󰨚 ',
      Class = '  ',
      Color = '  ',
      Constant = '  ',
      Constructor = ' 󰆧 ',
      ContinueStatement = '  ',
      Copilot = '  ',
      Declaration = ' 󰙠 ',
      Delete = ' 󰩺 ',
      DoStatement = ' 󰑖 ',
      Element = ' 󰅩 ',
      Enum = '  ',
      EnumMember = '  ',
      Event = '  ',
      Field = '  ',
      File = '  ',
      Folder = '  ',
      ForStatement = '󰑖 ',
      Function = ' 󰆧 ',
      GotoStatement = ' 󰁔 ',
      Identifier = ' 󰀫 ',
      IfStatement = ' 󰇉 ',
      Interface = '  ',
      Keyword = '  ',
      List = ' 󰅪 ',
      Log = ' 󰦪 ',
      Lsp = '  ',
      Macro = ' 󰁌 ',
      MarkdownH1 = ' 󰉫 ',
      MarkdownH2 = ' 󰉬 ',
      MarkdownH3 = ' 󰉭 ',
      MarkdownH4 = ' 󰉮 ',
      MarkdownH5 = ' 󰉯 ',
      MarkdownH6 = ' 󰉰 ',
      Method = ' 󰆧 ',
      Module = ' 󰅩 ',
      Namespace = ' 󰅩 ',
      Null = ' 󰢤 ',
      Number = ' 󰎠 ',
      Object = ' 󰅩 ',
      Operator = '  ',
      Package = ' 󰆧 ',
      Pair = ' 󰅪 ',
      Property = '  ',
      Reference = '  ',
      Regex = '  ',
      Repeat = ' 󰑖 ',
      Return = ' 󰌑 ',
      RuleSet = ' 󰅩 ',
      Scope = ' 󰅩 ',
      Section = ' 󰅩 ',
      Snippet = '  ',
      Specifier = ' 󰦪 ',
      Statement = ' 󰅩 ',
      String = '  ',
      Struct = '  ',
      SwitchStatement = ' 󰨙 ',
      Table = ' 󰅩 ',
      Terminal = '  ',
      Text = ' 󰀬 ',
      Type = '  ',
      TypeParameter = '  ',
      Unit = '  ',
      Value = '  ',
      Variable = '  ',
      WhileStatement = ' 󰑖 ',
    },
  },
  nonprog_modes = {
    ['markdown'] = true,
    ['org'] = true,
    ['orgagenda'] = true,
    ['text'] = true,
  },
}
--- @Note: 全局工具类，提供 Git、UI 高亮、LSP 状态等核心增强功能。
--- @Note: 采用缓存机制减少 shell 调用开销。

-- Ensure _G.tools exists
_G.tools = _G.tools or {}

local M = _G.tools

-- =============================================================================
-- Options Components & Caches
-- =============================================================================

local api, fn = vim.api, vim.fn

-- 缓存对象：使用弱引用键 (k) 防止内存泄漏
local _branch_cache = setmetatable({}, { __mode = 'k' })
local _remote_cache = setmetatable({}, { __mode = 'k' })

-- 处理图标：自动为 kind_icons 添加空格后缀
-- Preserve existing UI settings or init default
M.ui = M.ui or {}
M.ui.kind_icons = M.ui.kind_icons or {}

local function _init_spaced_icons()
  local icons_spaced = {}
  for key, value in pairs(M.ui.kind_icons) do
    icons_spaced[key] = value .. ' '
  end
  M.ui.kind_icons_spaced = icons_spaced
end

-- =============================================================================
-- Enhancement Methods (Private)
-- =============================================================================

--- 封装 git 命令行调用
--- @param root string 仓库根路径
--- @param ... string git 参数
--- @return string|nil, string|nil (结果, 错误信息)
local function _git_cmd(root, ...)
  local job = vim.system({ 'git', '-C', root, ... }, { text = true }):wait()
  if job.code ~= 0 then
    return nil, job.stderr
  end
  return vim.trim(job.stdout)
end

-- =============================================================================
-- Core Logic (Public APIs)
-- =============================================================================

--- 获取当前路径所在的项目根目录
--- @param path string 文件路径
--- @return string|nil 根目录路径
M.get_path_root = function(path)
  if not path or path == '' then
    return nil
  end

  local root = vim.b.path_root
  if root then
    return root
  end

  local root_items = { '.git', 'Makefile', 'package.json' }
  root = vim.fs.root(path, root_items)

  if root then
    vim.b.path_root = root
  end
  return root
end

--- 获取 Git 远程仓库名称并格式化
--- @param root string 根路径
--- @return string|nil
M.get_git_remote_name = function(root)
  if not root or _remote_cache[root] then
    return _remote_cache[root]
  end

  local out = _git_cmd(root, 'config', '--get', 'remote.origin.url')
  if not out then
    return nil
  end

  -- 标准化为短仓库名 (user/repo)
  out = out:gsub(':', '/'):gsub('%.git$', ''):match '([^/]+/[^/]+)$'
  _remote_cache[root] = out
  return out
end

--- 获取当前分支名或 Commit 简码
--- @param root string 根路径
--- @return string|nil
M.get_git_branch = function(root)
  if not root or _branch_cache[root] then
    return _branch_cache[root]
  end

  local out = _git_cmd(root, 'rev-parse', '--abbrev-ref', 'HEAD')
  if out == 'HEAD' then
    local commit = _git_cmd(root, 'rev-parse', '--short', 'HEAD')
    out = string.format('HEAD %s', M.hl_str('Comment', '(' .. (commit or '') .. ')'))
  end

  _branch_cache[root] = out
  return out
end

--- 检查当前缓冲区是否有 LSP 诊断支持
--- @return boolean
M.diagnostics_available = function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local method = vim.lsp.protocol.Methods.textDocument_publishDiagnostics

  for _, client in pairs(clients) do
    if client:supports_method(method) then
      return true
    end
  end
  return false
end

--- 包装字符串为状态栏高亮格式
--- @param hl string 高亮组名称
--- @param str string 文本内容
--- @return string
M.hl_str = function(hl, str)
  return string.format('%%#%s#%s%%*', hl, str)
end

--- 数字千分位格式化
--- @param num number|string
--- @param sep string 分隔符 (如 ',')
--- @return string
M.group_number = function(num, sep)
  local n = tostring(num)
  if #n < 4 then
    return n
  end
  return n:reverse():gsub('(%d%d%d)', '%1' .. sep):reverse():gsub('^' .. sep, '')
end

-- =============================================================================
-- Initialization
-- =============================================================================

_init_spaced_icons()

return M
