---
doc_type: feature-review
feature: 2026-07-15-upgrade-blink-cmp
status: passed
reviewer: subagent
reviewed: 2026-07-15
round: 1
---

# upgrade-blink-cmp 代码审查报告

## 1. Scope And Inputs

- Design: `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-design.md`
- Checklist: `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-checklist.yaml`
- Evidence pack: `/tmp/codestable-blink-upgrade-review.md`
- Gate results: none（Standard lane）
- DoD results: checklist canonical commands；CMD-000/002/003/004、YAML 与 `git diff --check` 本轮通过
- Implementation evidence: `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-implementation.md` 与两个 step fix 记录
- Diff basis: 当前 `git status`、unstaged diff 与 3 个未跟踪实现证据文件
- Review mode: initial
- Baseline dirty files: none；现有 dirty/untracked 均可归因于本 feature

### Independent Review

- Detection: Paseo 不可用；原生 Codex Task agent 可用；`ocr` CLI 存在，但 `ocr llm test` 因 `127.0.0.1:18080` connection refused 失败
- 环节 A 独立隔离 Task agent: native-agent + completed（`/root/blink_upgrade_code_review`）
- 环节 B OCR CLI: failed（provider 服务未运行，不阻塞 Task agent gate）
- OCR severity mapping: High→blocking/important，Medium→nit/suggestion，Low→discarded
- Merge policy: Task agent findings 已由主 agent逐条读取 fixture、canonical commands、实现记录和 blink v1.10.2 官方源码后合并；production config 未发现错误，但三项证据缺口会让核心场景假通过，因此从 reviewer 的 important 提升为 blocking
- Gate effect: `changes-requested`；修复并复审前不得进入 acceptance

## 2. Diff Summary

- 新增：implementation evidence、S1/S6 窄修复记录、本 review 报告
- 修改：`lazy-lock.json`、`lua/shawnvim/plugins/extras/coding/blink.lua`、design、checklist
- 删除：none
- 未跟踪 / staged：上述实现证据与 review 文件未跟踪；无 staged diff
- 风险热点：依赖与宿主 runtime 升级、异步 Rust matcher、Insert/cmdline 用户交互、rollback evidence；无权限、数据迁移或公共 API 改动

## 3. Adversarial Pass

- 假设的生产 bug：升级表面能启动，但 fallback、source 编排或通知错误被测试假阳性掩盖。
- 主动攻击过的反例：无候选 `<C-y>` 被吞、provider 内部有候选但公开 completion list 无候选、大小写混合 WARN 绕过 notification guard、冷缓存 matcher 超时、rollback 与 target checkout 串线。
- 结果：前三项升级为 blocking；matcher 慢网与 Neovim 0.11.2 实机覆盖留给 residual risk / acceptance focus。target/rollback checkout 与 production config 本身通过事实核验。

## 4. Findings

### blocking

- [x] REV-001 `/tmp/shawnvim-blink-cmp-upgrade/interaction-ui.py:98` `<C-y>` fallback fixture 会在首次结果仍为 `zz` 时 `iunmap` 后重试，吞键实现也可能通过。
  - Evidence: fixture 第 100-104 行删除被测映射后，只断言最终行不等于 `zz`；而新增 production 行为正是 `blink.lua:104` 的 fallback。
  - Impact: I5 是 `<C-y>` 配置改动的唯一交互回归证据，当前可假阳性，无法可信进入 acceptance。
  - Expected fix scope: 只修改临时 UI fixture；移除 unmap/retry，单次按键后精确断言原生结果 `zbz`，保存 stdout/exit code 并复跑。

- [x] REV-002 `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-implementation.md:58` 声称 LSP/path/buffer/lazydev 均在同一真实 UI 流程复验，但 UI fixture 实际只覆盖 snippet、fallback 与 cmdline。
  - Evidence: `interaction-ui.py:73-121` 未触发 LSP/path/buffer/lazydev Insert 场景；`source-smoke.lua:162-174` 通过 source module 内部调用取得 LSP/lazydev items，没有经过配置后的公开 completion list/menu。
  - Impact: provider 内部返回候选不能完全证明 blink 编排、fuzzy/list 与展示链路；I1-I3/I7 的 runtime interaction 证据不足。
  - Expected fix scope: 只扩充临时 UI/QA fixture，在真实 Insert UI 中分别触发 LSP/path/buffer/lazydev，并从公开 completion list 断言 `source_id + label`；同步修正实现证据，不改 production source 配置。

