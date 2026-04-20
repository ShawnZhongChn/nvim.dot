--- @Note: Lazydocker 配置
--- 提供容器化管理工具的浮窗集成，并显式绑定项目根目录。

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

local _lazydocker_term = nil

--- @Note: 获取当前上下文路径
--- @return string
local _get_context_path = function()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path ~= '' then
    return vim.fn.fnamemodify(buffer_path, ':p')
  end
  return vim.loop.cwd()
end

--- @Note: 获取当前项目根目录，优先命中 compose 根目录
--- @param path string
--- @return string
local _get_project_root = function(path)
  local compose_root = vim.fs.root(path, { 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml' })
  if compose_root then
    return compose_root
  end

  local root = require('globals').get_path_root(path)
  if root then
    return root
  end

  return vim.loop.cwd()
end

--- @Note: 获取 compose project name，避免 LazyDocker 0.25 在多项目场景下选错项目
--- @param root string
--- @return string|nil
local _get_compose_project_name = function(root)
  local job = vim.system({ 'docker', 'compose', 'config', '--format', 'json' }, { cwd = root, text = true }):wait()
  if job.code ~= 0 or not job.stdout or job.stdout == '' then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, job.stdout)
  if not ok or type(decoded) ~= 'table' then
    return nil
  end

  return decoded.name
end

--- @Note: 创建 LazyDocker 浮窗终端
--- @return table
local _create_lazydocker_terminal = function()
  local Terminal = require('toggleterm.terminal').Terminal
  local root = _get_project_root(_get_context_path())
  local project_name = _get_compose_project_name(root)
  local cmd = 'lazydocker'

  if project_name and project_name ~= '' then
    cmd = cmd .. ' -p ' .. vim.fn.shellescape(project_name)
  end

  return Terminal:new {
    cmd = cmd,
    dir = root,
    direction = 'float',
    hidden = true,
    close_on_exit = true,
    float_opts = {
      border = 'curved',
      width = math.floor(vim.o.columns * 0.92),
      height = math.floor(vim.o.lines * 0.9),
    },
    on_open = function(term)
      vim.cmd 'startinsert!'
      vim.keymap.set('n', 'q', function() term:close() end, { buffer = term.bufnr, noremap = true, silent = true })
    end,
    on_close = function()
      _lazydocker_term = nil
    end,
  }
end

--- @Note: 切换 LazyDocker 浮窗
--- @return nil
local _toggle_lazydocker = function()
  if _lazydocker_term and _lazydocker_term:is_open() then
    _lazydocker_term:close()
    return
  end

  _lazydocker_term = _create_lazydocker_terminal()
  _lazydocker_term:toggle()
end

--- @Note: 定义快捷键映射
--- @return table
local _setup_keymaps = function()
  return {
    { '<leader>ld', _toggle_lazydocker, desc = 'LazyDocker' },
  }
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------

--- @Note 插件初始化逻辑与 Lazy.nvim 规格定义
--- @return table
local _build_spec = function()
  return {
    'akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    opts = {
      autochdir = false,
    },
    keys = _setup_keymaps(),
  }
end

return _build_spec()
