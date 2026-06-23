--- @module custom.ui.picker
--- Picker/search UI boundary around Telescope.

local M = {}

local function _on_project_open(selection)
  local modified_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_get_option_value('modified', { buf = buf }) then
      table.insert(modified_buffers, vim.api.nvim_buf_get_name(buf))
    end
  end

  if #modified_buffers > 0 then
    vim.notify('Abort: You have unsaved changes!', vim.log.levels.ERROR)
    return
  end

  vim.cmd.cd(selection.path)
  vim.cmd 'silent! %bd!'
  vim.notify('Project loaded: ' .. selection.path, vim.log.levels.INFO)
end

function M.opts()
  return {
    defaults = {},
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
      zoxide = {
        prompt_title = '[ Project Switcher ]',
        mappings = { ['<CR>'] = { keepinsert = true, action = _on_project_open } },
      },
    },
  }
end

function M.keys(builtin)
  return {
    { '<leader>sh', builtin.help_tags, desc = '[S]earch [H]elp' },
    { '<leader>sk', builtin.keymaps, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', builtin.find_files, desc = '[S]earch [F]iles' },
    { '<leader>ss', builtin.builtin, desc = '[S]earch [S]elect Telescope' },
    { '<leader>sw', builtin.grep_string, desc = '[S]earch current [W]ord' },
    { '<leader>sg', builtin.live_grep, desc = '[S]earch by [G]rep' },
    { '<leader>sd', builtin.diagnostics, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', builtin.resume, desc = '[S]earch [R]esume' },
    { '<leader>s.', builtin.oldfiles, desc = '[S]earch Recent Files' },
    { '<leader><leader>', builtin.buffers, desc = 'Find existing buffers' },
    { '<leader>sz', function() require('telescope').extensions.zoxide.list() end, desc = '[S]earch [Z]oxide Projects' },
    { '<leader>/', function() builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false }) end, desc = 'Fuzzily search in current buffer' },
    { '<leader>s/', function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end, desc = '[S]earch in Open Files' },
    { '<leader>sc', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch Config files' },
  }
end

function M.setup()
  local telescope = require 'telescope'
  local builtin = require 'telescope.builtin'
  telescope.setup(M.opts())
  pcall(telescope.load_extension, 'fzf')
  pcall(telescope.load_extension, 'ui-select')
  pcall(telescope.load_extension, 'zoxide')
  for _, spec in ipairs(M.keys(builtin)) do
    vim.keymap.set('n', spec[1], spec[2], { desc = spec.desc })
  end
end

return M
