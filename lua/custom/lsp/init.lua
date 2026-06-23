--- @Note: LSP 系统核心初始化模块
--- @module custom.lsp

local M = {}
local config = require 'custom.config'

local function _with_rounded_border(handler)
  return function(err, result, ctx, cfg)
    local merged = vim.tbl_deep_extend('force', { border = 'rounded' }, cfg or {})
    return handler(err, result, ctx, merged)
  end
end

--- @Note 核心初始化逻辑
function M.setup()
  vim.lsp.handlers['textDocument/hover'] = _with_rounded_border(vim.lsp.handlers.hover)
  vim.lsp.handlers['textDocument/signatureHelp'] = _with_rounded_border(vim.lsp.handlers.signature_help)

  if vim.fn.exists(':LspInfo') == 0 then
    vim.api.nvim_create_user_command('LspInfo', function()
      vim.cmd 'checkhealth vim.lsp'
    end, { desc = 'Alias to :checkhealth vim.lsp' })
  end

  if vim.fn.exists(':LspLog') == 0 then
    vim.api.nvim_create_user_command('LspLog', function()
      vim.cmd(('tabnew %s'):format(vim.lsp.log.get_filename()))
    end, { desc = 'Open the Nvim LSP client log' })
  end

  if vim.fn.exists(':LspRestart') == 0 then
    vim.api.nvim_create_user_command('LspRestart', function()
      if vim.tbl_isempty(vim.lsp.get_clients { bufnr = 0 }) then
        vim.notify('No LSP clients attached to current buffer', vim.log.levels.WARN)
        return
      end

      vim.cmd 'lsp restart'
    end, { desc = 'Restart LSP clients for current buffer' })
  end

  require('custom.lsp.diagnostics').setup()

  local attach = require 'custom.lsp.attach'
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach-core', { clear = true }),
    callback = attach.on_attach,
  })

  local registry = require 'custom.lsp.registry'
  local servers = registry.servers()
  local ensure_installed = registry.ensure_installed()

  if config.is_enabled('auto_install_tools') then
    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
      auto_update = config.get_value({ 'features', 'auto_update_tools' }, true),
      run_on_start = true,
    }
  end

  local capabilities = require('custom.lsp.capabilities').make()

  require('mason-lspconfig').setup {
    automatic_enable = false,
  }

  for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    if server_name == 'basedpyright' then
      server.capabilities.documentFormattingProvider = false
      server.capabilities.documentRangeFormattingProvider = false
    end

    vim.lsp.config(server_name, server)
    vim.lsp.enable(server_name)
  end
end

return M
