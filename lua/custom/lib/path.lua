--- @module custom.lib.path
--- Path helpers for project root detection and relative rendering.

local M = {}

local ROOT_MARKERS = { '.git', 'Makefile', 'package.json' }

--- @param path string
--- @return string|nil
function M.get_project_root(path)
  if not path or path == '' then
    return nil
  end

  local root = vim.b.path_root
  if root then
    return root
  end

  root = vim.fs.root(path, ROOT_MARKERS)
  if root then
    vim.b.path_root = root
  end
  return root
end

--- @param path string
--- @param root string
--- @return string
function M.relative_to_root(path, root)
  if not path or path == '' or not root or root == '' then
    return path or ''
  end
  return path:gsub('^' .. vim.pesc(root) .. '/?', '')
end

return M
