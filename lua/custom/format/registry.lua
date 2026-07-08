--- @module custom.format.registry
--- Format policy resolver used by conform.nvim.

local M = {}

local function _has_file(root, candidates)
  if not root or root == '' then
    return false
  end

  for _, candidate in ipairs(candidates or {}) do
    if vim.uv.fs_stat(root .. '/' .. candidate) then
      return true
    end
  end

  return false
end

local function _project_root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return nil
  end

  return vim.fs.root(path, { '.git', 'package.json', 'pyproject.toml', 'biome.json', 'biome.jsonc' })
end

--- @param bufnr integer
--- @return table|nil
function M.resolve(bufnr)
  local ft = vim.bo[bufnr].filetype
  local root = _project_root(bufnr)

  if ft == 'rust' then
    return { formatters = { 'rustfmt' }, lsp_format = 'fallback' }
  end

  if ft == 'lua' then
    return { formatters = { 'stylua' }, lsp_format = 'fallback' }
  end

  if ft == 'java' then
    return { formatters = { 'google-java-format' }, lsp_format = 'fallback' }
  end

  local is_frontend = ft == 'javascript'
    or ft == 'javascriptreact'
    or ft == 'typescript'
    or ft == 'typescriptreact'
    or ft == 'css'
    or ft == 'json'
    or ft == 'jsonc'
  if is_frontend then
    if _has_file(root, { 'biome.json', 'biome.jsonc' }) or _has_file(root, { 'package.json' }) then
      return { formatters = { 'biome' }, lsp_format = 'fallback' }
    end
    return { formatters = { 'prettierd', 'prettier' }, stop_after_first = true, lsp_format = 'fallback' }
  end

  if ft == 'markdown' or ft == 'yaml' then
    return { formatters = { 'prettierd', 'prettier' }, stop_after_first = true, lsp_format = 'fallback' }
  end

  return { lsp_format = 'fallback' }
end

function M.formatters_by_ft()
  return {
    rust = { 'rustfmt' },
    lua = { 'stylua' },
    java = { 'google-java-format' },
    javascript = { 'biome', stop_after_first = true },
    javascriptreact = { 'biome', stop_after_first = true },
    typescript = { 'biome', stop_after_first = true },
    typescriptreact = { 'biome', stop_after_first = true },
    css = { 'biome', stop_after_first = true },
    json = { 'biome', stop_after_first = true },
    jsonc = { 'biome', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
  }
end

return M
