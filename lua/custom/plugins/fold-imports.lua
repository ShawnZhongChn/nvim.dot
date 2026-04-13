--- @Note: fold-imports.nvim
--- Neovim plugin to automatically fold imports in any language using treesitter
--- @url: https://github.com/dmtrKovalenko/fold-imports.nvim

return {
  'dmtrKovalenko/fold-imports.nvim',
  event = 'BufReadPost',
  opts = {
    auto_fold = true,
    fold_level = 99,
    auto_fold_after_code_action = false,
    max_import_lines = 100,
  },
  config = function(_, opts)
    require('fold_imports').setup(opts)
    -- fold-imports 强制设置 foldmethod=manual，折叠完后让 ufo 重新接管
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufWinEnter', 'FileType' }, {
      group = vim.api.nvim_create_augroup('FoldImportsUfoRestore', { clear = true }),
      callback = function()
        vim.defer_fn(function()
          local ok, ufo = pcall(require, 'ufo')
          if ok then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
            ufo.attach()
          end
        end, 100)
      end,
    })
  end,
}
