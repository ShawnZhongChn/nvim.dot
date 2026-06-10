--- @Note: Rustaceanvim 配置 (LSP + DAP)
--- rustaceanvim 会自动管理 rust-analyzer，无需手动配置
--- @url: https://github.com/mrcjkb/rustaceanvim

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^7',
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        -- DAP 配置
        dap = {
          autoload_configurations = true,
        },

        -- rust-analyzer 设置
        server = {
          on_attach = function(client, bufnr)
            -- K 映射为 Hover Actions
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp({ 'hover', 'actions' })
            end, { buffer = bufnr, desc = 'Rust Hover Actions' })

            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp('codeAction')
            end, { buffer = bufnr, desc = 'Rust Code Action' })

            vim.keymap.set('n', '<leader>dr', function()
              vim.cmd.RustLsp('debuggables')
            end, { buffer = bufnr, desc = 'Rust Debuggables' })

            vim.keymap.set('n', '<leader>rr', function()
              vim.cmd.RustLsp('runnables')
            end, { buffer = bufnr, desc = 'Rust Runnables' })

            vim.keymap.set('n', '<leader>rm', function()
              vim.cmd.RustLsp('expandMacro')
            end, { buffer = bufnr, desc = 'Rust Expand Macro' })

            vim.keymap.set('n', '<leader>rp', function()
              vim.cmd.RustLsp('parentModule')
            end, { buffer = bufnr, desc = 'Rust Parent Module' })
          end,

          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = {
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ['async-trait'] = { 'async_trait' },
                  ['napi-derive'] = { 'napi' },
                  ['async-recursion'] = { 'async_recursion' },
                },
              },
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = 'never' },
                lifetimeElisionHints = { enable = 'never' },
                parameterHints = { enable = true },
                reborrowHints = { enable = 'never' },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
              files = {
                excludeDirs = {
                  '.direnv', '.git', '.github', 'node_modules',
                  'target', 'venv', '.venv',
                },
              },
              diagnostics = {
                enable = true,
                experimental = { enable = true },
              },
              completion = {
                callable = { snippets = 'fill_arguments' },
                postfix = { enable = true },
                autoimport = { enable = true },
                fullFunctionSignatures = { enable = true },
              },
              imports = {
                granularity = { group = 'module' },
                prefix = 'self',
              },
            },
          },
        },
      }
    end,
  },
}
