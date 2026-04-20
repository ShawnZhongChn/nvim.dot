--- @Note: VTSLS Server Settings
--- @module custom.lsp.server_settings.vtsls

return {
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        includeCompletionsForImportStatements = true,
      },
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        includeCompletionsForImportStatements = true,
      },
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
}
