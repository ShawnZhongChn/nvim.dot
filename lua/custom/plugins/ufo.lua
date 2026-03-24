--- @Note: nvim-ufo 配置
--- 提供强大的 treesitter 折叠功能
--- @url: https://github.com/kevinhwang91/nvim-ufo

return {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  event = 'BufRead',
  keys = {
    { 'zc', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
    { 'zo', function() require('ufo').openFoldsExceptKinds() end, desc = 'Open folds' },
    { 'za', function() require('ufo').toggleFold() end, desc = 'Toggle fold' },
    { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
    { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
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
