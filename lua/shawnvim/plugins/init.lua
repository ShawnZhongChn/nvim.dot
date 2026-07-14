if vim.fn.has("nvim-0.11.2") == 0 then
  vim.api.nvim_echo({
    { "ShawnVim requires Neovim >= 0.11.2\n", "ErrorMsg" },
    { "For more info, see: https://github.com/ShawnZhongChn/nvim.dot/issues/6421\n", "Comment" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require("shawnvim.config").init()

return {
  { "folke/lazy.nvim", version = "*" },
  {
    dir = vim.fn.stdpath("config"),
    name = "ShawnVim",
    priority = 10000,
    lazy = false,
    opts = {},
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
    config = function(_, opts)
      local notify = vim.notify
      require("snacks").setup(opts)
      -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
      -- this is needed to have early notifications show up in noice history
      if ShawnVim.has("noice.nvim") then
        vim.notify = notify
      end
    end,
  },
}
