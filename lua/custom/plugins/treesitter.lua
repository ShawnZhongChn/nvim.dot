--- @Note 语法高亮、代码编辑增强与结构化导航 (Treesitter)
-------------------------------------------------------------------------------

local _languages = {
  'bash',
  'c',
  'css',
  'diff',
  'html',
  'javascript',
  'java',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'ron',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
}

local _filetypes = {
  'bash',
  'c',
  'css',
  'diff',
  'html',
  'javascript',
  'javascriptreact',
  'java',
  'jsdoc',
  'json',
  'jsonc',
  'lua',
  'luadoc',
  'markdown',
  'python',
  'query',
  'ron',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'typescriptreact',
  'vim',
  'vimdoc',
}

local _indent_disabled = {
  ruby = true,
}

-------------------------------------------------------------------------------

--- 生成 Treesitter 核心配置项
--- @return table
local function _get_opts()
  return {}
end

-------------------------------------------------------------------------------

local function _install_declared_parsers()
  require('nvim-treesitter').install(_languages, { max_jobs = 1 }):wait(300000)
end

local function _start_treesitter(args)
  local bufnr = args.buf
  local ok = pcall(vim.treesitter.start, bufnr)
  if not ok then
    return
  end

  if not _indent_disabled[vim.bo[bufnr].filetype] then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local function _setup_filetype_autocmds()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('custom-treesitter-start', { clear = true }),
    pattern = _filetypes,
    callback = _start_treesitter,
  })
end

-------------------------------------------------------------------------------

--- 核心初始化逻辑
local function _setup()
  require('nvim-treesitter').setup()
  _setup_filetype_autocmds()
end

-------------------------------------------------------------------------------

return {
  'nvim-treesitter/nvim-treesitter',
  build = _install_declared_parsers,
  opts = _get_opts(),
  config = _setup,
}
