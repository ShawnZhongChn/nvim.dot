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
  require 'globals'

  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.opt.termguicolors = true

  _load_core_config()

  pcall(vim.fn.serverstart, require('custom.config').get_value({ 'env', 'nvim_server_pipe' }, '/tmp/nvim'))

  local lazypath = _ensure_lazy_installed()
  vim.opt.rtp:prepend(lazypath)

  require('lazy').setup(_get_lazy_opts())
end

_init()

-- vim: ts=2 sts=2 sw=2 et
