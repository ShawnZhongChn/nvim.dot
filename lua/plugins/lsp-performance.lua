return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.flags = opts.flags or {}
      opts.flags.debounce_text_changes = 150

      local previous_on_attach = opts.on_attach
      opts.on_attach = function(client, bufnr)
        if previous_on_attach then
          previous_on_attach(client, bufnr)
        end
        -- Semantic tokens can be expensive in large buffers.
        client.server_capabilities.semanticTokensProvider = nil
      end

      opts.servers = opts.servers or {}
      local py = opts.servers.basedpyright
      if py and py.settings and py.settings.basedpyright and py.settings.basedpyright.analysis then
        local analysis = py.settings.basedpyright.analysis
        analysis.diagnosticMode = "openFilesOnly"
        analysis.useLibraryCodeForTypes = false
        analysis.typeCheckingMode = analysis.typeCheckingMode or "basic"
      end
    end,
  },
}
