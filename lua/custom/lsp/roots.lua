--- @module custom.lsp.roots
--- Root directory helpers for LSP server configuration.

local M = {}

local function _find_root(bufnr, markers, fallback_to_file_dir)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(bufnr, markers)

  if root then
    return root
  end

  if fallback_to_file_dir and path ~= '' then
    return vim.fs.dirname(vim.fs.normalize(path))
  end
end

--- @param markers string[]
--- @param fallback_to_file_dir boolean
--- @return fun(bufnr: integer, on_dir: function)
function M.make(markers, fallback_to_file_dir)
  return function(bufnr, on_dir)
    on_dir(_find_root(bufnr, markers, fallback_to_file_dir))
  end
end

return M
