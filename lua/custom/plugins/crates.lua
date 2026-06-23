local config = require 'custom.config'

--- @Note: Crates.nvim 配置 (Cargo.toml 增强)
--- 提供依赖版本补全和 LSP 功能
--- @url: https://github.com/saecki/crates.nvim

return {
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    enabled = true,
    opts = {
      completion = {
        crates = { enabled = true },
        cmp = { enabled = false },
        blink = { enabled = true },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
      popup = { border = 'rounded' },
    },
  },
}
