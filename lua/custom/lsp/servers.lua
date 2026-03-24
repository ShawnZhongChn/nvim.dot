--- @Note: 定义各语言项目的根目录检测与 LSP 服务器配置
--- @module custom.lsp.servers

local M = {}

--- @Note 定义各语言项目的根目录检测逻辑
--- @return table
local _get_roots = function()
  local util = require 'lspconfig.util'
  return {
    python = util.root_pattern('pyproject.toml', 'setup.py', 'requirements.txt', '.git'),
    lua = util.root_pattern('init.lua', '.stylua.toml'),
    markdown = util.root_pattern('.marksman.toml', '.git'),
    yaml = util.root_pattern('.git'),
  }
end

--- @Note 定义需要安装的 LSP 服务器及其特定设置
--- @return table
function M.get_servers()
  local roots = _get_roots()
  return {
    -- YAML: 通过 SchemaStore 提供极致的 Kubernetes/Helm 补全
    yamlls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.yamlls', {
      root_dir = roots.yaml,
    }),

    -- Lua: 配合 lazydev.nvim 获得极佳的插件开发体验
    lua_ls = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.lua_ls', {
      root_dir = roots.lua,
    }),

    -- Python: 类型检查引擎
    basedpyright = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.basedpyright', {
      root_dir = roots.python,
    }),

    -- Python: 极速 Linter & Formatter (LSP 模式)
    ruff = vim.tbl_deep_extend('force', require 'custom.lsp.server_settings.ruff', {
      root_dir = roots.python,
    }),

    -- Markdown: 文档导航与补全
    marksman = { root_dir = roots.markdown },
  }
end

return M