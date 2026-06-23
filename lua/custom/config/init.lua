--- @module custom.config
--- Centralized configuration defaults with optional local overrides and env vars.

local M = {}

local DEFAULTS = {
  env = {
    obsidian_vault = '/Users/shawn/Documents/Personal/MyNotes',
    obsidian_workspace = 'personal',
    obsidian_preview_vault = 'MyNotes',
    conda_envs_path = '/opt/miniconda3/envs',
    nvim_server_pipe = '/tmp/nvim',
    system_open_cmd = nil,
    file_reveal_cmd = nil,
  },
  ui = {
    theme = 'kanagawa-dragon',
    icons = true,
    statusline_enabled = true,
    noice_enabled = true,
    diagnostics_style = 'inline',
  },
  lang = {
    python = {
      typing_policy = 'relaxed',
    },
    frontend = {
      formatter = 'auto',
    },
    rust = {
      debug_adapter = 'codelldb',
    },
    markdown = {
      vault_mode = 'obsidian',
    },
    lua = {
      lsp = 'lua_ls',
    },
  },
  features = {
    obsidian = true,
    markdown_preview = true,
    lazydocker = true,
    auto_install_tools = true,
    auto_update_tools = true,
  },
}

local ENV_MAP = {
  env = {
    obsidian_vault = 'NVIM_OBSIDIAN_VAULT',
    obsidian_workspace = 'NVIM_OBSIDIAN_WORKSPACE',
    obsidian_preview_vault = 'NVIM_OBSIDIAN_PREVIEW_VAULT',
    conda_envs_path = 'NVIM_CONDA_ENVS_PATH',
    nvim_server_pipe = 'NVIM_SERVER_PIPE',
    system_open_cmd = 'NVIM_SYSTEM_OPEN_CMD',
    file_reveal_cmd = 'NVIM_FILE_REVEAL_CMD',
  },
  ui = {
    theme = 'NVIM_THEME',
    icons = 'NVIM_UI_ICONS',
    statusline_enabled = 'NVIM_STATUSLINE_ENABLED',
    noice_enabled = 'NVIM_NOICE_ENABLED',
    diagnostics_style = 'NVIM_DIAGNOSTICS_STYLE',
  },
  features = {
    obsidian = 'NVIM_FEATURE_OBSIDIAN',
    markdown_preview = 'NVIM_FEATURE_MARKDOWN_PREVIEW',
    lazydocker = 'NVIM_FEATURE_LAZYDOCKER',
    auto_install_tools = 'NVIM_FEATURE_AUTO_INSTALL_TOOLS',
    auto_update_tools = 'NVIM_FEATURE_AUTO_UPDATE_TOOLS',
  },
}

local _cached

local function _load_local_override()
  local ok, override = pcall(require, 'custom.config.local')
  if ok and type(override) == 'table' then
    return override
  end
  return {}
end

local function _decode_env_value(value, fallback)
  if value == nil or value == '' then
    return fallback
  end

  if type(fallback) == 'boolean' then
    local normalized = value:lower()
    return normalized == '1' or normalized == 'true' or normalized == 'yes' or normalized == 'on'
  end

  return value
end

local function _load_env_override()
  local override = {}
  for section, entries in pairs(ENV_MAP) do
    override[section] = override[section] or {}
    for key, env_name in pairs(entries) do
      local fallback = DEFAULTS[section][key]
      override[section][key] = _decode_env_value(vim.env[env_name], fallback)
    end
  end
  return override
end

--- @return table
function M.get()
  if not _cached then
    _cached = vim.tbl_deep_extend('force', vim.deepcopy(DEFAULTS), _load_env_override(), _load_local_override())
  end
  return _cached
end

--- @param path string[]
--- @param fallback any
--- @return any
function M.get_value(path, fallback)
  local cursor = M.get()
  for _, key in ipairs(path or {}) do
    if type(cursor) ~= 'table' then
      return fallback
    end
    cursor = cursor[key]
    if cursor == nil then
      return fallback
    end
  end

  if cursor == nil then
    return fallback
  end

  return cursor
end

--- @param name string
--- @return boolean
function M.is_enabled(name)
  return M.get_value({ 'features', name }, false) == true
end

return M
