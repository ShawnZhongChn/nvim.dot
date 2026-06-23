--- @Note: Kanagawa Dragon 颜色方案

local config = require 'custom.config'

return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    local theme_name = config.get_value({ 'ui', 'theme' }, 'kanagawa-dragon')
    local kanagawa_variant = theme_name:gsub('^kanagawa%-', '')
    require('kanagawa').setup {
      theme = kanagawa_variant,
    }
    vim.cmd('colorscheme ' .. theme_name)
    vim.api.nvim_set_hl(0, 'Visual', { bg = '#458ee6' })
    vim.api.nvim_set_hl(0, 'UfoFoldedEllipsis', { fg = '#999999', bold = true })
  end,
}
