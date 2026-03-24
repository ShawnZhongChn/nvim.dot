# nvim-config-optimization Design

## T1: Nerd Font 自动检测

**问题**: `vim.g.have_nerd_font = false` 硬编码导致图标无法显示

**方案**:

```lua
-- lua/core/keymaps.lua
-- 删除硬编码，改为自动检测
vim.g.have_nerd_font = (
  vim.fn.has('gui_running') == 1
  or vim.env.TERM_PROGRAM == 'Apple_Terminal'
  or vim.env.TERM_PROGRAM == 'iTerm.app'
  or vim.fn.executable('nvim-qt') == 1
  or (vim.env.TERM ~= nil and vim.env.TERM:match('nerd'))
)
```

---

## T2: Noice `<leader>ny` 修复

**问题**: 当前实现用 `vim.fn.getreg '"'` 获取 yank 内容，而非 noice 消息

**方案**:

```lua
-- lua/custom/plugins/noice.lua
map('n', '<leader>ny', function()
  local last = require('noice').last()
  if last and last.content then
    local text = type(last.content) == 'table'
      and table.concat(vim.tbl_flatten(last.content), '\n')
      or tostring(last.content)
    vim.fn.setreg('"', text)
    vim.notify('Last message yanked')
  else
    vim.notify('No message to yank', vim.log.levels.WARN)
  end
end, { desc = 'Noice: Yank Last Message' })
```

---

## T3: README Oil → Yazi

**问题**: README 描述 `Oil.nvim` 但已改用 `yazi.nvim`

**方案**: 更新 README.md 中相关描述

---

## T4: Blink.cmp 迁移

**问题**: blink-cmp.lua.disabled 已配置好但未启用，nvim-cmp 仍在使用

**方案**:

1. 删除 `lua/custom/plugins/nvim-cmp.lua`
2. 重命名 `blink-cmp.lua.disabled` → `blink-cmp.lua`
3. 移除 nvim-cmp 相关依赖 (cmp-nvim-lsp, cmp-path, cmp-buffer, cmp-cmdline, cmp-look, cmp-spell, cmp_luasnip)

**Blink.cmp 配置** (已有，保持不变):

```lua
return {
  'saghen/blink.cmp',
  version = 'v0.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      build = vim.fn.executable 'make' == 1 and 'make install_jsregexp' or nil,
    },
    'folke/lazydev.nvim',
  },
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      ghost_text = { enabled = false },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    snippets = { preset = 'luasnip' },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.default' },
}
```

**注意**: Markdown 字典补全 (cmp-look) 和拼写补全 (cmp-spell) 将被放弃，拼写检查依赖 Neovim 原生 `spell` 功能。

---

## T5: Git Hunk Keymaps

**问题**: which-key 定义了 `<leader>h` group 但 gitsigns 无实际映射

**方案**: 在 `lua/custom/plugins/gitsigns.lua` 添加:

```lua
-- 在 config 函数中添加
vim.keymap.set('n', '<leader>hs', require('gitsigns').stage_hunk, { desc = 'Stage hunk' })
vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk, { desc = 'Reset hunk' })
vim.keymap.set('v', '<leader>hs', function()
  require('gitsigns').stage_hunk { vim.fn.line '.' , vim.fn.line 'v' }
end, { desc = 'Stage hunk' })
vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { desc = 'Preview hunk' })
```

---

## T6: LSP Log 快捷键

**问题**: 调试 LSP 时缺少快速入口

**方案**: 在 `lua/core/keymaps.lua` 添加:

```lua
vim.keymap.set('n', '<leader>ll', '<cmd>LspLog<CR>', { desc = 'LSP: Open Log' })
vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = 'LSP: Restart' })
```

---

## T7: Obsidian CWD 修复

**问题**: `<leader>on` 使用 `vim.fn.chdir()` 改变全局 CWD

**方案**: 使用 `vim.cmd.cd()` 配合 `noautocmd` 减少副作用:

```lua
-- obsidian.lua
vim.cmd.cd(vault_path)  -- 已足够，vim.cmd 自带 noautocmd 效果
```

或在 `<leader>on` 实现中:

```lua
vim.cmd('cd ' .. vim.fn.fnameescape(vault_path))
```

---

## T8: nvim-ufo 集成 (替代 Python Folding)

**问题**: `_fold_python_docstrings` 使用 `vim.cmd.foldclose` 对 treesitter folds 无效

**方案**: 使用 nvim-ufo 替代当前有问题的实现，提供更强大的折叠控制:

### 1. 新增 ufo.lua 插件配置

```lua
-- lua/custom/plugins/ufo.lua
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
    provider_selector = function(bufnr, filetype, _)
      -- Python 使用 treesitter + indent 混合
      if filetype == 'python' then
        return { 'treesitter', 'indent' }
      end
      return { 'treesitter' }
    end,
  },
}
```

### 2. 删除 attach.lua 中的旧实现

删除:
- `_fold_python_docstrings` 函数
- `vim.api.nvim_buf_create_user_command(event.buf, 'FoldDocstrings', ...)`
- `map('zp', '<cmd>FoldDocstrings<CR>', ...)`

### 3. 更新 which-key spec

移除 `<leader>zp` 相关提示

**优点**: nvim-ufo 提供精确的 treesitter 折叠控制，支持 preview，功能强大
**依赖**: promise-async

---

## T9: LSP attach.lua 清理

**问题**: 0.11 兼容性检测代码冗余

**方案**: 删除 `_client_supports_method` 函数，简化调用:

```lua
-- 原来:
if _client_supports_method(client, method, event.buf) then

-- 改为 (Neovim 0.10+):
if client:supports_method(method, event.buf) then
```

---

## T10: Trouble.nvim 集成 (Optional)

**问题**: 诊断多时 loclist 体验不佳

**方案**: 添加 Trouble.nvim:

```lua
-- lua/custom/plugins/trouble.lua
return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    { '<leader>cdd', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Document Diagnostics' },
    { '<leader>cdp', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Project Diagnostics' },
    { '<leader>cq', '<cmd>Trouble qflist toggle<CR>', desc = 'Quickfix List' },
  },
  opts = { use_diagnostics = true },
}
```

---

## Dependencies

- T4 (Blink.cmp) 需要先完成才能测试
- T10 依赖 Telescope (已有)
