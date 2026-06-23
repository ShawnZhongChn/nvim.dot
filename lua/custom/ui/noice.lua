--- @module custom.ui.noice
--- Noice UI boundary.

local M = {}

function M.opts()
  return {
    notify = { enabled = true, view = 'mini' },
    cmdline = { enabled = true, view = 'cmdline_popup' },
    messages = { enabled = true, view = 'mini' },
    popupmenu = { enabled = true, view = 'popupmenu' },
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      hover = { enabled = true, silent = true },
      signature = { enabled = true },
    },
    views = {
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
    },
    routes = {
      { filter = { event = 'msg_show', find = 'written' }, opts = { skip = true } },
      { filter = { event = 'notify', find = 'Using a password on the command line interface can be insecure' }, opts = { skip = true } },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  }
end

function M.keys()
  return {
    { '<leader>nl', '<cmd>Noice last<CR>', desc = 'Noice: Show Last Message' },
    { '<leader>nh', '<cmd>Noice history<CR>', desc = 'Noice: Show History' },
    { '<leader>nd', '<cmd>Noice dismiss<CR>', desc = 'Noice: Dismiss All' },
    {
      '<leader>ny',
      function()
        local last = require('noice').last()
        if last and last.content then
          local text = type(last.content) == 'table' and table.concat(vim.tbl_flatten(last.content), '\n') or tostring(last.content)
          vim.fn.setreg('"', text)
          vim.notify('Last message yanked')
        else
          vim.notify('No message to yank', vim.log.levels.WARN)
        end
      end,
      desc = 'Noice: Yank Last Message',
    },
  }
end

function M.setup(opts)
  require('noice').setup(opts or M.opts())
end

return M
