--- @Note: LSP 系统核心初始化模块
--- @module custom.lsp

local M = {}

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
    -- Virtual text is handled by tiny-inline-diagnostic.nvim
    virtual_text = false,
  }
end

--- @Note 核心初始化逻辑
function M.setup()
  -- 1. UI 装饰
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'rounded' })

  -- 2. 诊断配置应用
  vim.diagnostic.config(_get_diagnostic_opts())

  -- 3. 注册挂载事件
  local attach = require('custom.lsp.attach')
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach-core', { clear = true }),
    callback = attach.on_attach,
  })

  -- 4. Mason 工具全自动安装
  local servers_module = require('custom.lsp.servers')
  local servers = servers_module.get_servers()
  local ensure_installed = vim.tbl_keys(servers or {})
  
  -- 手动补充非 LSP 工具 (Formatter & Linter)
  vim.list_extend(ensure_installed, {
    'stylua',
    'markdownlint-cli2', -- 解决 ENOENT 报错的核心
    'prettier', -- 配合 conform.nvim
    'yaml-language-server',
  })

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    auto_update = true,
    run_on_start = true,
  }

  -- 5. 通过 Mason-LSPConfig 桥接驱动 lspconfig
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
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

return M
