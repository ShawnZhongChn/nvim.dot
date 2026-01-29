--- @Note Main LSP Configuration (nvim-lspconfig)
--------------------------------------------------------------------------

--- @return table
--- @Note 定义需要安装的 LSP 服务器及其特定设置
local _get_servers = function()
  return {
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
        },
      },
    },
  }
end

--- @return table
--- @Note 获取诊断 (Diagnostic) 的显示配置
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

--------------------------------------------------------------------------

--- @param args table
--- @Note Python 专用的 Treesitter 文档折叠逻辑
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

--- @param client table
--- @param method string
--- @param bufnr number
--- @return boolean
local _client_supports_method = function(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

--- @param event table
--- @Note 当 LSP 挂载到 Buffer 时执行的操作
local _on_attach = function(event)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- 核心快捷键
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

  local client_new = vim.lsp.get_client_by_id(event.data.client_id)
  if not client_new then
    return
  end

  -- 为 Python 注入专属增强
  if client_new.name == 'pyright' or client_new.name == 'basedpyright' or client_new.name == 'pyrefly' then
    vim.api.nvim_buf_create_user_command(event.buf, 'FoldDocstrings', _fold_python_docstrings, { range = true })
    map('zp', '<cmd>FoldDocstrings<CR>', 'Fold Docstrings')
  end

  -- 文档高亮与 Inlay Hints (逻辑保持不变)
  if _client_supports_method(client_new, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = highlight_augroup, callback = vim.lsp.buf.document_highlight })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = highlight_augroup, callback = vim.lsp.buf.clear_references })
  end

  if _client_supports_method(client_new, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

--------------------------------------------------------------------------

--- @Note 整合与初始化
local _setup_core = function()
  -- 1. 设置全局 LSP 句柄 (圆角边框)
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'rounded' })

  -- 2. 注册 LspAttach
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = _on_attach,
  })

  -- 3. 应用诊断配置
  vim.diagnostic.config(_get_diagnostic_opts())

  -- 4. Mason 与服务器配置 (逻辑保持不变)
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  local servers = _get_servers()
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, { 'stylua' })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  require('mason-lspconfig').setup {
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }
end

--------------------------------------------------------------------------

--- @return table
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = _setup_core,
}
