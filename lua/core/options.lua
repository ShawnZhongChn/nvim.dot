-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Auto-detect Nerd Font based on terminal/emulator
vim.g.have_nerd_font = (
  vim.fn.has 'gui_running' == 1
  or vim.env.TERM_PROGRAM == 'Apple_Terminal'
  or vim.env.TERM_PROGRAM == 'iTerm.app'
  or vim.fn.executable 'nvim-qt' == 1
  or (vim.env.TERM and vim.env.TERM:match 'nerd')
)

-- [[ Setting options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- [[ Folding Configuration ]]
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

_G.custom_fold_text = function()
  return vim.fn.getline(vim.v.foldstart) .. ' ⋯ '
end
vim.opt.foldtext = 'v:lua.custom_fold_text()'

vim.opt.fillchars = {
  eob = ' ',
  fold = ' ',
  foldopen = ' ',
  foldsep = ' ',
  foldclose = ' ',
}

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 30
vim.o.confirm = true
