--- @Note: Nvim-cmp 核心配置，特别强化了 Markdown/Text 的英文单词联想与拼写检查
---

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 获取通用的代码补全源
--- @return table
local _get_code_sources = function()
  return {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
  }
end

--- 获取英文写作专属补全源 (Scheme 1 核心)
--- @Note: 仅在 markdown/text/gitcommit 中启用
--- @return table
local _get_writing_sources = function()
  return {
    -- 1. 字典联想 (核心): 读取系统 /usr/share/dict/words
    -- 效果：输入 "int" -> 提示 "intelligent", "interface", "internet"
    {
      name = "look",
      keyword_length = 2,
      option = {
        convert_case = true,
        loud = true,
      },
    },
    -- 2. 拼写检查: 基于 vim.opt.spell 的纠错
    -- 效果：输入错词 -> 提示修正建议
    {
      name = "spell",
      option = {
        keep_all_entries = false,
        enable_in_context = function()
          return true
        end,
      },
    },
    -- 3. 路径补全: 方便插入图片/文件链接
    { name = "path" },
    -- 4. 常用片段: 方便插入日期、frontmatter 等
    { name = "luasnip" },
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- 自定义补全菜单的格式化 (增加图标与来源标注)
--- @param entry any
--- @param vim_item table
--- @return table
local _format_completion_item = function(entry, vim_item)
  local icons = {
    look  = " (Dict)",  -- 字典图标
    spell = "󰓆 (Spell)", -- 拼写图标
    path  = " (Path)",
    LSP   = "",
  }

  -- 设置 Source 来源提示
  vim_item.menu = icons[entry.source.name] or entry.source.name
  return vim_item
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- 初始化 cmp 逻辑
--- @param _ any
--- @param _ any
local _init_cmp = function(_, _)
  local cmp = require("cmp")

  -- 1. 全局通用配置 (代码模式)
  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then cmp.select_next_item() else fallback() end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources(_get_code_sources()),
  })

  -- 2. 特定文件类型配置 (写作模式)
  -- 针对 Markdown, Text, GitCommit 启用单词联想
  cmp.setup.filetype({ "markdown", "text", "gitcommit" }, {
    sources = cmp.config.sources(_get_writing_sources()),
    formatting = {
      format = _format_completion_item,
    },
  })

  -- 3. 命令行搜索模式 (/ 模式) 使用 buffer 内容
  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" }
    }
  })
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- 插入模式加载，提升启动速度
  dependencies = {
    -- 核心补全引擎
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",

    -- 英文写作核心依赖 (Scheme 1)
    "octaltree/cmp-look", -- 读取系统字典实现单词联想
    "f3fora/cmp-spell",   -- 拼写检查源

    -- Snippet 引擎
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = _init_cmp,
}
