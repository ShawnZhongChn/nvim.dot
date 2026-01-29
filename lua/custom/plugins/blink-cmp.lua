----------------- @Note: Blink.cmp 自动补全配置
--- 基于 Rust 的高性能补全引擎，内置 LSP、Snippet 和签名提示功能。
--- @url: https://github.com/saghen/blink.cmp

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- @Note: 构建 LuaSnip 的编译命令 (仅在非 Windows 且有 make 环境下执行)
--- @return string|nil
local function _get_luasnip_build_cmd()
  -- Windows 或无 make 环境跳过编译
  if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
    return nil
  end
  return 'make install_jsregexp'
end

--- @Note: 获取 Blink 核心配置项
--- @return table
local function _get_opts()
  return {
    -- 1. 快捷键配置
    keymap = {
      -- 使用 'default' 预设 (类似原生体验):
      -- <C-space>: 触发补全
      -- <C-e>: 关闭菜单
      -- <C-y>: 确认选择 (支持自动导入)
      -- <C-k>: 切换签名提示
      preset = 'default',
    },

    -- 2. 外观配置
    appearance = {
      use_nvim_cmp_as_default = true, -- 为了兼容性
      nerd_font_variant = 'mono', -- 调整图标对齐
    },

    -- 3. 补全行为配置
    completion = {
      -- 文档预览窗口
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = 'rounded' }, -- 美化：添加圆角边框
      },
      -- 补全菜单
      menu = {
        border = 'rounded',
      },
      -- 幽灵文字 (Ghost Text) 提示
      ghost_text = {
        enabled = false,
      },
    },

    -- 4. 补全源配置
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100, -- 提高 Lua 配置文件的补全优先级
        },
      },
    },

    -- 5. 模糊匹配引擎 (核心性能开关)
    fuzzy = {
      -- 强烈建议使用 Rust 后端以获得最佳性能 (特别是在 Python 大型库中)
      implementation = 'prefer_rust_with_warning',
    },

    -- 6. Snippet 引擎适配
    snippets = {
      preset = 'luasnip',
    },

    -- 7. 函数签名提示
    signature = {
      enabled = true,
      window = { border = 'rounded' }, -- 美化：添加圆角边框
    },
  }
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

-- Blink.cmp 通常是声明式配置，直接通过 opts 传入即可
-- 如果需要更复杂的动态逻辑，可在此处扩展 config 函数

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  {
    'saghen/blink.cmp',
    version = 'v0.*', -- 推荐锁定版本以保证稳定性
    -- 依赖项管理
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = _get_luasnip_build_cmd(), -- 调用构建命令生成器
        dependencies = {
          -- 'rafamadriz/friendly-snippets', -- 如果需要预制 Snippets 可解注
        },
      },
      -- Lua 开发环境增强
      'folke/lazydev.nvim',
    },

    -- 加载配置
    opts = _get_opts(),

    -- 优化：确保模块能正确加载
    opts_extend = { 'sources.default' },
  },
}
