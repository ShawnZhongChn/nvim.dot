local M = {}

local function is_triple_quote_start(line)
  local trimmed = vim.trim(line)
  if trimmed:match([[^[rRuUbBfF]*''']]) then
    return "'''"
  end
  if trimmed:match([[^[rRuUbBfF]*"""]]) then
    return '"""'
  end
end

local function is_import_line(line)
  return line:match '^import%s+'
    or line:match '^from%s+[%w%._]+%s+import%s+'
end

local function is_continuation_line(line)
  return line:match '^%s*[%)%]}]?,?%s*$'
    or line:match '^%s*[%w_%.]+%s*,%s*$'
    or line:match '^%s*[%w_%.]+%s*\\%s*$'
    or line:match '^%s*[%w_%.]+%s*$'
    or line:match '^%s*#'
end

local function strip_inline_comment(line)
  local string_start = line:find([['"]])
  local comment_start = line:find('#', 1, true)
  if not comment_start or (string_start and string_start < comment_start) then
    return line
  end
  return line:sub(1, comment_start - 1)
end

local function skip_module_preamble(lines)
  local i = 1

  while i <= #lines do
    local trimmed = vim.trim(lines[i])
    if trimmed == '' or trimmed:match '^#' then
      i = i + 1
    else
      break
    end
  end

  local quote = is_triple_quote_start(lines[i] or '')
  if not quote then
    return i
  end

  local _, count = (lines[i] or ''):gsub(quote, '')
  if count >= 2 then
    return i + 1
  end

  i = i + 1
  while i <= #lines do
    if (lines[i] or ''):find(quote, 1, true) then
      return i + 1
    end
    i = i + 1
  end

  return i
end

local function get_import_ranges(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count < 2 then
    return {}
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_count, false)
  local ranges = {}
  local i = skip_module_preamble(lines)

  while i <= #lines do
    local start_line, end_line
    local paren_depth = 0
    local continued_with_backslash = false

    while i <= #lines do
      local trimmed = vim.trim(lines[i])
      if trimmed == '' or trimmed:match '^#' then
        i = i + 1
      elseif is_import_line(lines[i]) then
        start_line = i
        end_line = i
        break
      else
        break
      end
    end

    if not start_line then
      i = i + 1
      goto continue
    end

    while i <= #lines do
      local line = lines[i]
      local trimmed = vim.trim(line)

      if i == start_line then
      elseif trimmed == '' then
        end_line = i
      elseif is_import_line(line) then
        end_line = i
      elseif paren_depth > 0 or continued_with_backslash then
        if is_continuation_line(line) then
          end_line = i
        else
          break
        end
      else
        break
      end

      local code = strip_inline_comment(line)
      local opens = select(2, code:gsub('[%(%[{]', ''))
      local closes = select(2, code:gsub('[%)%]}]', ''))
      paren_depth = math.max(0, paren_depth + opens - closes)
      continued_with_backslash = code:match '\\%s*$' ~= nil
      i = i + 1
    end

    if start_line and end_line and end_line > start_line then
      table.insert(ranges, { start_line, end_line })
    end

    ::continue::
  end

  return ranges
end

local function apply_import_folds(winid, ranges)
  vim.api.nvim_win_call(winid, function()
    vim.wo.foldenable = true
    vim.wo.foldmethod = 'manual'
    pcall(vim.cmd, 'silent! normal! zE')
    for _, range in ipairs(ranges) do
      pcall(vim.cmd, string.format('silent! %d,%dfold', range[1], range[2]))
      pcall(vim.cmd, string.format('silent! %dfoldclose', range[1]))
    end
  end)
  vim.w[winid].python_import_fold_ranges = ranges
end

function M.apply(bufnr)
  local winids = vim.fn.win_findbuf(bufnr)
  if type(winids) ~= 'table' or #winids == 0 then
    return
  end

  local ranges = get_import_ranges(bufnr)
  for _, winid in ipairs(winids) do
    if vim.api.nvim_win_is_valid(winid) then
      apply_import_folds(winid, ranges)
    end
  end
end

return M
