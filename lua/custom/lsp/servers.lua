--- @Note: 定义各语言项目的根目录检测与 LSP 服务器配置
--- @module custom.lsp.servers

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

local function _root_dir(markers, fallback_to_file_dir)
  return function(bufnr, on_dir)
    on_dir(_find_root(bufnr, markers, fallback_to_file_dir))
  end
end

--- @Note 定义各语言项目的根目录检测逻辑
--- @return table
local _get_roots = function()
  return {
    rust = _root_dir({ 'Cargo.toml', 'rust-project.json', '.git' }, true),
    python = _root_dir({ 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' }, true),
    lua = _root_dir({ 'init.lua', '.stylua.toml' }, false),
    markdown = _root_dir({ '.marksman.toml', '.git' }, false),
    yaml = _root_dir({ '.git' }, false),
    frontend = _root_dir({ 'package.json', 'tsconfig.json', 'jsconfig.json', 'vite.config.ts', 'vite.config.js', '.git' }, true),
    biome = _root_dir({ 'biome.json', 'biome.jsonc', 'package.json', '.git' }, false),
    tailwind = _root_dir({ 'tailwind.config.ts', 'tailwind.config.js', 'postcss.config.ts', 'postcss.config.js', 'package.json', '.git' }, false),
  }
end

--- @Note 定义需要安装的 LSP 服务器及其特定设置
--- @return table
function M.get_servers()
  local roots = _get_roots()
  return {
    yamlls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.yamlls', { root_dir = roots.yaml }),
    lua_ls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.lua_ls', { root_dir = roots.lua }),
    basedpyright = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.basedpyright', { root_dir = roots.python }),
    ruff = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.ruff', { root_dir = roots.python }),
    marksman = { root_dir = roots.markdown },
    vtsls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.vtsls', { root_dir = roots.frontend }),
    tailwindcss = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.tailwindcss', { root_dir = roots.tailwind }),
    biome = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.biome', { root_dir = roots.biome }),
  }
end

return M
