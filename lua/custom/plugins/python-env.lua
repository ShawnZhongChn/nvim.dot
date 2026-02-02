--- @Note venv-selector 核心配置：使用 fd 精准检索 Conda 环境
--- @author shawn

-- -------------------------------------------------------------------------
-- Options Components
-- -------------------------------------------------------------------------

--- 生成针对 macOS Miniconda 环境的检索配置
--- @return table
local _get_anaconda_search_opts = function()
  return {
    -- -L: 跟随软链接
    -- -a: 输出绝对路径
    -- -p: 关键！开启路径全匹配，否则搜不到 bin/python
    command = 'fd -L -a -p "bin/python$" /opt/miniconda3/envs --color never',
    type = 'anaconda',
  }
end

-- -------------------------------------------------------------------------
-- Plugin Spec
-- -------------------------------------------------------------------------

return {
  'linux-cultist/venv-selector.nvim',
  branch = 'regexp', -- 建议使用 regexp 分支以获得更好的 fd 支持
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-telescope/telescope.nvim',
  },
  opts = function()
    return {
      search = {
        conda_envs = _get_anaconda_search_opts(),
      },
      -- 侧重逻辑：切换环境后自动重启 LSP
      auto_refresh = true,
      stay_on_this_version = true,
    }
  end,
  keys = {
    { '<leader>cv', '<cmd>VenvSelect<cr>', desc = 'Select VirtualEnv' },
  },
}
