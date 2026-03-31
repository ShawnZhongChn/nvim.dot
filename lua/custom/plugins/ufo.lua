--- @Note: nvim-ufo 配置
--- 提供强大的 treesitter 折叠功能
--- @url: https://github.com/kevinhwang91/nvim-ufo

return {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  event = 'BufRead',
  keys = {
    { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
    { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
    { 'zr', function() require('ufo').openFoldsExceptKinds() end, desc = 'Open folds except kinds' },
    { 'zm', function() require('ufo').closeFoldsWith() end, desc = 'Close folds by level' },
  },
  opts = {
    provider_selector = function(_, filetype, _)
      if filetype == 'python' then
        return { 'treesitter', 'indent' }
      end
      return { 'treesitter' }
    end,
  },
}
