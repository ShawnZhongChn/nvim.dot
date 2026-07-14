--- @Note Main LSP Configuration (nvim-lspconfig)
--- @url: https://github.com/neovim/nvim-lspconfig

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'mfussenegger/nvim-jdtls',
    'b0o/SchemaStore.nvim',
    'towolf/vim-helm',
    'yioneko/nvim-vtsls',
  },
  config = function()
    require('custom.lsp').setup()
  end,
}
