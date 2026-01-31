--- @Note: Neovim Entry Point & Lazy.nvim Bootstrap
-- https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 加载基础核心配置模块
local function _load_core_config()
  require 'core.options'
  require 'core.keymaps'
  require 'core.autocmds'
end

--- 获取 Lazy.nvim 初始化配置
--- @return table
local function _get_lazy_opts()
  return {
    -- 自动从 custom/plugins 目录导入插件配置
    { import = 'custom.plugins' },
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- 引导安装 Lazy.nvim (Bootstrap)
--- @return string lazypath 插件管理器路径
local function _ensure_lazy_installed()
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      lazyrepo,
      lazypath,
    }
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
  end
  return lazypath
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- 主初始化流程
local function _init()
  -- 0. 加载全局工具
  require 'globals'

  -- 1. 加载核心配置 (确保 mapleader 在 Lazy 启动前设置)
  _load_core_config()

  -- 2. 启动 Neovim RPC 服务 (用于 MCP Server)
  -- 始终尝试启动固定路径的 Pipe，方便外部工具连接
  pcall(vim.fn.serverstart, '/tmp/nvim')

  -- 3. 注入插件管理器路径
  local lazypath = _ensure_lazy_installed()
  vim.opt.rtp:prepend(lazypath)

  -- 3. 启动插件系统
  require('lazy').setup(_get_lazy_opts())
end

-- 执行初始化
_init()

-- vim: ts=2 sts=2 sw=2 et