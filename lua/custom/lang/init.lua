--- @module custom.lang
--- Language workflow registry.

local M = {}

M.python = require 'custom.lang.python'
M.frontend = require 'custom.lang.frontend'
M.rust = require 'custom.lang.rust'
M.markdown = require 'custom.lang.markdown'

local PROFILE_BY_FILETYPE = {
  python = M.python,
  javascript = M.frontend,
  javascriptreact = M.frontend,
  typescript = M.frontend,
  typescriptreact = M.frontend,
  css = M.frontend,
  json = M.frontend,
  jsonc = M.frontend,
  rust = M.rust,
  markdown = M.markdown,
}

function M.setup()
end

function M.profiles()
  return {
    M.python.profile(),
    M.frontend.profile(),
    M.rust.profile(),
    M.markdown.profile(),
  }
end

--- @param filetype string
--- @param bufnr integer|nil
function M.setup_filetype(filetype, bufnr)
  local profile = PROFILE_BY_FILETYPE[filetype]
  if profile and profile.setup then
    profile.setup(bufnr or 0)
  end
end

return M
