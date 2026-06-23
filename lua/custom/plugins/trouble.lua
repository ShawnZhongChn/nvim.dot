--- @Note: Trouble.nvim 配置
--- 提供诊断信息的分类视图，比 loclist 更强大
--- @url: https://github.com/folke/trouble.nvim

return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    {
      '<leader>xd',
      '<cmd>Trouble diagnostics toggle<CR>',
      desc = 'Document Diagnostics',
    },
    {
      '<leader>xp',
      '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
      desc = 'Project Diagnostics',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<CR>',
      desc = 'Quickfix List',
    },
    {
      '<leader>xw',
      '<cmd>Trouble lsp_workspace_diagnostics toggle<CR>',
      desc = 'Workspace Diagnostics',
    },
  },
  opts = {
    use_diagnostics = true,
    icons = false,
  },
}
