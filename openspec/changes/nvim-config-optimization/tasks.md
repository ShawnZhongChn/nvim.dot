# nvim-config-optimization Tasks

## Phase 1: Bug 修复

### T1: Nerd Font 自动检测
**Status**: pending
**Time**: 5 min

- [ ] 编辑 `lua/core/keymaps.lua`
- [ ] 将 `vim.g.have_nerd_font = false` 改为自动检测逻辑
- [ ] 测试: 确认状态栏图标显示正确

### T2: Noice `<leader>ny` 修复
**Status**: pending
**Time**: 10 min

- [ ] 编辑 `lua/custom/plugins/noice.lua`
- [ ] 重写 `<leader>ny` 映射函数
- [ ] 使用 `require('noice').last()` 获取消息
- [ ] 测试: 触发一条消息，按 `<leader>ny>` 确认内容被复制

### T3: README 更新
**Status**: pending
**Time**: 5 min

- [ ] 编辑 `README.md`
- [ ] 将 "Oil.nvim" 相关描述改为 "yazi.nvim"
- [ ] 更新截图或截图链接 (如有)

---

## Phase 2: 体验升级

### T4: Blink.cmp 迁移
**Status**: pending
**Time**: 20 min

- [ ] 删除 `lua/custom/plugins/nvim-cmp.lua`
- [ ] 重命名 `blink-cmp.lua.disabled` → `blink-cmp.lua`
- [ ] 编辑 `blink-cmp.lua`，确保 opts_extend 配置正确
- [ ] 清理 lazy-lock.json 中的 nvim-cmp 相关插件
- [ ] 测试: 打开 Python 文件，验证 LSP 补全正常

### T5: Git Hunk Keymaps
**Status**: pending
**Time**: 10 min

- [ ] 编辑 `lua/custom/plugins/gitsigns.lua`
- [ ] 在 config 函数中添加 hs/hr/hp 映射
- [ ] 测试: 修改文件，验证 stage/reset/preview hunk 正常工作

### T6: LSP Log 快捷键
**Status**: pending
**Time**: 5 min

- [ ] 编辑 `lua/core/keymaps.lua`
- [ ] 添加 `<leader>ll` 和 `<leader>lr` 映射
- [ ] 测试: 按 `<leader>ll>` 确认打开 LspLog

### T7: Obsidian CWD 修复
**Status**: pending
**Time**: 10 min

- [ ] 编辑 `lua/custom/plugins/obsidian.lua`
- [ ] 检查 `<leader>on` 的 chdir 实现
- [ ] 确保使用 `vim.cmd.cd()` 而非 `vim.fn.chdir()`
- [ ] 测试: 打开 vault 外文件，按 `<leader>on>`，确认 CWD 只在 vault 内受影响

---

## Phase 3: 增强功能

### T8: nvim-ufo 集成
**Status**: pending
**Time**: 30 min

- [ ] 创建 `lua/custom/plugins/ufo.lua`
- [ ] 删除 `attach.lua` 中的 `_fold_python_docstrings` 函数
- [ ] 删除 `attach.lua` 中的 `FoldDocstrings` 命令注册
- [ ] 删除 `attach.lua` 中的 `<leader>zp` 映射
- [ ] 更新 which-key spec，移除 `<leader>zp` 提示
- [ ] 测试: 打开 Python 文件，验证折叠功能正常

### T9: LSP attach.lua 清理
**Status**: pending
**Time**: 10 min

- [ ] 编辑 `lua/custom/lsp/attach.lua`
- [ ] 删除 `_client_supports_method` 函数
- [ ] 简化所有 `client:supports_method()` 调用
- [ ] 确保 Neovim 0.10 兼容性
- [ ] 测试: LSP Attach 时无错误

### T10: Trouble.nvim 集成
**Status**: pending
**Time**: 20 min

- [ ] 创建 `lua/custom/plugins/trouble.lua`
- [ ] 配置 document/project diagnostics 快捷键
- [ ] 集成到 which-key spec
- [ ] 测试: 打开有诊断的文件，验证 Trouble 视图正常

---

## Verification

完成所有 tasks 后执行:

```bash
# 1. 检查健康状态
nvim --checkhealth

# 2. 测试启动时间
nvim --startuptime /tmp/startup.log +q
cat /tmp/startup.log | head -20

# 3. 验证 Blink.cmp
nvim test.py
# 输入 "import " 确认 LSP 补全弹出
```
