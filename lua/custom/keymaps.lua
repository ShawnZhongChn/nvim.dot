--- @module custom.keymaps
--- Central registry for keymap declarations and which-key groups.

local M = {}

local _registered = {}
local _groups = {}

local function _normalize_modes(mode)
  if type(mode) == 'table' then
    return mode
  end
  return { mode }
end

local function _scope_key(mode, lhs, buffer)
  return table.concat({ mode, lhs, tostring(buffer or 'global') }, '\0')
end

--- @param spec table
function M.register(spec)
  assert(spec and spec.lhs and spec.rhs and spec.mode, 'keymap spec requires mode, lhs, rhs')

  local opts = vim.tbl_deep_extend('force', { noremap = true, silent = true }, spec.opts or {})
  if spec.desc then
    opts.desc = spec.desc
  end
  if spec.buffer ~= nil then
    opts.buffer = spec.buffer
  end

  for _, mode in ipairs(_normalize_modes(spec.mode)) do
    local key = _scope_key(mode, spec.lhs, spec.buffer)
    if _registered[key] then
      vim.notify(('Duplicate keymap ignored: %s (%s)'):format(spec.lhs, mode), vim.log.levels.WARN)
    else
      _registered[key] = true
      vim.keymap.set(mode, spec.lhs, spec.rhs, opts)
    end
  end
end

--- @param specs table[]
function M.register_many(specs)
  for _, spec in ipairs(specs or {}) do
    M.register(spec)
  end
end

--- @param prefix string
--- @param name string
--- @param opts table|nil
function M.register_group(prefix, name, opts)
  local entry = vim.tbl_extend('force', { [1] = prefix, group = name }, opts or {})
  table.insert(_groups, entry)
end

--- @return table[]
function M.groups()
  return vim.deepcopy(_groups)
end

function M.setup_defaults()
  M.register_group('<leader>c', '[C]ode', { mode = { 'n', 'x' } })
  M.register_group('<leader>x', '[X] Diagnostics')
  M.register_group('<leader>cq', 'Quickfix List')
  M.register_group('<leader>cw', 'Workspace Diagnostics')
  M.register_group('<leader>g', '[G]it')
  M.register_group('<leader>gh', 'Git [H]unk', { mode = { 'n', 'v' } })
  M.register_group('<leader>d', '[D]ocument')
  M.register_group('<leader>n', '[N]otices')
  M.register_group('<leader>r', '[R]ename')
  M.register_group('<leader>o', '[O]bsidian')
  M.register_group('<leader>s', '[S]earch')
  M.register_group('<leader>w', '[W]orkspace')
  M.register_group('<leader>t', '[T]oggle')
  M.register_group('<leader>f', '[F]iles')
  M.register_group('<leader>l', '[L]azy')
  M.register_group('<leader>fs', '[S]cratch Pad')
  M.register_group('<leader>fy', 'Yazi')
end

return M
