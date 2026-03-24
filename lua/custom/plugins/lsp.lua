--- @Note Main LSP Configuration (nvim-lspconfig)
--- 遵循模块化布局，集成了 Mason, Blink.cmp, Lazydev 及 Python 深度增强。
--- @url: https://github.com/neovim/nvim-lspconfig

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'b0o/SchemaStore.nvim',
    'towolf/vim-helm',
  },
  config = function()
    require('custom.lsp').setup()
  end,
}