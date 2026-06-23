--- @module custom.lib.git
--- Git metadata helpers used by UI components.

local M = {}

local _branch_cache = {}
local _remote_cache = {}

--- @param root string
--- @param ... string
--- @return string|nil, string|nil
local function _git_cmd(root, ...)
  local job = vim.system({ 'git', '-C', root, ... }, { text = true }):wait()
  if job.code ~= 0 then
    return nil, job.stderr
  end
  return vim.trim(job.stdout)
end

--- @param root string
--- @return string|nil
function M.get_remote_name(root)
  if not root or root == '' then
    return nil
  end
  if _remote_cache[root] ~= nil then
    return _remote_cache[root]
  end

  local out = _git_cmd(root, 'config', '--get', 'remote.origin.url')
  if not out or out == '' then
    _remote_cache[root] = nil
    return nil
  end

  out = out:gsub(':', '/'):gsub('%.git$', ''):match '([^/]+/[^/]+)$'
  _remote_cache[root] = out
  return out
end

--- @param root string
--- @return string|nil
function M.get_branch(root)
  if not root or root == '' then
    return nil
  end
  if _branch_cache[root] ~= nil then
    return _branch_cache[root]
  end

  local out = _git_cmd(root, 'rev-parse', '--abbrev-ref', 'HEAD')
  if out == 'HEAD' then
    local commit = _git_cmd(root, 'rev-parse', '--short', 'HEAD')
    out = string.format('HEAD %s', commit or '')
  end

  _branch_cache[root] = out
  return out
end

return M
