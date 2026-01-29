----------------- @Note: oil.nvim 插件配置
--- 允许以编辑 buffer 的方式管理文件系统，并支持自定义 Winbar 显示。

local M = {}

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note: 获取并格式化当前 Oil 路径用于 Winbar
local _get_oil_winbar_path = function()
  local path = vim.fn.expand '%'
  path = path:gsub('oil://', '')
  return '  ' .. vim.fn.fnamemodify(path, ':.')
end

--- @Note: 获取浮窗圆角配置
local _get_float_opts = function()
  return {
    padding = 2,
    max_width = 0,
    max_height = 0,
    border = 'rounded',
    win_options = { winblend = 0 },
  }
end

--- @Note: 定义需要过滤的特定文件夹
local _is_skip_folder = function(name)
  local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build', '.git' }
  return vim.tbl_contains(folder_skip, name)
end

--- @Note: 获取 Oil 的主要配置表
local _get_opts = function()
  return {
    columns = { 'icon' },
    float = _get_float_opts(),
    preview = {
      width = nil,
      min_width = { 40, 0.4 },
      border = 'rounded',
    },
    keymaps = {
      ['<C-h>'] = false,
      ['<C-l>'] = false,
      ['<C-k>'] = false,
      ['<C-j>'] = false,
      ['<C-p>'] = false,
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
      is_always_hidden = _is_skip_folder,
    },
  }
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note: 配置快捷键增强
local _setup_keymaps = function()
  vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Oil: Open parent directory' })
  vim.keymap.set('n', '<space>-', function()
    require('oil').toggle_float()
  end, { desc = 'Oil: Toggle floating window' })
end

--- @Note: 配置进入 Oil 时自动打开预览窗口
--- @param oil table Oil 模块实例
local _set_autocmds = function(oil)
  -- [FIX] 改用 BufWinEnter 确保每次打开窗口都触发
  vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = '*',
    callback = function(args)
      -- 检查当前 Buffer 是否是 Oil 类型
      if vim.bo[args.buf].filetype == 'oil' then
        -- 延迟执行，确保 UI 渲染完毕
        vim.defer_fn(function()
          -- 双重检查：确保当前窗口依然停留在 Oil buffer 中
          if vim.api.nvim_get_current_buf() == args.buf then
            -- 确保选中了条目才打开
            if oil.get_cursor_entry() then
              oil.open_preview()
            end
          end
        end, 50) -- 50ms 延迟
      end
    end,
    group = vim.api.nvim_create_augroup('OilAutoPreview', { clear = true }),
    desc = 'Oil: Auto open preview on entry',
  })
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note: 核心初始化逻辑
local _setup_core = function()
  local oil = require 'oil'

  _G._oil_winbar_provider = _get_oil_winbar_path
  oil.setup(_get_opts())
  _setup_keymaps()

  _set_autocmds(oil)
end

-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = _setup_core,
}
