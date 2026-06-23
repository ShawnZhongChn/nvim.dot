--- @module custom.lang.markdown
--- Markdown workflow profile boundary.

local M = {}

function M.profile()
  return {
    name = 'markdown',
    filetypes = { 'markdown' },
    lsp_servers = { 'marksman' },
    formatter_policy = 'prettierd-or-prettier',
    linter_policy = 'markdownlint-cli2',
    test_adapters = {},
    debug_adapters = {},
    keymaps = {},
    notes = { 'Separates project Markdown from Obsidian vault behavior.' },
  }
end

function M.setup(bufnr)
  bufnr = bufnr or 0
  if not vim.b[bufnr].obsidian_buffer then
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.bo[bufnr].textwidth = 0
  end
end

function M.is_vault_buffer(bufnr)
  return vim.b[bufnr].obsidian_buffer == true
end

return M
