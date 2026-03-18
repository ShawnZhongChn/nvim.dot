--- @Note: Ruff Server Settings
--- @module custom.lsp.server_settings.ruff

return {
  init_options = {
    settings = {
      lineLength = 120,
      lint = {
        enable = true,
        preview = true,
      },
    },
  },
}
