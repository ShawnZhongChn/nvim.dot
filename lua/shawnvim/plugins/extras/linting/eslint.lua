if shawnvim_docs then
  -- Set to false to disable auto format
  vim.g.shawnvim_eslint_auto_format = true
end

local auto_format = vim.g.shawnvim_eslint_auto_format == nil or vim.g.shawnvim_eslint_auto_format

return {
  {
    "neovim/nvim-lspconfig",
    -- other settings removed for brevity
    opts = {
      ---@type table<string, vim.lsp.Config>
      servers = {
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
            format = auto_format,
          },
        },
      },
      setup = {
        eslint = function()
          if not auto_format then
            return
          end

          local formatter = ShawnVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          -- register the formatter with ShawnVim
          ShawnVim.format.register(formatter)
        end,
      },
    },
  },
}
