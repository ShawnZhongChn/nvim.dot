---
doc_type: feature-design-review
feature: 2026-07-16-dashboard-logo-selector
status: passed
reviewed: 2026-07-16
round: 2
---

# dashboard-logo-selector feature design 审查报告

## 1. Scope And Inputs

- Design: `.codestable/features/2026-07-16-dashboard-logo-selector/dashboard-logo-selector-design.md`
- Checklist: `.codestable/features/2026-07-16-dashboard-logo-selector/dashboard-logo-selector-checklist.yaml`
- Brainstorm: `.codestable/features/2026-07-16-dashboard-logo-selector/dashboard-logo-selector-brainstorm.md`
- Roadmap / requirement: none
- Related docs: `.codestable/architecture/system-shawnvim-runtime.md`；compound 无相关记录
- Code facts checked: 四类 starter 配置、UI keymap、JSON 生命周期、Snacks picker/dashboard、mini.starter refresh、Mason Stylua 与 Git porcelain 行为

### Independent Review

- Status: completed
- Detection: native-agent
- Provider / agent: general-purpose agent `a5719a66894e9e3f6`
- Raw output: 多轮独立只读复核逐项发现并验证事务、隔离、baseline 生命周期、exclusive-create 和 file-level porcelain 问题；最终 verdict=`passed`
- Merge policy: 每条 finding 均由主 agent 用 design/checklist、项目源码、锁定插件源码或实际命令行为核验，修订后由同一 reviewer 复核
- Gate effect: none

## 2. Design Summary

- Goal: `<leader>uo` 打开两款已确认霓虹 Logo 的完整预览选择器，确认后原子持久化并刷新当前 Dashboard。
- Key contracts: 两款精确六行 Header（宽度 58）；共享 provider；`save(candidate?)` 双层兼容事务；scheduled User event；四类 starter adapter postcondition。
- Steps: S0-S7，按 scope baseline → registry → transaction → initial source → picker → installed adapters → optional adapters → UI/cleanliness 推进。
- Checks: 覆盖名词、编排、挂载点、范围、十个验收场景和固定 implementation baseline。
- Baseline / validation: CMD-000 exclusive-create 文件级 NUL-safe baseline；CMD-001 至 CMD-008 统一经隔离 matrix wrapper；Mason Stylua 2.5.2，既有 blink 格式红灯已归因并排除。

## 3. Findings

### blocking

none

### important

none

### nit

none

### suggestion

- 保留 `presets()` / `current()` defensive copy 和四类 starter 独立 postcondition 证据，避免聚合结果掩盖单个 adapter 失败。

### learning

- `git status -z` 只提供路径编码安全；文件级未跟踪证据还需要 `--untracked-files=all`。
- implementation scope baseline 与单次测试 checksum/trap 是两层不同证据。
- JSON 磁盘原子性与 legacy caller 内存语义必须分开声明，Logo 通过 defensive candidate 获得 commit-on-success。

### praise

- 用户否决不达预期的两种风格后，方案及时收敛为两款高质量霓虹成品。
- provider/adapter seam 与四处重复旧 Header 的代码事实匹配。
- CMD-000 至 CMD-008、Acceptance Matrix、DoD 与 Required Artifacts 已完全对齐。

## 4. User Review Focus

- 最终拍板：仅两款霓虹 Logo；默认 `neon-title-unicode`；两份准确六行画面；`<leader>uo`；缺 Nerd Font 时手动改选 Unicode。
- implement 遵守：S0 baseline 必须先于代码；candidate 原子保存；event schedule/pcall；confirm 成功才 close；四类 adapter postcondition；按钮/布局零语义变化。
- review/QA/acceptance 复核：CMD-000 至 CMD-008；临时 XDG/config/lock；四份 adapter 证据；日常 JSON/lock checksum；file-level baseline delta；架构回写。

## 5. Evidence Confidence Ledger

| Check | Verdict | Evidence Class | Basis | Follow-up |
|---|---|---|---|---|
| Acceptance Coverage Matrix | pass | E | S0-S7、CMD-000..008、场景与证据类型对应 | implementation 按矩阵留证 |
| DoD Contract | pass | E | 五阶段 DoD、命令与 artifacts 完整 | 后续 gate 执行 |
| Steps and checks traceability | pass | E | 每个核心场景可追到 step/check/command | none |
| Roadmap contract compliance | n/a | E | 非 roadmap feature | none |
| Module interface design | pass | E/C | provider、candidate save、event、adapter seam 有代码/API 事实 | code review 核对 |
| Exact assets | pass | E/C | 两份六行 Header，本地宽度均为 58 | UI QA |
| Validation isolation | pass | E/C | exclusive baseline、临时 XDG/config/lock、trap/checksum | 实现 wrapper |
| Scope guard | pass | E/C | file-level NUL-safe porcelain、rename/copy 解析、allowlist | guard 实现验证 |

Summary: E=4, E/C=4, H=0；H-only core checks=none。

## 6. Residual Risk

- Alpha/dashboard-nvim 当前未安装；S6 必须读取隔离 checkout 的锁定源码，API 不满足 postcondition 时返回 design。
- porcelain parser 必须正确处理 v1 `-z` rename/copy 双路径；baseline/current 参数不得漂移。
- 四类 adapter 需验证所有可见 Dashboard window，而不是只验证当前 buffer。
- Nerd Font `strdisplaywidth=58` 不能替代真实终端视觉确认。
- 用户私有配置可能占用 `<leader>uo`，实现需检查最终运行时映射。
- acceptance 需更新 `system-shawnvim-runtime.md` 的 `dashboard_logo` 状态与共享 provider。

## 7. Verdict

- Status: passed
- Next: 交给用户整体 review；用户明确批准后将 design 标记 `approved`，再进入 `cs-feat-impl`。
