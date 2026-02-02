--- @Note: LSP 挂载后的行为定义 (Keymaps, Autocmds, Enhancements)
--- @module custom.lsp.attach

local M = {}

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
function M.on_attach(event)
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

  -- [Lua_ls Hotfix]
  -- 强制在内存中补全 'vim' 全局变量配置，并主动通知服务器，绕过配置合并失败问题
  if client.name == 'lua_ls' then
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
      diagnostics = {
        globals = { 'vim' },
      },
    })
    client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
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

return M
