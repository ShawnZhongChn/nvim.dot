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
  }
end

--- @Note 定义需要安装的 LSP 服务器及其特定设置
--- @return table
function M.get_servers()
  local roots = _get_roots()
  return {
    -- Lua: 配合 lazydev.nvim 获得极佳的插件开发体验
    lua_ls = {
      root_dir = roots.lua,
      settings = {
        Lua = { completion = { callSnippet = 'Replace' } },
      },
    },

    -- Python: 类型检查引擎
    basedpyright = {
      root_dir = roots.python,
      settings = {
        basedpyright = {
          disableOrganizeImports = true,
          analysis = {
            typeCheckingMode = 'standard',
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
          },
        },
      },
    },

    -- Python: 极速 Linter & Formatter (LSP 模式)
    ruff = {
      root_dir = roots.python,
      init_options = {
        settings = {
          lineLength = 120,
          lint = { enable = true, preview = true },
        },
      },
    },

    -- Markdown: 文档导航与补全
    marksman = { root_dir = roots.markdown },
  }
end

return M
