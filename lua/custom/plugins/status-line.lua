--- @Note: 轻量自研状态栏插件适配器。

return {
  'echasnovski/mini.icons',
  lazy = false,
  config = function()
    require('custom.ui.statusline').setup()
  end,
}
