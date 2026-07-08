--- @module custom.lsp.registry
--- LSP server registry and installer bridge.

local M = {}

local roots = require 'custom.lsp.roots'

local function _servers()
  local root = {
    rust = roots.make({ 'Cargo.toml', 'rust-project.json', '.git' }, true),
    python = roots.make({ 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' }, true),
    lua = roots.make({ 'init.lua', '.stylua.toml' }, false),
    markdown = roots.make({ '.marksman.toml', '.git' }, false),
    yaml = roots.make({ '.git' }, false),
    frontend = roots.make({ 'package.json', 'tsconfig.json', 'jsconfig.json', 'vite.config.ts', 'vite.config.js', '.git' }, true),
    biome = roots.make({ 'biome.json', 'biome.jsonc', 'package.json', '.git' }, false),
    tailwind = roots.make({ 'tailwind.config.ts', 'tailwind.config.js', 'postcss.config.ts', 'postcss.config.js', 'package.json', '.git' }, false),
    java = roots.make({ 'pom.xml', 'mvnw', '.git' }, true),
  }

  return {
    yamlls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.yamlls', { root_dir = root.yaml }),
    lua_ls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.lua_ls', { root_dir = root.lua }),
    basedpyright = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.basedpyright', { root_dir = root.python }),
    ruff = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.ruff', { root_dir = root.python }),
    marksman = { root_dir = root.markdown },
    vtsls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.vtsls', { root_dir = root.frontend }),
    tailwindcss = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.tailwindcss', { root_dir = root.tailwind }),
    biome = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.biome', { root_dir = root.biome }),
    jdtls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.jdtls', { root_dir = root.java }),
  }
end

local function _mason_packages()
  return {
    yamlls = 'yaml-language-server',
    lua_ls = 'lua-language-server',
    basedpyright = 'basedpyright',
    ruff = 'ruff',
    marksman = 'marksman',
    vtsls = 'vtsls',
    tailwindcss = 'tailwindcss-language-server',
    biome = 'biome',
    jdtls = 'jdtls',
  }
end

--- @return table<string, table>
function M.servers()
  return _servers()
end

--- @return table<string, string>
function M.mason_packages()
  return _mason_packages()
end

--- @return string[]
function M.ensure_installed()
  local servers = _servers()
  local packages = _mason_packages()
  local ensure_installed = {}

  for server_name, _ in pairs(servers) do
    local package_name = packages[server_name]
    if package_name then
      table.insert(ensure_installed, package_name)
    end
  end

  vim.list_extend(ensure_installed, {
    'stylua',
    'markdownlint-cli2',
    'prettierd',
    'prettier',
    'google-java-format',
    'vscode-spring-boot-tools',
  })

  return ensure_installed
end

return M
