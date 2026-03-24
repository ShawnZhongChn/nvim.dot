---
--- @Note: Obsidian.nvim 高级集成配置
--- @Desc: 集成笔记管理、每日日记、模板系统、智能链接跳转与 Zettelkasten 工作流
---

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

--- 生成 Obsidian 核心配置项
--- @return table
local _get_obsidian_opts = function()
  return {
    -- 1. 工作区定义 (支持多 Vault 切换)
    workspaces = {
      {
        name = 'personal',
        path = '/Users/shawn/Documents/Study/MyNotes/',
      },
      -- 添加 Workspace
    },

    -- Where to put new notes.
    new_notes_location = 'vault_root',

    -- The specific subdirectory for notes.
    notes_subdir = '', -- [Note]: 设置为 "" 则直接放在 MyNotes 根目录下

    -- 2. 每日笔记配置 (Daily Notes)
    daily_notes = {
      folder = 'dailies',
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      template = 'daily-template.md', -- 需在 templates 目录创建此文件
    },

    -- 2.5 模板配置 (Templates)
    templates = {
      subdir = '4 - Templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
      substitutions = {},
    },

    -- 3. 补全集成 (Completion)
    completion = {
      nvim_cmp = false, -- 如果使用 nvim-cmp
      min_chars = 2,
    },

    -- 4. 界面美化 (UI)
    ui = {
      enable = true,
      update_debounce = 200,
      bullets = { char = '•', hl_group = 'ObsidianBullet' },
      external_link_icon = { char = '', hl_group = 'ObsidianExtLink' },
      reference_text = { hl_group = 'ObsidianRefText' },
      highlight_text = { hl_group = 'ObsidianHighlightText' },
      tags = { hl_group = 'ObsidianTag' },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = '#f78c6c' },
        ObsidianDone = { bold = true, fg = '#89ddff' },
        ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
        ObsidianTilde = { bold = true, fg = '#ff5370' },
        ObsidianBullet = { bold = true, fg = '#89ddff' },
        ObsidianRefText = { underline = true, fg = '#c792ea' },
        ObsidianExtLink = { fg = '#c792ea' },
        ObsidianTag = { italic = true, fg = '#89ddff' },
        ObsidianHighlightText = { bg = '#75662e' },
      },
    },

    checkboxes = {
      [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
      ['x'] = { char = '', hl_group = 'ObsidianDone' },
      ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
      ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
    },

    -- 5. 附件与图片 (Attachments)
    attachments = {
      folder = 'assets/imgs', -- 图片存放目录
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format('![%s](%s)', path.name, path)
      end,
    },

    -- 6. Frontmatter 智能生成 (Zettelkasten ID)
    frontmatter = {
      enabled = true,
      --- @param note table
      func = function(note)
        -- 如果已有 frontmatter，保留大部分字段
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          return note.metadata
        end

        -- 生成新笔记的元数据
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- 如果 ID 不是日期格式，添加 created/updated 时间戳
        if note.title and not note.title:match '%d%d%d%d%-%d%d%-%d%d' then
          out.created = os.date '%Y-%m-%d %H:%M'
          out.updated = os.date '%Y-%m-%d %H:%M'
        end

        return out
      end,
    },

    -- 7. 笔记 ID 生成规则
    note_id_func = function(title)
      -- 优先使用标题作为文件名 (Readable)
      local suffix = ''
      if title ~= nil then
        -- 将标题转换为文件名格式 (如 "My Note" -> "my-note")
        return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        -- 否则使用 Zettelkasten 时间戳
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return tostring(os.time()) .. '-' .. suffix
      end
    end,
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

--- 智能回车行为：根据光标上下文执行不同操作
--- 1. 在 Markdown 链接上 -> 跳转
--- 2. 在复选框上 -> 切换状态
--- 3. 否则 -> 普通回车
--- @return string|nil
local _smart_action = function()
  local obsidian = require 'obsidian'
  if obsidian.util.cursor_on_markdown_link(nil, nil, true) then
    return '<cmd>ObsidianFollowLink<CR>'
  elseif obsidian.util.cursor_on_checkbox(nil, nil) then
    return '<cmd>ObsidianToggleCheckbox<CR>'
  else
    return '<CR>'
  end
end

--- 设置 Obsidian 专用快捷键
--- @param client table
local _setup_keymaps = function(client)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { remap = false, buffer = true, desc = desc })
  end

  -- 核心操作 (Buffer-local)
  map('n', 'gd', '<cmd>ObsidianFollowLink<CR>', 'Obsidian: Follow Link')
  map('n', '<CR>', _smart_action, 'Obsidian: Smart Action')
  map('n', '<BS>', '<cmd>ObsidianBacklinks<CR>', 'Obsidian: Show Backlinks')

  -- 高级操作 (Buffer-local)
  map('v', '<leader>ol', '<cmd>ObsidianLink<CR>', 'Obsidian: Link Selection')
  map('n', '<leader>oc', '<cmd>ObsidianToggleCheckbox<CR>', 'Obsidian: Toggle Checkbox')
  map('n', '<leader>op', '<cmd>ObsidianPasteImg<CR>', 'Obsidian: Paste Image')
end

--- 自动配置：设置 Markdown 专属选项
local _setup_autocmds = function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
      vim.opt_local.conceallevel = 2 -- 隐藏 Markdown 语法符号，仅显示渲染效果
      vim.opt_local.wrap = true -- 自动换行
    end,
  })
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

--- 初始化插件并挂载逻辑
--- @param _ any
--- @param opts table
local _init_obsidian = function(_, opts)
  local obsidian = require 'obsidian'
  obsidian.setup(opts)

  -- 仅在 Markdown 文件进入时绑定快捷键，避免污染全局
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
      _setup_keymaps(obsidian)
      _setup_autocmds()
    end,
  })
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  lazy = true,
  -- 使用 keys 触发加载，确保全局可用
  keys = {
    {
      '<leader>on',
      function()
        local vault_path = '/Users/shawn/Documents/Study/MyNotes/'
        -- 1. 切换 Neovim 的工作目录到 Vault 根目录
        -- 这样输入框的路径补全就会基于此目录
        vim.cmd.cd(vault_path)
        -- 2. 确保插件识别到该工作区
        vim.cmd 'ObsidianWorkspace personal'
        -- 3. 触发新建笔记
        vim.cmd 'ObsidianNew'
      end,
      desc = 'Obsidian: New Note (at Vault Root)',
    },
    { '<leader>oo', '<cmd>ObsidianOpen<CR>', desc = 'Obsidian: Open in App' },
    { '<leader>od', '<cmd>ObsidianToday<CR>', desc = 'Obsidian: Daily Note' },
    { '<leader>oy', '<cmd>ObsidianYesterday<CR>', desc = 'Obsidian: Yesterday Note' },
    { '<leader>ot', '<cmd>ObsidianTemplate<CR>', desc = 'Obsidian: Insert Template' },
    { '<leader>os', '<cmd>ObsidianSearch<CR>', desc = 'Obsidian: Search (Grep)' },
    { '<leader>of', '<cmd>ObsidianQuickSwitch<CR>', desc = 'Obsidian: Find File' },
  },
  ft = 'markdown', -- 也可以通过打开 Markdown 文件加载
  dependencies = {
    -- 基础依赖
    'nvim-lua/plenary.nvim',
    -- 搜索依赖 (可选但推荐)
    'nvim-telescope/telescope.nvim',
    -- 语法高亮依赖
    'nvim-treesitter/nvim-treesitter',
  },
  opts = _get_obsidian_opts(),
  config = _init_obsidian,
}
