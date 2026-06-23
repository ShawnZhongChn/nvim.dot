local keys = require 'custom.keymaps'

keys.register_many {
  { mode = 'n', lhs = '<Esc>', rhs = '<cmd>nohlsearch<CR>' },
  { mode = 'n', lhs = '<leader>q', rhs = vim.diagnostic.setloclist, desc = 'Open diagnostic [Q]uickfix list' },
  { mode = 'n', lhs = '<leader>li', rhs = '<cmd>LspInfo<CR>', desc = 'LSP: Info' },
  { mode = 'n', lhs = '<leader>ll', rhs = '<cmd>LspLog<CR>', desc = 'LSP: Open Log' },
  { mode = 'n', lhs = '<leader>lr', rhs = '<cmd>LspRestart<CR>', desc = 'LSP: Restart' },
  { mode = 't', lhs = '<Esc><Esc>', rhs = '<C-\\><C-n>', desc = 'Exit terminal mode' },
  { mode = 'n', lhs = '<C-h>', rhs = '<C-w><C-h>', desc = 'Move focus to the left window' },
  { mode = 'n', lhs = '<C-l>', rhs = '<C-w><C-l>', desc = 'Move focus to the right window' },
  { mode = 'n', lhs = '<C-j>', rhs = '<C-w><C-j>', desc = 'Move focus to the lower window' },
  { mode = 'n', lhs = '<C-k>', rhs = '<C-w><C-k>', desc = 'Move focus to the upper window' },
}

