---------------------------------------------------------------- @Note: oil.nvim 插件配置
--- 允许以编辑 buffer 的方式管理文件系统，并支持自定义 Winbar 显示。

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note: 获取并格式化当前 Oil 路径用于 Winbar
--- @return string
local _get_oil_winbar_path = function()
  local path = vim.fn.expand '%'
  path = path:gsub('oil://', '')
  return '  ' .. vim.fn.fnamemodify(path, ':.')
end

--- @Note: 获取浮窗圆角配置
--- @return table
local _get_float_opts = function()
  return {
    padding = 2,
    max_width = 0,
    max_height = 0,
    border = 'rounded', -- 设置为圆角
    win_options = {
      winblend = 0,
    },
  }
end

--- @Note: 定义需要过滤的特定文件夹
--- @param name string 文件/目录名
--- @return boolean
local _is_skip_folder = function(name)
  local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build', '.git' }
  return vim.tbl_contains(folder_skip, name)
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note: 配置快捷键增强
local _setup_keymaps = function()
  -- 在当前窗口打开父目录
  vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Oil: Open parent directory' })

  -- 在浮窗中切换打开父目录
  vim.keymap.set('n', '<space>-', function()
    require('oil').toggle_float()
  end, { desc = 'Oil: Toggle floating window' })
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note: 整合配置与初始化
local _init = function()
  -- 暴露私有路径函数给全局，供 winbar 的 v:lua 字符串访问
  _G._oil_winbar_provider = _get_oil_winbar_path

  require('oil').setup {
    columns = { 'icon' },
    -- 注入圆角浮窗配置
    float = _get_float_opts(),
    keymaps = {
      ['<C-h>'] = false,
      ['<C-l>'] = false,
      ['<C-k>'] = false,
      ['<C-j>'] = false,
      ['<M-h>'] = 'actions.select_split',
      ['L'] = 'actions.select',
      ['H'] = 'actions.parent',
      ['q'] = 'actions.close',
    },
    win_options = {
      winbar = '%{v:lua._oil_winbar_provider()}',
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return _is_skip_folder(name)
      end,
    },
  }

  _setup_keymaps()
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = _init,
  },
}
