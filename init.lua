-- bootstrap lazy.nvim, LazyVim and your plugins

-- Save when leaving insert mode or when text is changed
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    if vim.bo.modified and vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
      vim.cmd("silent! write")
    end
  end,
})

require("config.lazy")
