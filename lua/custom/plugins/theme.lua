--- @Note: GitHub Monochrome 颜色方案 - 极简黑白配置

return {
  'oskarnurm/koda.nvim',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- require("koda").setup({ transparent = true })
    vim.cmd 'colorscheme koda'
    vim.api.nvim_set_hl(0, 'Visual', { bg = '#458ee6' })
    -- UFO 折叠省略号样式 (黑白)
    vim.api.nvim_set_hl(0, 'UfoFoldedEllipsis', { fg = '#999999', bold = true })
  end,
}
