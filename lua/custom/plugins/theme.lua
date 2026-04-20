--- @Note: Kanagawa Dragon 颜色方案

return {
  'rebelot/kanagawa.nvim',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('kanagawa').setup {
      theme = 'dragon',
    }
    vim.cmd 'colorscheme kanagawa-dragon'
    vim.api.nvim_set_hl(0, 'Visual', { bg = '#458ee6' })
    vim.api.nvim_set_hl(0, 'UfoFoldedEllipsis', { fg = '#999999', bold = true })
  end,
}
