---
--- @Note: Render Markdown 美化配置
--- @Desc: 提升 Markdown 阅读体验，提供标题、代码块、表格、Callout 的实时渲染与美化
---

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 获取 Render Markdown 核心配置
--- @return table
local _get_opts = function()
  return {
    -- 1. 标题配置 (Headings)
    heading = {
      -- 启用标题渲染
      enabled = true,
      -- 标题图标 (使用 Nerd Fonts)
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      -- 标题符号位置 'overlay' | 'inline'
      position = 'inline',
      -- 标题背景高亮
      backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
      },
      -- 标题宽度 'full' | 'block'
      width = 'block',
    },

    -- 2. 代码块 (Code Blocks)
    code = {
      enabled = true,
      -- 代码块样式 'language' | 'normal' | 'none'
      style = 'language',
      -- 代码块位置 'left' | 'right'
      position = 'left',
      -- 宽度 'full' | 'block'
      width = 'block',
      -- 边框 'thin' | 'thick'
      border = 'thick',
      -- 是否在代码块周围显示行号
      highlight = 'RenderMarkdownCode',
    },

    -- 3. 引用块 (Callouts/Blockquotes)
    callout = {
      note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
      tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
      important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownWarn' },
      warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
      caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
    },

    -- 4. 列表与复选框 (Lists & Checkboxes)
    bullet = {
      enabled = true,
      icons = { '●', '○', '◆', '◇' },
    },
    checkbox = {
      enabled = true,
      unchecked = { icon = '󰄱 ' },
      checked = { icon = ' ' },
      custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownWarn' },
      },
    },

    -- 5. 表格 (Tables)
    pipe_table = {
      enabled = true,
      style = 'heavy', -- 'heavy' | 'double' | 'round' | 'none'
      cell = 'padded', -- 'padded' | 'raw' | 'overlay'
    },

    -- 6. 链接 (Links)
    link = {
      enabled = true,
      image = '󰥶 ',
      email = '󰇮 ',
      hyperlink = '󰌹 ',
      highlight = 'RenderMarkdownLink',
      wiki = { icon = '󱗆 ', highlight = 'RenderMarkdownWiki' },
    },

    -- 7. 符号隐藏 (Anti-Conceal)
    -- 当光标位于特定元素时显示原始 Markdown 符号
    anti_conceal = {
      enabled = true,
    },

    -- 8. Latex 公式支持
    latex = {
      enabled = true,
      converter = 'latex2text',
      highlight = 'RenderMarkdownMath',
      top_pad = 0,
      bottom_pad = 0,
    },
  }
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown', 'Avante' }, -- 在 Markdown 和 Avante 窗口中启用
  opts = _get_opts(),
  config = function(_, opts)
    require('render-markdown').setup(opts)
    -- 配合 Obsidian.nvim 使用时的额外设置（如果需要）
    -- 目前 render-markdown 会自动处理大部分兼容性
  end,
}
