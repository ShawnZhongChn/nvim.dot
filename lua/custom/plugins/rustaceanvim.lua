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
        dap = {
          autoload_configurations = true,
        },
        server = {
          on_attach = function(_, _)
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
