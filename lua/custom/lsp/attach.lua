--- @Note: LSP 挂载后的行为定义 (Keymaps, Autocmds, Enhancements)
--- @module custom.lsp.attach

local M = {}

--- @Note 核心增强：合并定义(gd)与引用(grr)到一个列表展示，并使用色块区分类型
local _lsp_merged_search = function()
  local conf = require('telescope.config').values
  local finders = require 'telescope.finders'
  local pickers = require 'telescope.pickers'
  local entry_display = require 'telescope.pickers.entry_display'

  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then return vim.notify('LSP: No client attached') end
  local offset_encoding = vim.lsp.util._get_offset_encoding(bufnr)

  local locations_seen = {}
  local priorities = { Definition = 3, Declaration = 2, Reference = 1 }

  local function add_result(resp_locations, type_label)
    if not resp_locations then return end
    local locs = vim.tbl_islist(resp_locations) and resp_locations or { resp_locations }
    for _, loc in ipairs(locs) do
      local uri = loc.uri or loc.targetUri
      local range = loc.range or loc.targetSelectionRange
      if uri and range then
        local key = string.format('%s:%d:%d', uri, range.start.line, range.start.character)
        local current_prio = locations_seen[key] and priorities[locations_seen[key].type] or 0
        if priorities[type_label] > current_prio then
          locations_seen[key] = { loc = loc, type = type_label }
        end
      end
    end
  end

  local methods = {
    { 'textDocument/declaration', 'Declaration' },
    { 'textDocument/definition', 'Definition' },
    { 'textDocument/references', 'Reference' },
  }

  local valid_methods = {}
  for _, m in ipairs(methods) do
    if vim.tbl_filter(function(c) return c.supports_method(m[1]) end, clients)[1] then
      table.insert(valid_methods, m)
    end
  end

  local finished = 0
  local function check_done()
    finished = finished + 1
    if finished == #valid_methods then
      local final_list = {}
      for _, v in pairs(locations_seen) do table.insert(final_list, v) end
      if #final_list == 0 then return vim.notify('LSP: No locations found') end

      table.sort(final_list, function(a, b)
        local uri_a = a.loc.uri or a.loc.targetUri
        local uri_b = b.loc.uri or b.loc.targetUri
        if uri_a ~= uri_b then return uri_a < uri_b end
        local r_a = a.loc.range or a.loc.targetSelectionRange
        local r_b = b.loc.range or b.loc.targetSelectionRange
        return r_a.start.line < r_b.start.line
      end)

      local items = vim.lsp.util.locations_to_items(vim.tbl_map(function(x) return x.loc end, final_list), offset_encoding)
      for i, item in ipairs(items) do
        item.kind = final_list[i].type
      end

      pickers.new({}, {
        prompt_title = 'LSP Locations',
        finder = finders.new_table {
          results = items,
          entry_maker = function(entry)
            local displayer = entry_display.create {
              separator = ' ',
              items = { { width = 2 }, { width = 12 }, { remaining = true } },
            }
            local make_display = function(e)
              local kind_hl = e.value.kind == 'Definition' and 'Function' or (e.value.kind == 'Declaration' and 'Type' or 'Comment')
              local icon = '▋'
              return displayer {
                { icon, kind_hl },
                { e.value.kind, kind_hl },
                string.format('%s:%d:%d %s', vim.fn.fnamemodify(e.value.filename, ':t'), e.value.lnum, e.value.col, vim.trim(e.value.text)),
              }
            end
            return {
              value = entry,
              display = make_display,
              ordinal = entry.filename .. entry.text,
              filename = entry.filename,
              lnum = entry.lnum,
              col = entry.col,
            }
          end,
        },
        previewer = conf.qflist_previewer({}),
        sorter = conf.generic_sorter({}),
        layout_strategy = 'vertical',
        layout_config = { prompt_position = 'top', mirror = true },
      }):find()
    end
  end

  for _, m in ipairs(valid_methods) do
    local params = vim.lsp.util.make_position_params(0, offset_encoding)
    params.context = { includeDeclaration = true }
    vim.lsp.buf_request_all(bufnr, m[1], params, function(results)
      for _, res in pairs(results) do
        if not res.error and res.result then add_result(res.result, m[2]) end
      end
      check_done()
    end)
  end
end

--- @Note 当 LSP 挂载到 Buffer 时执行的操作 (Keymaps, Autocmds)
--- @param event table
function M.on_attach(event)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

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

  if client.name == 'lua_ls' then
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
      diagnostics = { globals = { 'vim' } },
    })
    client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) and client.name ~= 'vtsls' then
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

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

return M
