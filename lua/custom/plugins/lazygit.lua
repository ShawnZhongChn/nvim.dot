--- @Note: 增强型 LazyGit 配置
--- 优化了悬浮窗的视觉比例、增加了圆角边框支持，并实现了 Which-key 的自动化标签管理。

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @Note 配置全局变量以美化 UI 表现，适配 Hyprland/4K 环境
--- @return nil
local _apply_ui_options = function()
  -- 悬浮窗缩放比例 (0-1)，针对大屏优化
  vim.g.lazygit_floating_window_scaling_factor = 0.85
  -- 悬浮窗圆角边框字符
  vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
  -- 启用高度集成的 Plenary 窗口控制
  vim.g.lazygit_floating_window_use_plenary = 1
  -- 允许在 LazyGit 中使用 Neovim 的远程控制
  vim.g.lazygit_use_neovim_remote = 1
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note: 增强型 LazyGit 配置
local _setup_keymaps = function()
  return {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit (Float)' },
    { '<leader>lc', '<cmd>LazyGitConfig<cr>', desc = 'LazyGit Config' },
    { '<leader>lf', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit Current File' },
  }
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note 插件初始化逻辑与 Lazy.nvim 规格定义
--- @return table
local _build_spec = function()
  _apply_ui_options()

  return {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- 自动化管理的核心：Lazy 会自动将此 table 同步给 Which-key
    keys = _setup_keymaps(),
    config = function()
      -- 预留：Telescope 扩展加载
      -- pcall(require("telescope").load_extension, "lazygit")
    end,
  }
end

return _build_spec()
