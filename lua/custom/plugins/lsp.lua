--- @Note Main LSP Configuration (nvim-lspconfig)
--- 遵循模块化布局，集成了 Mason, Blink.cmp, Lazydev 及 Python 深度增强。
--- @url: https://github.com/neovim/nvim-lspconfig

-------------------------------------------------------------------------------
-- [Options Components]
-------------------------------------------------------------------------------

--- @Note 获取诊断 (Diagnostic) 的显示配置
--- @return table
local _get_diagnostic_opts = function()
  return {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      format = function(diagnostic)
        return diagnostic.message
      end,
    },
  }
end

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
local _get_servers = function()
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

-------------------------------------------------------------------------------
-- [Enhancement Methods]
-------------------------------------------------------------------------------

--- @Note 核心增强：合并定义(gd)与引用(grr)到一个列表展示
local _lsp_merged_search = function()
  require('telescope.builtin').lsp_references {
    include_declaration = true,
    include_current_line = false,
    prompt_title = 'LSP: Definitions & References',
    show_line = false,
  }
end

--- @Note Python 专用：利用 Treesitter 智能折叠 Docstrings
--- @param args table
local _fold_python_docstrings = function(args)
  local query = vim.treesitter.query.parse(
    'python',
    [[
    (module (expression_statement (string) @docstring))
    (function_definition body: (block (expression_statement (string) @docstring)))
    (class_definition body: (block (expression_statement (string) @docstring)))
  ]]
  )
  local start_line = args.range >= 2 and args.line1 or nil
  local end_line = args.range >= 2 and args.line2 or nil
  local parser = vim.treesitter.get_parser(0, 'python')
  if not parser then
    return
  end

  local tree = parser:parse()[1]:root()
  for _, node in query:iter_captures(tree, 0, start_line, end_line) do
    local s_row, _, e_row, _ = node:range()
    pcall(function()
      if vim.wo.foldmethod == 'manual' then
        vim.cmd.fold { range = { s_row + 1, e_row } }
      else
        vim.cmd.foldclose { range = { s_row + 1 } }
      end
    end)
  end
end

--- @Note 判断 LSP Client 是否支持特定方法 (兼容性处理)
local _client_supports_method = function(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

--- @Note 当 LSP 挂载到 Buffer 时执行的操作 (Keymaps, Autocmds)
--- @param event table
local _on_attach = function(event)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- 核心导航
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
  map('gd', _lsp_merged_search, '[G]oto [D]efinition & References')
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then
    return
  end

  -- Python 专用增强
  if vim.tbl_contains({ 'basedpyright', 'ruff' }, client.name) then
    vim.api.nvim_buf_create_user_command(event.buf, 'FoldDocstrings', _fold_python_docstrings, { range = true })
    map('zp', '<cmd>FoldDocstrings<CR>', '[P]ython: Fold Docstrings')
  end

  -- 自动高亮 (CursorHold)
  if _client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    local highlight_group = vim.api.nvim_create_augroup('lsp-highlight-' .. event.buf, { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_group,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- Inlay Hints
  if _client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

-------------------------------------------------------------------------------
-- [Core Logic]
-------------------------------------------------------------------------------

--- @Note 整合与初始化
local _setup_core = function()
  -- 1. UI 装饰
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'rounded' })

  -- 2. 诊断配置应用
  vim.diagnostic.config(_get_diagnostic_opts())

  -- 3. 注册挂载事件
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach-core', { clear = true }),
    callback = _on_attach,
  })

  -- 4. Mason 工具全自动安装
  local servers = _get_servers()
  local ensure_installed = vim.tbl_keys(servers or {})
  -- 手动补充非 LSP 工具 (Formatter & Linter)
  vim.list_extend(ensure_installed, {
    'stylua',
    'markdownlint-cli2', -- 解决 ENOENT 报错的核心
    'prettier', -- 配合 conform.nvim
  })

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    auto_update = true,
    run_on_start = true,
  }

  -- 5. 通过 Mason-LSPConfig 桥接驱动 lspconfig
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  require('mason-lspconfig').setup {
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

        -- 避免 Basedpyright 抢夺格式化权
        if server_name == 'basedpyright' then
          server.capabilities.documentFormattingProvider = false
          server.capabilities.documentRangeFormattingProvider = false
        end

        require('lspconfig')[server_name].setup(server)
      end,
    },
  }
end

-------------------------------------------------------------------------------
-- [Plugin Spec]
-------------------------------------------------------------------------------

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = _setup_core,
}
