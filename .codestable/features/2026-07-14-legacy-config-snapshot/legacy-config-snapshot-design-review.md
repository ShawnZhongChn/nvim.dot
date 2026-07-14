---
doc_type: feature-design-review
feature: 2026-07-14-legacy-config-snapshot
status: passed
reviewed: 2026-07-14
round: 3
---

# legacy-config-snapshot feature design 审查报告

## 1. Scope And Inputs

- Design: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-design.md`
- Checklist: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-checklist.yaml`
- Intent / brainstorm: none
- Roadmap: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-roadmap.md`、`shawnvim-fork-items.yaml`
- Related docs: `.codestable/attention.md`、Git worktree/ignore/remote facts
- Code facts checked: `.gitignore`、`lua/custom/debug/init.lua`、`lua/custom/plugins/dap.lua`、`lazy-lock.json`、origin refs

### Independent Review

- Status: completed
- Detection: native-agent
- Provider / agent: native Codex agent `/root/design_review_git_core`
- Raw output: 当前会话 agent transcript；三轮完整审查与最终 focused closure
- Merge policy: findings 均由主 agent 以 design/checklist/Git facts 逐条核验；最终剩余 blocking/important 为 none
- Gate effect: none

## 2. Design Summary

- Goal: 在任何旧运行时删除前建立完整 legacy commit 与 annotated tag 恢复锚点。
- Key contracts: tracked/untracked/ignored 三类 inventory；PRE_HEAD 与真实远端 before/after；tag object/peeled/tree/ancestor assertions。
- Steps: 4 步；风险热点是 ignored runtime blobs、ahead commits 与远端非变更证明。
- Checks: 7 项，覆盖名词、流程、挂载点、范围与验收。
- Baseline / validation: 8 条 Git commands，均可从命名 evidence/tag 直接重放。

## 3. Findings

### blocking

none。

### important

none。

### nit

none。

### suggestion

none。

### learning

- 迁移前快照必须审计 ignored 但被运行时引用的文件，普通 `git status` 不足以证明恢复完整。

### praise

- PRE_HEAD、关键 ignored blobs、双祖先与真实远端 before/after 已形成可证伪闭环。

## 4. User Review Focus

- 用户需要重点拍板：legacy tag 是命名恢复 snapshot，不承诺它是未来时序上的绝对最后 commit。
- implement 需要重点遵守：不 push、不重写历史；同名错误 tag fail-closed。
- code review / QA / acceptance 需要重点复核：before/after 参数一致、关键 blobs 存在、PRE_HEAD 为 snapshot 祖先。

## 5. Evidence Confidence Ledger

| Check | Verdict | Evidence Class | Basis | Follow-up |
|---|---|---|---|---|
| Acceptance Coverage Matrix | pass | E | design §3.3 与 4 个 steps/8 commands 对齐 | none |
| DoD Contract | pass | E | Design/Impl/Review/QA/Acceptance 均有证据 | none |
| Steps and checks traceability | pass | E | checklist 全 pending且来源完整 | none |
| Roadmap contract compliance | pass | C | parent item/status/feature pointer一致 | none |
| Module interface design | pass | C | Git commit/tag 是稳定恢复 seam | none |
| Validation and artifacts | pass | E | PRE_HEAD、remote snapshots、tag/tree assertions明确 | none |

Summary: E=4, C=2, H=0, H-only core checks=none。

## 6. Residual Risk

- 远端并发变化只能检测不能归因；当前按 fail-closed 阻塞即可。
- ignored 路径的有效性仍需实现时逐项写理由。

## 7. Verdict

- Status: passed
- Next: 交给用户与其余 epic child designs 一次性整体 review。

## 8. Focused Closure

- Closed findings: PRE_HEAD 变量不可重放、remote after 生成参数不明确。
- Attributed delta: CMD-007 改为直接读取 evidence/tag；S1/S4/CMD-008 固定同一 `ls-remote` 参数。
- Verification: YAML validation、design/checklist command equality、`git diff --check` 均通过。
- Classification: 仅收紧证据映射与命令自包含性，不改变范围、行为、架构或验收语义。
