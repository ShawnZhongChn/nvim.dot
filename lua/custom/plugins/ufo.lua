--- @Note: nvim-ufo 深度增强版
--- 1. 支持 LSP, Treesitter 和 Indent 多重驱动回退。
--- 2. 彻底移除 "--- 14 lines" 这种丑陋的显示，采用极简现代风格。

return {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  event = 'BufReadPost', -- 稍微提前加载，确保在文件打开时即生效
  keys = {
    { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
    { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
  },
  opts = {
    -- 驱动选择器：优先 LSP，其次 Treesitter，最后 Indent
    provider_selector = function(bufnr, filetype, buftype)
      return { 'lsp', 'indent' }
    end,

    -- 显式设置：不自动关闭任何类型的折叠，防止模式切换时重新计算导致的意外关闭
    close_fold_kinds_for_ft = {
      default = {},
    },

    -- 自定义折叠虚拟文本显示
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      if #virtText == 0 then
        local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
        virtText = { { line, 'Normal' } }
      end
      local newVirtText = {}
      local suffix = ' ⋯ ' -- 使用一个更简洁的符号表示折叠
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0

      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          -- strdisplaywidth(chunkText) 可能会大于截断后的宽度
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, 'UfoFoldedEllipsis' })
      return newVirtText
    end,
  },
  config = function(_, opts)
    -- 注意：ufo 需要手动开启 foldcolumn 如果需要的话，但我们保持 0 以维持极简
    require('ufo').setup(opts)
  end,
}
