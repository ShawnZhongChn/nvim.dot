-- Description: Python Virtual Environment switcher-- Description: Python Virtual Environment Selector
--              Replaces swenv.nvim with venv-selector (Regexp branch recommended)
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

---构建并返回插件配置表
---@Note 定义搜索规则和 UI 行为
---@return table
local function _get_opts()
  return {
    -- 核心配置：查找名为 .venv 或 venv 的目录
    name = { '.venv', 'venv' },

    dap_enabled = true, -- 如果你使用 nvim-dap，这会自动更新 debugger 的 python 路径

    -- UI 设置
    settings = {
      search = {
        my_venvs = {
          command = 'fd python$ /opt/miniconda3/envs',
        },
      },
      options = {
        notify_user_on_venv_activation = true,
      },
    },
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

---配置插件相关的键位映射
---@Note <leader>cv 呼出环境选择菜单 (基于 Telescope)
---@return nil
local function _set_keymaps()
  -- 手动选择环境
  -- 使用 :VenvSelect 命令呼出界面
  vim.keymap.set('n', '<leader>cv', '<cmd>VenvSelect<cr>', { desc = 'Python: Choose Virtual Env' })
end

---设置自动激活逻辑 (venv-selector 自带缓存，通常不需要此 Autocmd)
---@Note 只有在需要强制“首次打开即自动寻找 .venv”时保留，否则插件会记忆上次的选择
---@return nil
local function _set_autocmds()
  -- venv-selector (regexp分支) 会自动记忆你为项目选择的环境
  -- 因此，通常不需要像 swenv 那样写 FileType Autocmd。
  -- 插件初始化时会自动尝试加载缓存的环境。
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

---执行插件的初始化逻辑
---@param opts table 插件配置选项
---@return nil
local function _setup_core(opts)
  require('venv-selector').setup(opts)

  -- 注册增强功能
  _set_keymaps()
  -- _set_autocmds() -- 除非有特殊需求，否则不再需要手动 Autocmd
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  'linux-cultist/venv-selector.nvim',
  branch = 'main', -- 强力推荐：使用重构后的分支，性能更好且支持缓存
  ft = 'python', -- 懒加载：仅在 Python 文件中加载
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-telescope/telescope.nvim',
    'mfussenegger/nvim-dap', -- 可选：如果你需要调试 Python
    {
      'nvim-lua/plenary.nvim',
      branch = 'master',
    },
  },
  config = function(_, opts)
    -- 获取配置并初始化
    local final_opts = opts or _get_opts()
    _setup_core(final_opts)
  end,
  -- 将配置传递给 Lazy 用于合并
  opts = _get_opts(),
}
