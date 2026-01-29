--- @Note Fuzzy Finder (files, lsp, etc) 配置文件
--------------------------------------------------------------------------

--- @return table
--- @Note 获取 Telescope 的基础配置项
local _get_opts = function()
  return {
    defaults = {
      -- mappings = { i = { ['<c-enter>'] = 'to_fuzzy_refine' } },
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown(),
      },
      -- zoxide 扩展的配置（可选）
      zoxide = {
        prompt_title = '[ Zoxide List ]',
      },
    },
  }
end

--------------------------------------------------------------------------

--- @param builtin table
--- @Note 注册 Telescope 相关快捷键
local _set_keymaps = function(builtin)
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>sz', function()
    require('telescope').extensions.zoxide.list()
  end, { desc = '[S]earch [Z]oxide' })

  -- 高级用法：当前 Buffer 模糊搜索
  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- 高级用法：在已打开的文件中 Grep
  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  -- 快捷键：搜索 Neovim 配置文件
  vim.keymap.set('n', '<leader>sc', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [C]onfig files' })
end

--------------------------------------------------------------------------

--- @Note 核心初始化逻辑
local _setup_core = function()
  local telescope = require 'telescope'
  local builtin = require 'telescope.builtin'

  -- 1. 先进行基础设置
  telescope.setup(_get_opts())

  -- 2. 显式加载扩展（必须在 setup 之后）
  pcall(telescope.load_extension, 'fzf')
  pcall(telescope.load_extension, 'ui-select')
  pcall(telescope.load_extension, 'zoxide')

  -- 3. 设置快捷键
  _set_keymaps(builtin)
end

--------------------------------------------------------------------------

--- @return table
--- @Note 返回 Lazy.nvim 插件定义
return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'jvgrootveld/telescope-zoxide', -- 必须添加此依赖
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = _setup_core,
}
