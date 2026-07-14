vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? ShawnVimConfig
function M.setup(opts)
  require("shawnvim.config").setup(opts)
end

return M
