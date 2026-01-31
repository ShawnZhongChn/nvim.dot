--- @Note: 仅启用 Snacks.nvim 的 Scratch 模块，避免与 Noice/Notify/Telescope 冲突
--- 满足 IDEA 风格的快速类型选择创建

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 预设草稿类型列表
--- @return table
local function _get_fts()
  return { 'lua', 'python', 'markdown', 'json', 'go', 'sql', 'sh' }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- 模拟 IDEA 创建草稿的 UI 选择逻辑
local function _create_idea_scratch()
  vim.ui.select(_get_fts(), {
    prompt = 'Create Scratch File ❯ ',
  }, function(choice)
    if choice then
      require('snacks').scratch { ft = choice, name = 'Scratch' }
    end
  end)
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- 显式禁用所有可能引起冲突的模块
--- @return table
local function _get_safe_opts()
  return {
    scratch = { enabled = true },
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
    -- 绑定你习惯的快捷键
    { '<leader>fsn', _create_idea_scratch, desc = 'New Scratch ' },
    {
      '<leader>fss',
      function()
        require('snacks').scratch.select()
      end,
      desc = 'List Scratches',
    },
  },
}
