--- @Note: Noice 配置 - 将 CMD, Messages, Popupmenu UI 化
--- 针对 120Hz 高刷屏优化：平滑动画与高清 UI
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Options Components
-------------------------------------------------------------------------------

--- @return table
--- @Note 配置 UI 视图样式，在 4K 屏幕上使用更加精致的尺寸
local _get_view_configs = function()
  return {
    cmdline_popup = {
      position = { row = '40%', col = '50%' },
      size = { width = 60, height = 'auto' },
      border = { style = 'rounded', padding = { 0, 1 } },
    },
    popupmenu = {
      relative = 'editor',
      position = { row = '55%', col = '50%' },
      size = { width = 60, height = 10 },
      border = { style = 'rounded', padding = { 0, 1 } },
      win_options = { winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' } },
    },
  }
end

--- @return table
--- @Note 配置路由规则 (例如：隐藏不需要的高频写入消息)
local _get_routes = function()
  return {
    {
      filter = { event = 'msg_show', find = 'written' }, -- 隐藏 "X lines written"
      opts = { skip = true },
    },
  }
end

-------------------------------------------------------------------------------
-- Enhancement Methods
-------------------------------------------------------------------------------

--- @Note 绑定快捷键：快速进入消息历史或清除消息
local _setup_keymaps = function()
  local map = vim.keymap.set
  -- 查看消息历史 (在 4K 屏上分屏看报错非常爽)
  map('n', '<leader>nl', '<cmd>Noice last<CR>', { desc = 'Noice: Show Last Message' })
  map('n', '<leader>nh', '<cmd>Noice history<CR>', { desc = 'Noice: Show History' })
  map('n', '<leader>nd', '<cmd>Noice dismiss<CR>', { desc = 'Noice: Dismiss All' })

  -- 针对你的需求：直接把最后一条消息存入剪贴板
  map('n', '<leader>ny', function()
    require('noice').redirect(function()
      print(vim.fn.getreg '"') -- 这里的逻辑可以通过 noice 路由截取
    end)
  end, { desc = 'Noice: Yank Last Message' })
end

-------------------------------------------------------------------------------
-- Core Logic
-------------------------------------------------------------------------------
local _setup_noice = function()
  require('noice').setup {
    notify = {
      enabled = false,
      view = 'notify',
    },

    -- 核心：重定向标准的命令行和输入
    cmdline = { enabled = true, view = 'cmdline_popup' },
    messages = { enabled = true, view = 'notify' },
    popupmenu = { enabled = true, view = 'popupmenu' },

    -- LSP 增强
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      hover = { enabled = true, silent = true },
      signature = { enabled = true },
    },

    -- 针对 120Hz 的动画流畅度调整
    views = _get_view_configs(),
    routes = _get_routes(),

    -- 预设功能
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
    },
  }

  _setup_keymaps()
end
-------------------------------------------------------------------------------
-- Plugin Spec
-------------------------------------------------------------------------------

return {
  'folke/noice.nvim',
  lazy = false,
  priority = 1000,
  dependencies = {
    'MunifTanjim/nui.nvim',
    {
      'rcarriga/nvim-notify',
      opts = {
        fps = 120, -- 强制开启 120 FPS 渲染
        render = 'compact',
        stages = 'fade_in_slide_out',
        background_colour = '#000000',
      },
    },
  },
  config = _setup_noice,
}
