--- @module custom.ui.explorer
--- Explorer UI boundary around Yazi.

local M = {}

function M.yazi_opts()
  return {
    floating_window_options = { border = 'rounded', relative = 'editor' },
    open_for_directories = true,
    set_keymaps = false,
    yazi_floating_window_winblend = 0,
    set_keymappings_function = function(buffer)
      vim.keymap.set('t', 'H', 'h', { buffer = buffer, remap = true })
      vim.keymap.set('t', 'L', 'l', { buffer = buffer, remap = true })
    end,
  }
end

function M.setup_yazi()
  require('yazi').setup(M.yazi_opts())
  vim.keymap.set('n', '-', '<cmd>Yazi<cr>', { desc = 'Yazi: Open at current file' })
  vim.keymap.set('n', '<space>-', '<cmd>Yazi toggle<cr>', { desc = 'Yazi: Toggle window' })
  vim.keymap.set('n', '<leader>fy', '<cmd>Yazi cwd<cr>', { desc = 'Yazi: Open at CWD' })
end

return M
