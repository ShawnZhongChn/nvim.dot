--- @Note: LSP 系统核心初始化模块
--- @module custom.lsp

local M = {}

local function _with_rounded_border(handler)
  return function(err, result, ctx, config)
    local merged = vim.tbl_deep_extend('force', { border = 'rounded' }, config or {})
    return handler(err, result, ctx, merged)
  end
end

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
  local mason_packages = {
    yamlls = 'yaml-language-server',
    lua_ls = 'lua-language-server',
    basedpyright = 'basedpyright',
    ruff = 'ruff',
    marksman = 'marksman',
    vtsls = 'vtsls',
    tailwindcss = 'tailwindcss-language-server',
    biome = 'biome',
  }
  local ensure_installed = {}

  for server_name, _ in pairs(servers or {}) do
    local package_name = mason_packages[server_name]

    if package_name then
      table.insert(ensure_installed, package_name)
    end
  end

  -- 手动补充非 LSP 工具 (Formatter & Linter)
  vim.list_extend(ensure_installed, {
    'stylua',
    'markdownlint-cli2', -- 解决 ENOENT 报错的核心
    'prettierd', -- 配合 conform.nvim
    'prettier', -- 配合 conform.nvim
  })

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    auto_update = true,
    run_on_start = true,
  }

  -- 5. 通过 Mason-LSPConfig 桥接驱动 lspconfig
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  require('mason-lspconfig').setup {
    automatic_enable = false,
  }

  for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

    -- 避免 Basedpyright 抢夺格式化权
    if server_name == 'basedpyright' then
      server.capabilities.documentFormattingProvider = false
      server.capabilities.documentRangeFormattingProvider = false
    end

    vim.lsp.config(server_name, server)
    vim.lsp.enable(server_name)
  end
end

return M
