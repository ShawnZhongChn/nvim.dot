# ShawnVim Fork Goal Plan

## 1. Inputs And Order

- Roadmap: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-roadmap.md`
- Items: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-items.yaml`
- Baseline: `6552a4d0304f6b1378b5a75f06a1b0062f8f2249`
- Execution order:
  1. `legacy-config-snapshot` — 保存完整旧配置与不可变恢复 tag（mixed）。
  2. `shawnvim-core-fork` — 导入固定源码并建立独立 Distribution Core（functional）。
  3. `shawnvim-development-docs` — 接收并适配固定 Markdown 文档快照（non-functional）。
  4. `shawnvim-config-cutover` — 真实启动链切换与旧 runtime 删除（functional）。
  5. `shawnvim-release-hardening` — 完整测试、CI、发布对象与远端同步（mixed）。

## 2. Roadmap Core Acceptance Paths

1. Git recovery：legacy annotated tag 可读取 PRE_HEAD、关键 ignored blobs 与完整旧 tree。
2. Core smoke：隔离 minit 从本地 self-spec 真实加载 `_G.ShawnVim` / `shawnvim.plugins`，无 LazyVim/starter spec。
3. Documentation baseline：固定 docs commit 的 138 source Markdown 映射为 138 destinations，另有 1 generated working news；全量 audit 为 139 Markdown。
4. Real cutover：四 XDG clean-room 首次/二次启动成功，真实 config root 在隔离 data/state/cache 下通过 health。
5. Release：本地 `scripts/test` 与 candidate 精确 SHA 的 Neovim v0.11.2/stable CI 通过；两个 annotated tags 和最终 master 与 origin 收敛，GitHub Release 为 absent。

## 3. Assumptions

- 用户已确认 roadmap 与五份 feature design，并确认拥有文档转载权。
- `origin` 仍是 `https://github.com/ShawnZhongChn/nvim.dot.git`，目标分支为 `master`。
- 只允许正常 non-force push；远端 divergence、tag冲突或权限不足必须 handoff。
- release candidate push 前仍需针对具体 candidate OID/refs 完成 `approval-report.md` owner gate。
- 不运行 `scripts/setup_editor.sh`；不全局安装缺失工具，不创建同名 shim。

## 4. Top Risks And Mitigations

1. **破坏性切换遗漏用户状态**：legacy feature 先提交 tracked/untracked/ignored有效资产并建立 annotated tag；cutover mutation 前再次验证。
2. **大规模分叉出现身份/许可/语义漂移**：固定源码/docs commits，使用双 hash、精确 JSON Pointer、逐文件 notice、Tabs/operation replay与独立 review/QA。
3. **CI或远端部分成功**：candidate/tag/admin 分阶段非强制同步；每步 fetch/equality/object reconciliation，失败保留对象并按 ref 幂等恢复。

## 5. Mandatory Validation Commands

- Legacy：8 条 checklist Git object/remote commands。
- Core：`nvim -l tests/minit.lua --minitest`、identity/source/syntax audits；Stylua/Selene 为 supporting baseline。
- Docs：`scripts/audit-docs ...`、identity audit、`git diff --check`。
- Cutover：clean-room/real-config、identity/runtime-tree、strict tracked state/lock、resolved graph audit。
- Release：`scripts/test`、license audit、exact-SHA GitHub Actions REST jobs、tag object/peeled comparisons、Release 404、final admin convergence。

完整命令以各 `.codestable/features/.../*-checklist.yaml` 与 `goal-features/*.md` 为权威；不得降低 core 标记。

## 6. Final Aggregate Commands

Roadmap 完成前至少重跑：

```text
scripts/test --json-evidence .tests/evidence/release-local.json
scripts/audit-identity --json .tests/evidence/final-identity.json
scripts/audit-source-manifest --source-cache .tests/upstream/lazyvim-source --fetch-missing --core . --manifest UPSTREAM-SOURCE.json --json .tests/evidence/final-source.json
scripts/audit-docs --source-cache .tests/upstream/lazyvim-docs --fetch-missing --docs docs/development/0.1.0 --manifest docs/development/0.1.0/SOURCE.json --core . --json .tests/evidence/final-docs.json
scripts/test-clean-start --json .tests/evidence/final-clean-start.json
scripts/audit-runtime-tree --json .tests/evidence/final-runtime-tree.json
scripts/generate-lock --check-resolved --json .tests/evidence/final-lock.json
git diff --check
python3 /home/shawn/.codex/plugins/cache/codestable/codestable/1.0.3/skills/cs-onboard/tools/codestable-goal-consistency-gate.py --roadmap .codestable/roadmap/shawnvim-fork
```

External CI/ref/API facts may use immutable prior evidence only when the candidate/tag/admin OIDs still match; otherwise re-query. Functional core paths cannot be skipped for cost or duration.

## 7. Preflight Strategy

- 每个 feature 先读取其 design/checklist/spec，运行 declared baseline checks。
- Legacy snapshot 负责把当前 dirty worktree、CodeStable runtime与用户代码修改安全提交；在此之前不删除或覆盖文件。
- Source/docs cache 只允许 fixed commit；cache-hit须验证 OID/tree/clean。
- 自动化 Neovim 使用隔离 XDG，除明确 `--real-config` 模式外不读取用户data/state/cache。
- 外部 mutation 仅在 release feature 的 approval、fetch、divergence/tag conflict gates通过后发生。

## 8. DoD Policy

- 每个 design保持`approved`；checklist steps依序`pending → done`，checks只在acceptance改为`passed`。
- 每个feature必须有独立code review、QA、acceptance与机器evidence；core场景不能只有H证据。
- acceptance后回写roadmap item/架构/requirements/attention，并立即scoped commit；工作树干净后才能推进下一feature。
- 任一approved contract需要变化时立即handoff，不得在goal内静默改scope。

## 9. Gate Policy

- 运行时权威：`.codestable/roadmap/shawnvim-fork/goal-protocol-gates.md`。
- Implementation前后运行scope-gate、dod-runner、evidence-pack；review、QA、acceptance各自消费对应evidence gate。
- review必须使用独立Task agent；QA高风险路径优先独立runner。三轮同一失败仍不通过则handoff。
- 最终必须运行goal consistency gate与goal audit gate，写`goal-audit.md`。

## 10. Provider Policy

- Paseo不可用时使用用户可见native Task agent；同类agent残余风险写入review/QA。
- archguard/meta-cc unavailable只记录fallback，不自动阻塞；provider warning必须由review/QA/audit解释。
- Provider不可用不能用本地自审伪装独立gate；需要降级时必须owner明确批准。

## 11. Missing Validation Tool Recovery

- 只可补真实测试依赖、锁文件或既有runner配置；不得创建`pytest.py`、`jest`、`go`等同名shim。
- Stylua/Selene在core阶段缺失时按design记录supporting baseline；release CI若声明安装，则使用固定版本/来源。
- GitHub CLI缺失不阻塞：设计已使用`curl`/`jq` REST gate；HTTP失败与404必须区分。

## 12. Final Audit Artifacts

- 五份design/checklist/review/QA/acceptance与gate/evidence packs。
- source/docs manifests、per-file notice、138/139/Tabs/operation/core digest证据。
- clean-room/real-config/runtime-tree/state/lock evidence。
- candidate/legacy/release/admin Git objects、exact-SHA CI run/jobs、approved publish report、tag双OID、Release 404与FinalConvergenceEvidence。
- architecture/requirements/attention/roadmap回写、provider warnings与E/C/H汇总、H-only core checks清单。
