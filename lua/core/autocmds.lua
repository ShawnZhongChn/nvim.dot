-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local fold_view_group = vim.api.nvim_create_augroup('preserve-fold-view', { clear = true })

vim.api.nvim_create_autocmd('InsertLeavePre', {
  desc = 'Save window view before leaving Insert mode so folds keep their current state',
  group = fold_view_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then
      return
    end
    vim.w.saved_fold_view = {
      view = vim.fn.winsaveview(),
      winid = vim.api.nvim_get_current_win(),
    }
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Restore window view after leaving Insert mode to preserve fold state',
  group = fold_view_group,
  callback = function(args)
    local saved = vim.w.saved_fold_view
    if not saved or vim.bo[args.buf].buftype ~= '' then
      return
    end

    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_win_is_valid(saved.winid) then
        vim.api.nvim_win_call(saved.winid, function()
          pcall(vim.fn.winrestview, saved.view)
        end)
      end
      vim.w.saved_fold_view = nil
    end)
  end,
})
