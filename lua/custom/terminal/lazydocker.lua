--- @module custom.terminal.lazydocker
--- LazyDocker terminal wrapper used by the plugin adapter.

local M = {}

local _lazydocker_term = nil
local _compose_files = { 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml' }

local function _find_compose_root(path)
  return vim.fs.root(path, _compose_files)
end

local function _get_context_path()
  local cwd = vim.fn.getcwd()
  if cwd and cwd ~= '' then
    return vim.fn.fnamemodify(cwd, ':p')
  end

  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path ~= '' then
    return vim.fn.fnamemodify(buffer_path, ':p')
  end

  return vim.loop.cwd()
end

local function _get_project_root(path)
  local compose_root = _find_compose_root(path)
  if compose_root then
    return compose_root
  end

  local root = vim.fs.root(path, { '.git' })
  if root then
    return root
  end

  return vim.loop.cwd()
end

local function _get_running_project_name(root)
  local job = vim.system({ 'docker', 'compose', 'ls', '--format', 'json' }, { text = true }):wait()
  if job.code ~= 0 or not job.stdout or job.stdout == '' then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, job.stdout)
  if not ok or type(decoded) ~= 'table' then
    return nil
  end

  local projects = decoded
  if decoded.Name then
    projects = { decoded }
  end

  local normalize = function(p)
    return vim.fn.fnamemodify(p or '', ':p')
  end
  local normalized_root = normalize(root)

  for _, project in ipairs(projects) do
    local config_files = project.ConfigFiles
    if type(config_files) == 'string' and config_files ~= '' then
      for config_file in string.gmatch(config_files, '[^,]+') do
        local config_dir = normalize(vim.fs.dirname(vim.trim(config_file)))
        if config_dir == normalized_root then
          return project.Name
        end
      end
    end
  end

  return nil
end

local function _get_compose_project_name(root)
  local running_name = _get_running_project_name(root)
  if running_name and running_name ~= '' then
    return running_name
  end

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

local function _create_terminal()
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

function M.toggle()
  if _lazydocker_term and _lazydocker_term:is_open() then
    _lazydocker_term:close()
    return
  end

  _lazydocker_term = _create_terminal()
  _lazydocker_term:toggle()
end

function M.keys()
  return {
    { '<leader>ld', M.toggle, desc = 'LazyDocker' },
  }
end

return M
