local VAULT_PATH = '/Users/shawn/Documents/Personal/MyNotes'
local ROUGH_NOTES_DIR = '1 - Rough Notes'
local TOPIC_PAGES_DIR = '3 - Tags'
local DAILY_NOTES_DIR = 'dailies'
local TEMPLATES_DIR = '4 - Templates'
local OBSIDIAN_GROUP = 'CustomObsidianVault'

local _trim = function(value)
  return value and vim.trim(value) or value
end

local _fallback_note_id = function()
  local suffix = ''
  for _ = 1, 4 do
    suffix = suffix .. string.char(math.random(65, 90))
  end
  return tostring(os.time()) .. '-' .. suffix
end

local _sanitize_note_id = function(title)
  title = _trim(title)
  if title == nil or title == '' then
    return nil
  end

  local sanitized = title
  sanitized = sanitized:gsub('[\\/:*?"<>|]', '-')
  sanitized = sanitized:gsub('[#%[%]%^]', '')
  sanitized = sanitized:gsub('%s+', ' ')
  sanitized = sanitized:gsub('^%s+', ''):gsub('%s+$', '')

  if sanitized == '' or sanitized:match '^%.+$' then
    return nil
  end

  return sanitized
end

local function _url_encode(str)
  if not str then return "" end
  str = string.gsub(str, " ", "%%20")
  str = string.gsub(str, "!", "%%21")
  str = string.gsub(str, "#", "%%23")
  str = string.gsub(str, "$", "%%24")
  str = string.gsub(str, "&", "%%26")
  str = string.gsub(str, "'", "%%27")
  str = string.gsub(str, "(", "%%28")
  str = string.gsub(str, ")", "%%29")
  str = string.gsub(str, "*", "%%2A")
  str = string.gsub(str, "+", "%%2B")
  str = string.gsub(str, ",", "%%2C")
  str = string.gsub(str, "/", "%%2F")
  str = string.gsub(str, ":", "%%3A")
  str = string.gsub(str, ";", "%%3B")
  str = string.gsub(str, "=", "%%3D")
  str = string.gsub(str, "?", "%%3F")
  str = string.gsub(str, "@", "%%40")
  str = string.gsub(str, "[", "%%5B")
  str = string.gsub(str, "]", "%%5D")
  return str
end


local _is_daily_path = function(path)
  return path ~= nil and path:find('/' .. DAILY_NOTES_DIR .. '/', 1, true) ~= nil
end

local _ensure_workspace = function()
  if vim.fn.exists ':Obsidian' == 2 then
    vim.cmd 'Obsidian workspace personal'
  end
end

local _new_from_template = function(template_name, prompt)
  return function()
    _ensure_workspace()
    vim.ui.input({ prompt = prompt }, function(input)
      local title = _sanitize_note_id(input)
      if title == nil then
        return
      end
      require('obsidian.actions').new_from_template(title, template_name)
    end)
  end
end

local _touch_updated_field = function(bufnr)
  if not vim.b[bufnr].obsidian_buffer or not vim.bo[bufnr].modifiable then
    return
  end

  local max_lines = math.min(vim.api.nvim_buf_line_count(bufnr), 50)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, max_lines, false)
  if lines[1] ~= '---' then
    return
  end

  local boundary = nil
  for i = 2, #lines do
    if lines[i] == '---' then
      boundary = i
      break
    end
  end

  if boundary == nil then
    return
  end

  local updated_value = _is_daily_path(vim.api.nvim_buf_get_name(bufnr)) and os.date '%Y-%m-%d' or os.date '%Y-%m-%d %H:%M'
  local replacement = 'updated: ' .. updated_value

  for i = 2, boundary - 1 do
    if lines[i]:match '^updated:%s*' then
      if lines[i] ~= replacement then
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { replacement })
      end
      return
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, boundary - 1, boundary - 1, false, { replacement })
end

