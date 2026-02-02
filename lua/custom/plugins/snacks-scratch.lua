--- @Note: 仅启用 Snacks.nvim 的 Scratch 模块，避免与 Noice/Notify/Telescope 冲突

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 预设草稿类型列表
--- @return table
local function _get_fts()
  return { 'lua', 'py', 'md', 'json', 'go', 'sql', 'sh' }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

local function _create_idea_scratch()
  vim.ui.select(_get_fts(), {
    prompt = 'Create Scratch File ❯ ',
  }, function(choice)
    if choice then
      require('snacks').scratch { ft = choice, name = 'Scratch' }
    end
  end)
end

--- 在系统资源管理器中打开当前选中的文件
--- 适配 MacOS (Finder) 和 Linux (xdg-open)
--- @param picker table Snacks Picker 实例
local function _action_reveal_in_os(picker)
  local item = picker:current()
  if not item or not item.file then
    return
  end

  local path = vim.fn.expand(item.file)
  local is_mac = vim.fn.has 'macunix' == 1

  if is_mac then
    -- MacOS: 使用 -R 参数在 Finder 中“选中”文件
    os.execute('open -R ' .. vim.fn.shellescape(path))
  else
    -- Linux (Arch): 打开文件所在的目录
    local dir = vim.fn.fnamemodify(path, ':h')
    os.execute('xdg-open ' .. vim.fn.shellescape(dir))
  end
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- 显式禁用所有可能引起冲突的模块，并配置 Picker 行为
--- @return table
local function _get_safe_opts()
  return {
    scratch = { enabled = true },

    -- 针对 picker 模块进行微调
    picker = {
      sources = {
        scratch = {
          actions = {
            reveal_explorer = _action_reveal_in_os,
          },
          win = {
            input = {
              keys = {
                ['<C-n>'] = { 'list_down', mode = { 'i', 'n' } },
                ['<C-p>'] = { 'list_up', mode = { 'i', 'n' } },
                ['<C-e>'] = { 'reveal_explorer', mode = { 'i', 'n' }, desc = 'Reveal in OS Explorer' },
              },
            },
          },
        },
      },
    },

    notifier = { enabled = false },
    input = { enabled = false },
    indent = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
  }
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  'folke/snacks.nvim',
  lazy = true,
  opts = _get_safe_opts(),
  keys = {
    { '<leader>fsn', _create_idea_scratch, desc = 'New Scratch' },
    {
      '<leader>fss',
      function()
        require('snacks').scratch.select()
      end,
      desc = 'List Scratches',
    },
  },
}
