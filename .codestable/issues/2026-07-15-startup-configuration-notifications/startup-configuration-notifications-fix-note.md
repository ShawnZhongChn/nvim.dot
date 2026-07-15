---
doc_type: issue-fix
issue: 2026-07-15-startup-configuration-notifications
path: fast-track
fix_date: 2026-07-15
tags: [neovim, lazy-nvim, blink-cmp]
---

# Neovim 启动配置通知修复记录

## 1. 问题描述

启动后的 Notifications 出现两类配置异常：ShawnVim 报告 lazy.nvim imports 顺序不正确；blink.cmp 初始化失败并报告 `ipairs` 收到 boolean。

## 2. 根因

- `lua/config/lazy.lua` 把 `shawnvim.plugins` import 与名为 `ShawnVim` 的本地插件声明合并在同一个 spec 中，lazy.nvim 因而把模块记录为 `ShawnVim`，无法满足顺序检查对 `shawnvim.plugins` 的精确匹配。
- `lua/shawnvim/plugins/extras/coding/blink.lua` 在 cmdline keymap 中用 `false` 禁用 `<Right>` 和 `<Left>`。当前锁定的 blink.cmp v0.14.2 将按键值校验为命令数组并对其执行 `ipairs`，boolean 会触发初始化错误。

## 3. 修复方案

- 根配置只保留 `{ import = "shawnvim.plugins" }`；本地 `ShawnVim` 插件继续由 `lua/shawnvim/plugins/init.lua` 注册。
- 按 blink.cmp v0.14.2 官方源码示例，将两个禁用按键的值改为空命令数组 `{}`。该写法也兼容当前官方稳定版。

## 4. 改动文件清单

- `lua/config/lazy.lua`
- `lua/shawnvim/plugins/extras/coding/blink.lua`

流程证据文件位于本 issue 目录；未修改其他运行时代码。

## 5. 验证结果

- 全新 headless Neovim 实例中的模块顺序为 `shawnvim.plugins` → `shawnvim.plugins.extras.*` → `plugins`。
- 强制加载 blink.cmp 后 `blink_loaded=true`，进程正常退出。
- 新实例的相关 Notifications 为空：未出现 import order、blink.cmp 或 `ipairs` 错误。
- `git diff --check` 通过。
- `stylua --check` 未执行：系统 PATH 与 Mason bin 均未安装 stylua；本次改动保持现有 Lua 格式。

## 6. 遗留事项

- blink.cmp v0.14.2 → 当前稳定版的升级作为独立任务处理，不混入本次定点修复。
- `9 lines yanked` 是普通通知；`E382: Cannot write, 'buftype' option is set` 是当次特殊 buffer 写入操作错误，目前没有证据指向持久配置缺陷，均不在本次修复范围。
