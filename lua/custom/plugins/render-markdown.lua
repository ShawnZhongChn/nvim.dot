local config = require 'custom.config'

--- @Note: Render Markdown 美化配置
--- @Desc: 提升 Markdown 阅读体验，提供标题、代码块、表格、Callout 的实时渲染与美化
---

local function _get_opts()
  return {
    heading = {
      enabled = true,
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      position = 'inline',
      backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
      },
      width = 'block',
    },
    code = {
      enabled = true,
      style = 'language',
      position = 'left',
      width = 'block',
      border = 'thick',
      highlight = 'RenderMarkdownCode',
    },
    callout = {
      note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
      tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
      important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownWarn' },
      warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
      caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
    },
    bullet = { enabled = true, icons = { '●', '○', '◆', '◇' } },
    checkbox = {
      enabled = true,
      unchecked = { icon = '󰄱 ' },
      checked = { icon = ' ' },
      custom = { todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownWarn' } },
    },
    pipe_table = { enabled = true, style = 'heavy', cell = 'padded' },
    link = {
      enabled = true,
      image = '󰥶 ',
      email = '󰇮 ',
      hyperlink = '󰌹 ',
      highlight = 'RenderMarkdownLink',
      wiki = { icon = '󱗆 ', highlight = 'RenderMarkdownWiki' },
    },
    anti_conceal = { enabled = true },
    latex = { enabled = true, converter = 'latex2text', highlight = 'RenderMarkdownMath', top_pad = 0, bottom_pad = 0 },
  }
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown', 'Avante' },
  enabled = config.is_enabled('markdown_preview'),
  opts = _get_opts(),
  config = function(_, opts)
    require('render-markdown').setup(opts)
  end,
}
