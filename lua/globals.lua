--- @Note: 全局工具兼容桥。
--- @Note: 保留 _G.tools 与旧调用点，避免迁移期间破坏现有入口。

local lib = require 'custom.lib'

_G.tools = _G.tools or {}
local M = _G.tools

M.ui = lib.ui
M.reveal_in_explorer = lib.reveal_in_explorer
M.open_url = lib.open_url
M.get_path_root = lib.get_path_root
M.get_git_remote_name = lib.get_git_remote_name
M.get_git_branch = lib.get_git_branch
M.diagnostics_available = lib.diagnostics_available
M.hl_str = lib.hl_str
M.group_number = lib.group_number

return M
