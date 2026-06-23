--- @module custom.lib
--- Shared low-level helpers exposed as explicit Lua modules.

local M = {}

M.icons = require 'custom.lib.icons'
M.git = require 'custom.lib.git'
M.path = require 'custom.lib.path'
M.system = require 'custom.lib.system'
M.diagnostics = require 'custom.lib.diagnostics'
M.highlight = require 'custom.lib.highlight'

M.ui = {
  icons = M.icons.get_icons(),
  kind_icons = M.icons.get_kind_icons(),
  kind_icons_spaced = M.icons.get_kind_icons_spaced(),
}

M.reveal_in_explorer = M.system.reveal_in_file_manager
M.open_url = M.system.open_url
M.get_path_root = M.path.get_project_root
M.get_git_remote_name = M.git.get_remote_name
M.get_git_branch = M.git.get_branch
M.diagnostics_available = M.diagnostics.available
M.hl_str = M.highlight.statusline
M.group_number = M.highlight.group_number

return M
