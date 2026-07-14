---
doc_type: feature-design-review
feature: 2026-07-14-shawnvim-core-fork
status: passed
reviewed: 2026-07-14
round: 4
---

# shawnvim-core-fork feature design 审查报告

## 1. Scope And Inputs

- Design: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-design.md`
- Checklist: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-checklist.yaml`
- Intent / brainstorm: none
- Roadmap: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-roadmap.md`、`shawnvim-fork-items.yaml`
- Related docs: fixed LazyVim source/license facts、namespace/state/provenance contracts
- Code facts checked: upstream commit `459a4c3...`、version 16.0.0/minimum 0.11.2/self-spec/minit；lazy.nvim commit `306a055...`

### Independent Review

- Status: completed
- Detection: native-agent
- Provider / agent: native Codex agent `/root/design_review_git_core`
- Raw output: 当前会话 agent transcript；四轮完整独立复审
- Merge policy: 所有 findings 以固定源码、roadmap、design/checklist逐条核验；最终剩余 blocking/important 为 none
- Gate effect: none

## 2. Design Summary

- Goal: 把固定 LazyVim 16.0.0 源码直接分叉为本地 ShawnVim 0.1.0 core，不切真实 init。
- Key contracts: local self-spec；ShawnVim namespace/state；精确source manifest/JSON Pointer；逐文件Apache notice；fixed minit harness。
- Steps: 7 步；风险热点是机械identity、setup lifecycle、source/notice审计与test harness漂移。
- Checks: 12 项，覆盖入口、状态、来源、identity、history、version seam与fixed lazy.nvim。
- Baseline / validation: minit、identity/source audits、syntax与supporting format/lint baselines。

## 3. Findings

### blocking

none。

### important

none。

### nit

none。

### suggestion

- 实现 audit 时显式拒绝 `modified` 与 `modification_notice.status` 矛盾。

### learning

- 固定 bootstrap 脚本来源不等于固定最终 checkout；clone/cache-hit都必须验证实际OID与clean状态。

### praise

- test-only真实import probe、四分支lazy.nvim harness、逐source notice与字段级identity allowlist已闭合。

## 4. User Review Focus

- 用户需要重点拍板：首次core只做必要分叉，不迁移旧个人行为，也不保留LazyVim兼容alias。
- implement 需要重点遵守：每个被改写Apache源文件带显著notice；source/test依赖都固定OID。
- code review / QA / acceptance 需要重点复核：resolved local self-spec、真实import version failure、manifest双hash/notice和旧identity零残留。

## 5. Evidence Confidence Ledger

| Check | Verdict | Evidence Class | Basis | Follow-up |
|---|---|---|---|---|
| Acceptance Coverage Matrix | pass | E | setup/state/source/news/version/harness场景完整 | none |
| DoD Contract | pass | E | core commands与supporting baseline边界一致 | none |
| Steps and checks traceability | pass | E | 7 steps/12 checks均可追踪 | none |
| Roadmap contract compliance | pass | C | namespace/provenance/manifest硬契约已同步 | none |
| Module interface design | pass | C | local self-spec/setup/version test seam明确 | none |
| Validation and artifacts | pass | E | core-minit/source/identity JSON与notice artifacts明确 | none |

Summary: E=4, C=2, H=0, H-only core checks=none。

## 6. Residual Risk

- 外部plugin specs的完整锁定由cutover/release lockfile与CI负责。
- notice显著性的法律充分性仍需owner/法律判断；机器gate只证明存在、位置与hash。

## 7. Verdict

- Status: passed
- Next: 交给用户与其余 epic child designs 一次性整体 review。

## 8. Focused Closure

none。
