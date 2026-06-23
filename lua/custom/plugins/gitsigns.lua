-- Adds git related signs to the gutter, as well as utilities for managing change----------------- @Note: Git Signs 配置
--- 在侧边栏显示 Git 变更状态，并提供 Hunk 操作、Diff 预览与 Blame 功能。
--- @url: https://github.com/lewis6991/gitsigns.nvim

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- @Note: 定义侧边栏 Git 状态图标 (使用平滑线条)
--- @return table
local function _get_signs_config()
  return {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  }
end

--- @Note: 获取核心配置项
--- @return table
local function _get_opts()
  return {
    signs = _get_signs_config(),
    -- 符号列优先级
    sign_priority = 6,
    -- 预览窗口配置
    preview_config = {
      border = 'rounded', -- 使用圆角边框
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
    -- 这里的 on_attach 将在 _config 中动态绑定，保持 opts 纯净
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- @Note: 为当前 Git 仓库下的 Buffer 绑定快捷键
--- @param bufnr number
local function _setup_buffer_keymaps(bufnr)
  local gitsigns = require 'gitsigns'

  -- 辅助函数：简化按键映射
  local function map(mode, l, r, desc)
    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
  end

  -- 1. 导航 (Navigation)
  map('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      gitsigns.nav_hunk 'next'
    end
  end, 'Git: Jump to next change')

  map('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      gitsigns.nav_hunk 'prev'
    end
  end, 'Git: Jump to prev change')

  -- 2. 核心操作 (Hunk Actions)
  -- Visual Mode
  map('v', '<leader>ghs', function()
    gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, 'Git: Stage hunk (v)')
  map('v', '<leader>ghr', function()
    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, 'Git: Reset hunk (v)')

  -- Normal Mode
  map('n', '<leader>ghs', gitsigns.stage_hunk, 'Git: Stage hunk')
  map('n', '<leader>ghr', gitsigns.reset_hunk, 'Git: Reset hunk')
  map('n', '<leader>ghu', gitsigns.undo_stage_hunk, 'Git: Undo stage hunk')
  map('n', '<leader>ghS', gitsigns.stage_buffer, 'Git: Stage buffer')
  map('n', '<leader>ghR', gitsigns.reset_buffer, 'Git: Reset buffer')

  -- 3. 预览与查看 (Preview & Review)
  map('n', '<leader>ghp', gitsigns.preview_hunk, 'Git: Preview hunk')
  map('n', '<leader>ghb', function()
    gitsigns.blame_line { full = true }
  end, 'Git: Blame line')
  map('n', '<leader>ghB', gitsigns.toggle_current_line_blame, 'Git: Toggle blame line')
  map('n', '<leader>ghd', gitsigns.preview_hunk_inline, 'Git: Toggle deleted preview')

  -- 4. 差异对比 (Diff)
  map('n', '<leader>ghD', gitsigns.diffthis, 'Git: Diff vs Index')
  map('n', '<leader>ghE', function()
    gitsigns.diffthis '@'
  end, 'Git: Diff vs Last Commit')
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- @Note: 插件初始化与配置注入
--- @param opts table
local function _config(_, opts)
  -- 将 Keymaps 绑定逻辑注入到 on_attach 回调中
  opts.on_attach = _setup_buffer_keymaps

  require('gitsigns').setup(opts)
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' }, -- 优化加载时机
    opts = _get_opts(),
    config = _config,
  },
}
