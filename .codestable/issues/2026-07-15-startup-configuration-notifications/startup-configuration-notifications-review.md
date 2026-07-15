---
doc_type: issue-review
issue: 2026-07-15-startup-configuration-notifications
status: passed
reviewer: subagent
reviewed: 2026-07-15
round: 1
---

# startup-configuration-notifications 代码审查报告

## 1. Scope And Inputs

- Fix note: `.codestable/issues/2026-07-15-startup-configuration-notifications/startup-configuration-notifications-fix-note.md`
- Evidence pack: none
- Gate results: start gate passed with owner-approved worktree override
- DoD results: none
- Implementation evidence: 本轮对话、全新 headless Neovim 启动输出与 blink.cmp 强制加载结果
- Diff basis: `git status --short`、两个运行时代码文件的 unstaged `git diff`；staged diff 为空
- Review mode: initial
- Baseline dirty files: `.codestable/` 是本轮 onboard 后尚未提交的工作流骨架；代码审查仅归因 `lua/config/lazy.lua` 与 `lua/shawnvim/plugins/extras/coding/blink.lua`

### Independent Review

- Detection: 原生 Codex Task agent 可用；OCR CLI 已安装但 LLM 端点不可连接
- 环节 A 独立隔离 Task agent: native-agent + completed
- 环节 B OCR CLI: failed（`127.0.0.1:18080` connection refused）
- OCR severity mapping: High→blocking/important，Medium→nit/suggestion，Low→discarded
- Merge policy: Task agent 结果已逐条用本地源码、运行时配置和验证输出核验后合并
- Gate effect: OCR 是可选增强，Task agent 已完成，故不阻塞最终 verdict

## 2. Diff Summary

- 新增：none（运行时代码）
- 修改：`lua/config/lazy.lua`、`lua/shawnvim/plugins/extras/coding/blink.lua`
- 删除：none
- 未跟踪 / staged：`.codestable/` 未跟踪；staged 为空
- 风险热点：插件导入顺序与命令行按键行为；无权限、数据、并发或公共 API 风险

## 3. Adversarial Pass

- 假设的生产 bug：移除根 lazy spec 的本地插件包装后 `ShawnVim` 未注册，或空命令数组仍吞掉 `<Left>/<Right>`。
- 主动攻击过的反例：检查 lazy.nvim 实际 modules 与插件注册结果；检查 blink.cmp v0.14.2 validator、preset 覆盖、apply 阶段零命令分支与合并后的运行时值；避免仅凭退出码判断。
- 结果：`shawnvim.plugins` 仍从 `lua/shawnvim/plugins/init.lua` 返回并注册本地 `ShawnVim`；空命令数组通过校验且 apply 阶段跳过映射。没有升级为 blocking/important 的发现。

## 4. Findings

### blocking

none

### important

none

### nit

none

### suggestion

- [ ] REV-001 在后续 QA/自动化中保留可复跑 smoke 命令与关键输出，减少修复记录只有结论、无法直接复验的成本；不要求修改本次生产代码。

### learning

- lazy.nvim 的 import 名与插件显示名属于不同语义层；根 spec 应保留可被顺序检查识别的 import 名。
- blink.cmp v0.14.2 的单键禁用值必须满足命令数组 schema，空数组同时表达“覆盖 preset 且不安装映射”。

### praise

- 改动严格限制在两个根因位置，并把 blink.cmp 升级明确留作独立任务。

## 5. Test And QA Focus

- QA 必须重点复核：冷启动等待 `VeryLazy` 后无 import-order、blink.cmp、`ipairs(boolean)` 通知；在 `:`、`/`、`?` 中确认 `<Left>/<Right>` 保持原生移动。
- Evidence pack residual risks / gate warnings：OCR 服务不可用已记录；不影响独立 Task agent gate。
- 建议新增或加强的测试：smoke test 断言 modules 首项为 `shawnvim.plugins`、`ShawnVim` 插件已注册、blink.cmp 可强制加载、cmdline 左右键无 blink 映射。
- 不能靠 review 完全确认的点：最低支持版本 Neovim 0.11.2 未在本机实跑；当前运行环境为 0.12.0-dev。

## 6. Residual Risk

- Neovim 0.11.2 的最低版本兼容性尚未实机验证；升级 blink.cmp 前应在 0.11.2 与当前环境各跑一次 smoke test。
- blink.cmp v1.10.2 升级不属于本轮范围，需独立更新 lockfile并回归测试。

## 7. Verdict

- Status: passed
- Next: 返回 `cs-issue` 完成修复闭环；不自动提交。随后可另开独立升级任务。

## 8. Focused Closure

none
