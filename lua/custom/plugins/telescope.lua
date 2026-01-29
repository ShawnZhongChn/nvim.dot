--------------------------------------------------------------------------
-- Header: Telescope 配置 (支持 Zoxide 项目制跳转 - 安全版)
--------------------------------------------------------------------------

--- @param selection table Zoxide 选择的条目对象
--- @Note [Project Mode] 跳转目录并清理所有旧 Buffer (包含安全检查)
local _on_project_open = function(selection)
  -- 1. 安全检查：遍历所有 Buffer 查看是否有未保存更改
  local modified_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- 检查 buffer 是否被修改 (modified) 且是加载的 (loaded)
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_get_option_value('modified', { buf = buf }) then
      table.insert(modified_buffers, vim.api.nvim_buf_get_name(buf))
    end
  end

  -- 如果发现有未保存的文件，发出警告并终止操作
  if #modified_buffers > 0 then
    vim.notify('Abort: You have unsaved changes!', vim.log.levels.ERROR)
    -- 可选：打印出具体哪些文件没保存
    -- for _, file in ipairs(modified_buffers) do vim.notify('Unsaved: ' .. file, vim.log.levels.WARN) end
    return
  end

  -- 2. 切换工作目录
  vim.cmd.cd(selection.path)

  -- 3. 清理 Buffer
  -- 此时已确认无未保存文件，使用 %bd! 是安全的，它可以强制清理掉一些非文件类型的 buffer (如 NvimTree, Output 面板等)
  vim.cmd 'silent! %bd!'

  -- 4. 打印提示
  vim.notify('Project loaded: ' .. selection.path, vim.log.levels.INFO)
end

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
      -- zoxide 扩展配置
      zoxide = {
        prompt_title = '[ Project Switcher ]',
        mappings = {
          ['<CR>'] = {
            keepinsert = true,
            action = _on_project_open,
          },
        },
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

  -- Zoxide 入口
  vim.keymap.set('n', '<leader>sz', function()
    require('telescope').extensions.zoxide.list()
  end, { desc = '[S]earch [Z]oxide Projects' })

  -- 高级用法
  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  vim.keymap.set('n', '<leader>sc', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [C]onfig files' })
end

--------------------------------------------------------------------------

--- @Note 核心初始化逻辑
local _setup_core = function()
  local telescope = require 'telescope'
  local builtin = require 'telescope.builtin'

  telescope.setup(_get_opts())

  pcall(telescope.load_extension, 'fzf')
  pcall(telescope.load_extension, 'ui-select')
  pcall(telescope.load_extension, 'zoxide')

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
    'jvgrootveld/telescope-zoxide',
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
