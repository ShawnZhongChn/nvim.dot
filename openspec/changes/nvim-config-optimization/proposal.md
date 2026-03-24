# nvim-config-optimization

## Summary

优化 Neovim 配置，修复 bug、提升性能、完善功能。

## Motivation

经过代码审查发现当前配置存在以下问题：

### Bug 修复
- **Nerd Font 检测错误**: `have_nerd_font` 硬编码为 `false`
- **Noice `<leader>ny` 功能失效**: 获取 yank 内容而非消息历史
- **README 文档过时**: 仍描述 Oil.nvim，实际已改用 yazi

### 体验升级
- **Blink.cmp 未启用**: 已配置但被禁用，仍用旧 nvim-cmp
- **Git Hunk keymaps 缺失**: which-key 有 group 但 gitsigns 无实际映射
- **LSP Log 入口缺失**: 调试 LSP 无快捷方式
- **Obsidian CWD 副作用**: 切换 vault 时改全局 CWD 影响其他插件

### 增强功能
- **Python Folding bug**: `foldclose` 对 treesitter folds 无效
- **LSP attach.lua 冗余**: 0.11 兼容性检测代码可清理
- **undofile 全局开启**: 建议区分项目与临时文件
- **Terminal 单次 ESC 未映射**

## Non-goals

- 不改变整体架构
- 不新增大型插件
- 不修改主题/配色方案

## Proposal

### Phase 1: Bug 修复 (不影响现有功能)

| Task | Description | Files |
|------|-------------|-------|
| T1 | Nerd Font 自动检测 | `lua/core/keymaps.lua` |
| T2 | Noice `<leader>ny` 修复 | `lua/custom/plugins/noice.lua` |
| T3 | README 更新 (Oil → Yazi) | `README.md` |

### Phase 2: 体验升级

| Task | Description | Files |
|------|-------------|-------|
| T4 | Blink.cmp 迁移 | 删除 `nvim-cmp.lua`，启用 `blink-cmp.lua` |
| T5 | Git Hunk keymaps | `lua/custom/plugins/gitsigns.lua` |
| T6 | LSP Log 快捷键 | `lua/core/keymaps.lua` |
| T7 | Obsidian CWD 修复 | `lua/custom/plugins/obsidian.lua` |

### Phase 3: 增强功能

| Task | Description | Files |
|------|-------------|-------|
| T8 | Python Folding 修复 | `lua/custom/lsp/attach.lua` |
| T9 | LSP attach.lua 清理 | `lua/custom/lsp/attach.lua` |
| T10 | Trouble.nvim 集成 | `lua/custom/plugins/` |

## Success Metrics

- `:checkhealth` 无警告
- 启动时间 < 100ms (使用 `nvim --startuptime`)
- Blink.cmp fuzzy 排序质量不低于原有 nvim-cmp
