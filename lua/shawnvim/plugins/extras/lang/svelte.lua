return {
  recommended = function()
    return ShawnVim.extras.wants({
      ft = "svelte",
      root = {
        "svelte.config.js",
        "svelte.config.mjs",
        "svelte.config.cjs",
      },
    })
  end,

  -- depends on the typescript extra
  { import = "shawnvim.plugins.extras.lang.typescript" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "svelte" } },
  },

  -- LSP Servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
      },
    },
  },

  -- Configure tsserver plugin
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      ShawnVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "typescript-svelte-plugin",
          location = ShawnVim.get_pkg_path("svelte-language-server", "/node_modules/typescript-svelte-plugin"),
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },

  {
    "conform.nvim",
    opts = function(_, opts)
      if ShawnVim.has_extra("formatting.prettier") then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.svelte = { "prettier" }
      end
    end,
  },
}
