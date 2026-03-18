--- @Note: BasedPyright Server Settings
--- @module custom.lsp.server_settings.basedpyright

return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = 'standard',
        autoSearchPaths = true,
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        diagnosticSeverityOverrides = {
          reportUnusedCallResult = 'none',
        },
      },
    },
    -- Compatibility fallback
    python = {
      analysis = {
        diagnosticSeverityOverrides = {
          reportUnusedCallResult = 'none',
        },
      },
    },
  },
}
