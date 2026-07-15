---
doc_type: feature-design-review
feature: 2026-07-15-upgrade-blink-cmp
status: passed
reviewed: 2026-07-15
round: 7
---

# upgrade-blink-cmp feature design 审查报告

## 1. Scope And Inputs

- Design: `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-design.md`
- Checklist: `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-checklist.yaml`
- Intent / brainstorm: none
- Roadmap: none
- Related docs: `.codestable/attention.md`；无 requirement、architecture 或 compound 约束
- Code facts checked: `lazy-lock.json`、`lua/shawnvim/plugins/extras/coding/blink.lua`、启动通知修复记录、Neovim/blink 官方版本事实

### Independent Review

- Status: completed
- Detection: native-agent
- Provider / agent: `/root/blink_upgrade_design_review_alt`
- Raw output: round 7 focused closure verdict 为 passed；单版本目标路径 `~/.local/opt/nvim` 在 design/checklist/CMD-000 中一致
- Merge policy: round 5 finding 已逐条修复；用户确认后的无版本号目标路径变更也由独立 reviewer 复核，无 blocking
- Gate effect: none；等待用户对 design 整体确认

## 2. Design Summary

- Goal: 先把 Neovim 切到官方 `v0.12.4` 并删除旧 apt/历史目录，再将 blink.cmp 固定升级到 `v1.10.2` peeled commit `78336bc…`。
- Key contracts: S1 的 CMD-005 前置冷启动门禁；CMD-000 单版本/realpath/PATH/apt 验收；target/rollback 双隔离 XDG；唯一 lock key 与 stable spec pin；acceptance 最后才清理临时运行时。
- Steps: 8；宿主验证与删除、旧 blink 基线、pin/lock、兼容、smoke、health/source、I1-I7 交互、rollback/交接。
- Checks: 15；覆盖宿主、版本范围、pin、matcher、sources、cmdline、snippet、lazydev、rollback 和最终清洁度。
- Baseline / validation: YAML、6 条命令 shell 语法和 `git diff --check` 已通过；运行证据留给 implementation/QA/acceptance。

## 3. Findings

### blocking

none

### important

none

### nit

- CMD-000 使用内存中的 tar listing，避免留下临时 `.list`；原子 symlink 切换前后 realpath 需在 implementation manifest 记录。

### suggestion

- 在最终 acceptance absence assertion 中同时记录 target/rollback XDG 与 tarball 的清理路径，便于审计。

### learning

- Neovim `checkhealth` 输出是特殊 `buftype` buffer，必须通过 API 读取 lines + `writefile()`，不能直接 `:write`。
- 删除 apt 后不再承诺回到历史 dev 包；本 feature 的宿主回退边界是重新安装同一官方 `v0.12.4`，blink 则可通过旧 lock 独立回退。

### praise

- 用户要求的 Neovim-first 顺序、旧版本删除和“不并行保留”已经在 flow、S1-S3、CMD-000/CMD-005 中形成一致契约。
- `version = "1.10.2"`、唯一 lock key、实际 checkout 与 Rust matcher 正向断言组合后，目标版本具备确定性。
- target/rollback XDG 生命周期已从 implementation S8 清理动作中解耦，保留至 acceptance 最后复验。

## 4. User Review Focus

- 用户需要重点拍板：接受旧 apt/历史目录在 S1 验证通过后删除；接受 apt 删除后只对 blink 做 lock 回退、宿主以同一官方 tarball 重装；接受 Neovim 0.11.2 未实机覆盖的 residual risk。
- implement 需要重点遵守：CMD-005 先于 apt removal，隔离 state/cache 且不 sync/install；保存官方 checksum provenance；CMD-000 在删除后确认唯一 canonical binary；S8 不清理 target/rollback。
- code review / QA / acceptance 需要重点复核：原始启动与 messages 输出、实际 checkout/Rust health、I1-I7、rollback manifest，以及最后的临时路径 absence assertions。

## 5. Evidence Confidence Ledger

| Check | Verdict | Evidence Class | Basis | Follow-up |
|---|---|---|---|---|
| Lifecycle 顺序 | pass | E+C | flow、S1-S3、CMD-005/CMD-000 明确先验证后删除再升级 | implementation 保存有序时间线 |
| Single-version Nvim | pass | E+C | checksum、架构、Release、realpath、PATH 去重、apt absence、旧目录排除目标 | implementation 实机执行 |
| XDG 生命周期 | pass | E | target/rollback 保留至 acceptance，S8 不清理 | acceptance 最后清理并断言 |
| Health evidence | pass | E+C | 特殊 buffer API 捕获、旧文件删除、xpcall/cquit、非空与文案断言 | implementation 运行 CMD-004 |
| Lock/spec pin | pass | E+C | CMD-003 同时断言 lock peeled commit 与 `version = ... "1.10.2"` | implementation 更新并运行 |
| Acceptance matrix | pass | E | S1/S3/S5-S8 映射与 15 checks 对齐 | QA/acceptance 执行 |
| Checksum provenance | residual-risk | H | URL/digest 已写入 design，官方性需联网复核 | implementation evidence |
| Neovim 0.11.2 | residual-risk | H | 本 feature 明确不覆盖最低版本实机 | owner review |

## 6. Verdict

- Status: passed
- Next: 用户确认 design 后，将 design 标为 `approved` 并提交 spec，再创建 linked worktree；在此之前不下载、删除或升级任何 Neovim/插件。