local _get_obsidian_opts = function()
  return {
    workspaces = {
      {
        name = 'personal',
        path = VAULT_PATH,
      },
    },

    legacy_commands = false,
    notes_subdir = ROUGH_NOTES_DIR,
    new_notes_location = 'notes_subdir',

    note = {
      template = 'new-note.md',
    },

    daily_notes = {
      folder = DAILY_NOTES_DIR,
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      template = 'daily-template.md',
      default_tags = {},
      workdays_only = false,
    },

    templates = {
      folder = TEMPLATES_DIR,
      date_format = 'YYYY-MM-DD',
      time_format = 'HH:mm',
      substitutions = {},
      customizations = {
        ['new-note'] = {
          notes_subdir = ROUGH_NOTES_DIR,
        },
        topic = {
          notes_subdir = TOPIC_PAGES_DIR,
        },
      },
    },

    link = {
      style = 'wiki',
      format = 'shortest',
    },

    completion = {
      min_chars = 2,
      create_new = true,
    },

    search = {
      sort_by = 'modified',
      sort_reversed = true,
      max_lines = 2000,
    },

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

    attachments = {
      folder = 'assets/imgs',
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format('![%s](%s)', path.name, path)
      end,
    },

    frontmatter = {
      enabled = true,
      sort = { 'id', 'aliases', 'tags', 'created', 'updated' },
      func = function(note)
        local metadata = vim.tbl_extend('force', note.metadata or {}, {
          id = note.id,
          aliases = note.aliases or {},
          tags = note.tags or {},
        })

        local default_timestamp = note.title and note.title:match '^%d%d%d%d%-%d%d%-%d%d$' and os.date '%Y-%m-%d' or os.date '%Y-%m-%d %H:%M'

        metadata.aliases = metadata.aliases or {}
        metadata.tags = metadata.tags or {}
        metadata.created = metadata.created or default_timestamp
        metadata.updated = metadata.updated or default_timestamp

        return metadata
      end,
    },

    note_id_func = function(title)
      return _sanitize_note_id(title) or _fallback_note_id()
    end,
  }
end

local _smart_action = function()
  local obsidian = require 'obsidian'
  if obsidian.util.cursor_on_markdown_link(nil, nil, true) then
    return '<cmd>Obsidian follow_link<CR>'
  elseif obsidian.util.cursor_on_checkbox(nil, nil) then
    return '<cmd>Obsidian toggle_checkbox<CR>'
  else
    return '<CR>'
  end
end

local _setup_keymaps = function(bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { remap = false, buffer = bufnr, desc = desc })
  end

  map('n', 'gf', '<cmd>Obsidian follow_link<CR>', 'Obsidian: Follow Link')
  map('n', 'gd', '<cmd>Obsidian follow_link<CR>', 'Obsidian: Follow Link')
  map('n', '<CR>', _smart_action, 'Obsidian: Smart Action')
  map('n', '<leader>ob', '<cmd>Obsidian backlinks<CR>', 'Obsidian: Show Backlinks')
  map('v', '<leader>ol', '<cmd>Obsidian link<CR>', 'Obsidian: Link Selection')
  map('n', '<leader>oc', '<cmd>Obsidian toggle_checkbox<CR>', 'Obsidian: Toggle Checkbox')
  map('n', '<leader>op', '<cmd>Obsidian paste_img<CR>', 'Obsidian: Paste Image')
end

local _setup_buffer = function(bufnr)
  vim.opt_local.conceallevel = 2
  vim.opt_local.wrap = true
  vim.bo[bufnr].textwidth = 0
end

local _setup_autocmds = function()
  local group = vim.api.nvim_create_augroup(OBSIDIAN_GROUP, { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'markdown',
    callback = function(args)
      if not vim.b[args.buf].obsidian_buffer then
        return
      end
      _setup_keymaps(args.buf)
      _setup_buffer(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    pattern = '*.md',
    callback = function(args)
      _touch_updated_field(args.buf)
    end,
  })
end

local _init_obsidian = function(_, opts)
  local obsidian = require 'obsidian'
  obsidian.setup(opts)
  _setup_autocmds()
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  lazy = true,
  keys = {
    {
      '<leader>on',
      _new_from_template('new-note.md', 'New note title: '),
      desc = 'Obsidian: New Rough Note',
    },
    {
      '<leader>og',
      _new_from_template('topic.md', 'New topic title: '),
      desc = 'Obsidian: New Topic Page',
    },
    { '<leader>oo', function()
      local file_path = vim.fn.expand('%:p')
      local vault_name = 'MyNotes'
      local url_encoded_file_path = _url_encode(file_path)
      local obsidian_url = string.format('obsidian://open?vault=%s&file=%s', vault_name, url_encoded_file_path)
      vim.fn.system({'open', obsidian_url}) -- macOS specific command
      print('Opening in Obsidian: ' .. obsidian_url)
    end, desc = 'Obsidian: Open current file' },
    { '<leader>od', '<cmd>Obsidian today<CR>', desc = 'Obsidian: Daily Note' },
    { '<leader>oy', '<cmd>Obsidian yesterday<CR>', desc = 'Obsidian: Yesterday Note' },
    { '<leader>ot', '<cmd>Obsidian template<CR>', desc = 'Obsidian: Insert Template' },
    { '<leader>os', '<cmd>Obsidian search<CR>', desc = 'Obsidian: Search' },
    { '<leader>of', '<cmd>Obsidian quick_switch<CR>', desc = 'Obsidian: Find File' },
  },
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = _get_obsidian_opts(),
  config = _init_obsidian,
}
