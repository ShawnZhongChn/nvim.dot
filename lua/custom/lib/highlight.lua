--- @module custom.lib.highlight
--- Formatting helpers for statusline and other UI surfaces.

local M = {}

--- @param hl string
--- @param text string
--- @return string
function M.statusline(hl, text)
  return string.format('%%#%s#%s%%*', hl, text)
end

--- @param num integer
--- @param sep string
--- @return string
function M.group_number(num, sep)
  local value = tostring(num)
  if #value < 4 then
    return value
  end
  return value:reverse():gsub('(%d%d%d)', '%1' .. sep):reverse():gsub('^' .. sep, '')
end

return M
