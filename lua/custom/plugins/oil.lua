return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      CustomOilBar = function()
        local path = vim.fn.expand('%'):gsub('oil://', '')
        if path == '' then
          return '  󰇚 Root'
        end
        return '   ' .. vim.fn.fnamemodify(path, ':.')
      end

      require('oil').setup {
        columns = {
          { 'icon', add_padding = false },
        },
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['<CR>'] = 'actions.select',
          ['<C-v>'] = 'actions.select_vsplit',
          ['q'] = 'actions.close',
          ['L'] = 'actions.select',
          ['H'] = 'actions.parent',
          ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
          ['gs'] = 'actions.change_sort',
          ['<C-p>'] = 'actions.preview',
        },
        win_options = {
          winbar = '%{v:lua.CustomOilBar()}',
          signcolumn = 'yes:1',
        },
        preview = {
          update_on_cursor_moved = true,
          max_width = 0.45,
          border = 'rounded',
          win_options = { winblend = 0 },
        },
        view_options = {
          show_hidden = false,
          is_always_hidden = function(name, _)
            local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build', '.git', '__pycache__' }
            return vim.tbl_contains(folder_skip, name)
          end,
          highlight_filename = function(is_hidden, _, _)
            if is_hidden then
              return 'Comment'
            end
          end,
        },
        lsp_file_methods = {
          enabled = true,
          autosave_changes = 'unmodified',
        },
        float = {
          border = 'rounded',
          win_options = { winblend = 5 },
        },
      }

      -- 【关键修复】使用 OilEnter 事件确保在数据就绪后瞬发打开预览
      vim.api.nvim_create_autocmd('User', {
        pattern = 'OilEnter',
        callback = function()
          local oil = require 'oil'
          -- schedule 确保在当前渲染周期结束后立即执行，避开 ID 映射冲突
          vim.schedule(function()
            -- 增加安全判断，确保当前确实是在有效 entry 上
            if vim.bo.filetype == 'oil' and oil.get_cursor_entry() then
              oil.open_preview()
            end
          end)
        end,
      })

      vim.keymap.set('n', '<space>-', function()
        require('oil').toggle_float()
      end, { desc = 'Oil Float' })
    end,
  },
}
