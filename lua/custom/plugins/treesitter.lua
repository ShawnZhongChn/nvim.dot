--- @Note 语法高亮、代码编辑增强与结构化导航 (Treesitter)
-------------------------------------------------------------------------------

--- 生成 Treesitter 核心配置项
--- @return table
local function _get_opts()
  return {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
    },
    -- 自动安装未就绪的语言解析器
    auto_install = true,
    highlight = {
      enable = true,
      -- 部分语言（如 Ruby）依赖 Vim 传统的正则高亮以维持缩进正确
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = {
      enable = true,
      disable = { 'ruby' },
    },
  }
end

-------------------------------------------------------------------------------

--- 核心初始化逻辑
--- @param opts table
local function _setup(_, opts)
  require('nvim-treesitter').setup(opts)
end

-------------------------------------------------------------------------------

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  -- 插件规格定义
  opts = _get_opts(),
  config = _setup,
}
