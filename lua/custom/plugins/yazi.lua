--- @Note: yazi.nvim 插件适配器
--- 提供基于 Rust 编写的高性能文件管理器集成。

return {
  'mikavilpas/yazi.nvim',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('custom.ui.explorer').setup_yazi()
  end,
}
