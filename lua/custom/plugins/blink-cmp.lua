--- @note Blink.cmp 自动补全配置
--- 基于 Rust 的高性能补全引擎，内置 LSP、Snippet 和签名提示功能。
--- @url: https://github.com/saghen/blink.cmp

local config = require 'custom.config'

local function _get_luasnip_build_cmd()
  if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
    return nil
  end
  return 'make install_jsregexp'
end

local function _get_opts()
  return {
    keymap = {
      preset = 'default',
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = 'rounded' },
      },
      menu = {
        border = 'rounded',
      },
      ghost_text = {
        enabled = false,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        crates = {
          name = 'Crates',
          module = 'crates.nvim',
          score_offset = 90,
        },
      },
    },
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
    },
    snippets = {
      preset = 'luasnip',
    },
    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },
  }
end

return {
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = _get_luasnip_build_cmd(),
      },
      'folke/lazydev.nvim',
    },
    opts = _get_opts(),
    opts_extend = { 'sources.default' },
    enabled = config.is_enabled('obsidian') or true,
  },
}