- [x] REV-003 `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-checklist.yaml:117` Notifications 关键词匹配区分大小写，会漏掉非 ERROR 的 `Blink`/`Config`/`Schema`/`Import` warning。
  - Evidence: CMD-002 和 CMD-005 对 `n.msg` 直接调用小写 `find()`；仅 `:messages` 分支先执行 `lower()`。
  - Impact: design 要求无 blink/config/schema/import-order 通知，但例如 `Blink config schema changed` 可被核心 cold-start 命令判为成功。
  - Expected fix scope: 只加强 CMD-002/CMD-005 notification predicate，对 `tostring(n.msg):lower()` 匹配；注入大小写混合 WARN，证明验证以非零退出失败。

### important

none

### nit

- [x] REV-004 `.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-implementation.md:45` “无新增兼容配置”与 S4 已记录的 `<C-y>` fallback 不一致；改为“除已记录 fallback 外无其他兼容配置”。

### suggestion

- [ ] REV-005 将 UI interaction stdout、退出码与 rollback manifest 保存为稳定 evidence artifact，避免 `/tmp` fixture 与实现摘要漂移。

### learning

- blink.cmp v1.10.2 官方 `default` preset 和 keymap 注释均明确使用 `<C-y> = { "select_and_accept", "fallback" }`；v0.14.2 也支持同一 fallback command。
- rollback config 的旧 lock 会让 Lazy restore 覆盖 semver 解析，因此当前 rollback 并非新 spec 与旧 checkout 的失配状态。

### praise

- `lazy-lock.json` 精确命中 v1.10.2 peeled commit，merge-base JSON guard 只有 `blink.cmp` 一个 key 变化。
- production `<C-y>` 配置与 v1.10.2 官方 preset 一致；target/rollback checkout 仍分别为 v1.10.2/v0.14.2。

## 5. Test And QA Focus

- QA 必须重点复核：单次 `<C-y>` 原生 fallback；真实 Insert UI 的 LSP/path/buffer/snippets/lazydev；`: / ?` 候选可见时的左右键；大小写混合 notification 失败注入；cold-cache Rust matcher；最终清理 absence assertions。
- Evidence pack residual risks / gate warnings：OCR provider 不可用；review packet 的通用 sufficiency checker 不识别 quality packet shape，但 reviewer 直接读取了原始产物与 diff。
- 建议新增或加强的测试：扩充一次性 UI fixture并保存输出；为 notification predicate 做正/负注入。
- 不能靠 review 完全确认的点：慢网下载重试、Neovim 0.11.2 实机兼容、日常 XDG 在 merge 后的最终同步。

## 6. Residual Risk

- Design 明确未覆盖 Neovim 0.11.2 实机；本 feature 只对已安装的 0.12.4 自证。
- Rust matcher 首次下载有异步时序；已有 15 秒等待和 health 正向证据，但慢网/下载失败重试留给 acceptance 风险说明。
- 日常 `~/.local/share/nvim` 仍为 v0.14.2，避免 feature 未合并时污染日常环境；merge 后需执行精确 restore/update 并复验实际日常 checkout。

## 7. Verdict

- Status: passed
- Next: Standard feature 进入 `cs-feat` accept-inline。

## 8. Focused Closure

- Closed findings: REV-001、REV-002、REV-003、REV-004
- Attributed delta: `/tmp/shawnvim-blink-cmp-upgrade/interaction-ui.py`、checklist/design 中 CMD-002/CMD-005 notification predicates、implementation/review-fix evidence；production `blink.lua` 与 `lazy-lock.json` 没有 review 后增量
- Targeted verification: UI fixture `interaction-ui-exit=0`；单次 `<C-y>=zbz`；公开 completion list 的 buffer/path/snippets/LSP/lazydev `source_id + label`；snippet/LSP 接受；`: / ?` 左右键；CMD-002/CMD-005 正常为 0、大小写混合 WARN 注入均为 1；CMD-000..005、YAML、scope guard 全通过
- Classification: 增量仅为 test/docs/metadata/validation evidence，不改变 production 行为、公开契约、安全、数据、并发或架构；满足 focused closure 条件，保留首次 `reviewer: subagent` 锚点与 `round: 1`
