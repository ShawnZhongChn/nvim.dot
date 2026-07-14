---
doc_type: roadmap-review
roadmap: shawnvim-fork
status: passed
reviewed: 2026-07-14
round: 8
---

# shawnvim-fork roadmap 审查报告

## 1. Scope And Inputs

- Roadmap: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-roadmap.md`
- Items: `.codestable/roadmap/shawnvim-fork/shawnvim-fork-items.yaml`
- Related docs: `.codestable/requirements/nvim-dot.md`、`.codestable/architecture/ARCHITECTURE.md`、`.codestable/roadmap/nvim-modernization/`
- Related compound/drafts: 未找到与 ShawnVim / LazyVim fork 直接相关的材料
- Code facts checked: 当前 `init.lua`、`.gitignore`、`.stylua.toml`、`LICENSE.md`、README、Git branch/remote/status
- Upstream source facts: LazyVim commit `459a4c3b1059671e766a46c7cc223827dc67e3d0` 的 core init、config version、self-spec、tests、CI、NEWS、CHANGELOG 与 Apache-2.0 LICENSE
- Upstream docs facts: `LazyVim/lazyvim.github.io` commit `85e5b49e5bf0a4208bd9d1600e1710f4bb6c0e9c`；本次只选取 138 个 Markdown，3 个 `_category_.yml` 明确排除；仓库无独立 LICENSE；Markdown 包含大量 Docusaurus Tabs/TabItem/admonition 和一个 docs tree 外 `/img/logo.svg`
- Retrieval note: browser-bridge 因 Chrome 扩展无已连接 tab 无法抽取页面，官方事实改由 Git remote 与固定仓库快照只读核验
- Authorization fact: 项目 owner 明确确认持有文档转载权

### Independent Review

- Status: completed
- Detection: native-agent
- Provider / agent: `/root/shawnvim_roadmap_review`
- Raw output: 同一独立 reviewer 完成 8 轮审查；round 1-4 审查源码/运行时/发布契约，round 5-7 审查新增文档基线，round 8 审查 Markdown-only 收窄
- Merge policy: 主 agent 对每条 finding 使用本地仓库、固定上游源码和固定文档快照逐条核验；每次实质修订后重新交独立 reviewer
- Gate effect: none

## 2. Roadmap Summary

- Goal completion signal: 以固定 LazyVim 16.0.0 源码建立 ShawnVim 0.1.0，核心源码直接位于本仓库，运行时/Git/CI 不依赖 LazyVim；把官方当前选定的 138 个 Markdown 完整、可追溯地适配为 0.1.0 开发文档；旧配置可由 legacy tag 恢复；最终 branch 与两个 annotated tags 同步到 origin。
- Module split: Legacy Safety、Distribution Core、Config Shell、Documentation Baseline、Verification & Release 五层。
- Interface contracts: 本地 self-spec、ShawnVim namespace/state、固定 import order、source/docs provenance、source import manifest、versioned development docs。
- Items: 5 条；`shawnvim-core-fork` 为唯一 minimal loop；docs 与 cutover 在 core 后形成两个独立分支，release 同时依赖两者。
- Dependency shape: DAG：`legacy-config-snapshot → shawnvim-core-fork → {shawnvim-development-docs, shawnvim-config-cutover} → shawnvim-release-hardening`。

## 3. Findings

### blocking

none。

### important

none。

### nit

none。Round 7 的 Goal Coverage wording 与 hash normalization 建议已在不改变方案的前提下补齐。

### suggestion

- `v0.1.0` annotated tag message 可同时记录源码 commit、文档 commit 与“不创建 GitHub Release”，增强单独查看 tag 时的 provenance。
- 实现阶段可让 docs audit 输出 JSON evidence，方便 acceptance 和 CI 复用。

### learning

- 运行时代码读取 NEWS/CHANGELOG 不代表应复制并改牌上游发布历史；ShawnVim 保留 news API，但从 0.1.0 建立自己的历史。
- 品牌 identity audit 无法发现纯数字版本残留，发行版本需要独立 runtime assertion。
- 文档 source hash/file count 只能证明完整接收，不能证明转换后脱离 Docusaurus；MDX residual、Tabs branch bijection 与 link/asset gate 是独立证据。
- “持有转载权”不自动等于可按 Apache-2.0 向下游再许可，文档子树必须与根源码许可证分界。

### praise

- 固定源码与文档两个独立 commit、Apache 源码归属、文档转载边界、legacy 恢复锚点和无长期 upstream Git 关系均已形成可审计契约。
- 上游 16.0.0 provenance、ShawnVim 0.1.0 release version、JSON schema integer 三种版本含义已分离。
- 文档 138-Markdown bijection、source/destination 双 hash、generated/excluded files、Tabs branch mapping、news 保真隔离和无站点运行时 gate 具备直接实现粒度。

### Review History

- RMR-001 resolved：core 独占 minit/self-spec smoke，release 独占其余 tests/scripts/CI。
- RMR-002 resolved：Apache LICENSE/UPSTREAM 与源码同批落地并删除 MIT `LICENSE.md`。
- RMR-003 resolved：identity audit 覆盖 tracked paths/content、events、globals、health、state 与 plugin identity。
- RMR-004/RMR-007 resolved：新建 ShawnVim NEWS/CHANGELOG，上游历史仅由 provenance 链接。
- RMR-005 resolved：采用上游 Stylua/Selene 开发基线，cutover 明确跟踪 lockfile。
- RMR-006 resolved：CI matrix 覆盖精确 `v0.11.2` 与 stable。
- RMR-008 resolved：cutover 生成/提交 lockfile，release 只审计。
- RMR-009 resolved：硬性断言 `ShawnVim.config.version == "0.1.0"`，并与 schema version、`v0.1.0` tag 分离。
- RMR-010 resolved：根 Apache-2.0 不覆盖转载/适配文档子树，文档权利边界由 `UPSTREAM-DOCS.md` 单列。
- RMR-011 resolved：code-aware 全树 gate 禁止 MDX/Docusaurus 残留并验证本地链接/资产。
- RMR-012 resolved：每个 Tabs 源文件保存 source/target ordinal、label/heading、body hash，gate 全量验证分支 bijection；logo 明确不导入。
- Round 8 scope closure：只复制 138 个 Markdown；三份 `_category_.yml` 仅进入 excluded manifest，不产生 destination。

## 4. User Review Focus

- 用户需要重点拍板：
  - 旧 `lua/custom` / `lua/core` / `after/ftplugin` 行为不迁移，只通过 Git history 与 legacy tag 保存。
  - ShawnVim 与 LazyVim 不保留 remote/submodule/自动同步；仅保留来源归属。
  - ShawnVim 从 `0.1.0` 开始独立版本线，创建并推送 annotated `v0.1.0`，本次不创建 GitHub Release。
  - 根源码采用 Apache-2.0；转载/适配文档子树不自动适用 Apache，其权利边界由 `UPSTREAM-DOCS.md` 声明。
  - 只接收官方 `docs/` 中的 138 个 Markdown，不复制 category YAML 或 Docusaurus/Yarn/React 站点工程；转换后以普通 Markdown 交付。
- 后续 feature-design 需要重点复核：self-spec root seam、动态 extras/state migration、文档转换/manifest schema、code-aware MDX parser、identity allowlist、clean-room 首次启动、v0.11.2 lockfile 兼容。
- 不能靠 roadmap review 完全确认的点：origin 的 branch/tag protection 与推送权限、最终 lockfile 跨版本兼容、138 个 Markdown 的品牌/语义适配质量、外部转载授权文件本身。

## 5. Evidence Confidence Ledger

| Check | Verdict | Evidence Class | Basis | Follow-up |
|---|---|---|---|---|
| Granularity Gate | pass | E | roadmap 明确 Git safety、core、docs、cutover、release 多阶段 | none |
| Goal Coverage Matrix | pass | E | 每个核心完成信号映射到 item、命令/CI/manifest 与证据类型 | acceptance 按矩阵采证 |
| DAG and minimal loop | pass | E | items.yaml 可解析、无未知依赖/环，唯一 minimal loop | none |
| Interface contract usability | pass | C | Lua/spec/state/provenance/docs 契约与固定上游快照逐项核对 | feature-design 细化实现 |
| Module interface depth | pass | E | core 为 deep module，Config Shell 为 composition root，Docs 为冻结版本 module | none |
| Docs snapshot completeness | pass | C | 固定官方 commit 的 138 Markdown selection 与 3 YAML exclusion 契约一致 | implementation 生成双 hash |
| Docs runtime independence | pass | C | 官方 MDX/asset 事实映射到 residual/Tabs/link/asset gates | 用真实 138 Markdown 验证 parser |

Summary: E=4，C=3，H=0，H-only core checks=none。

## 6. Residual Risk

- 最终 lockfile 中的插件组合能否同时支持精确 v0.11.2 与 stable，需在 release CI 实测。
- namespace 改名后的动态 extras/state migration 必须由 core smoke 与 clean-room QA 覆盖。
- 138 个 Markdown 的品牌适配和代码链接校准可能存在语义偏差；machine gates 后仍需代表性人工阅读。
- Markdown/MDX parser 对嵌套 JSX、代码围栏和异常源格式的处理必须用全部 138 个 Markdown 验证。
- 用户转载权是外部授权事实；仓库审查只能确认来源、许可边界和授权声明被记录。
- branch 与两个 annotated tags 的推送依赖 origin 权限、保护规则与网络；部分推送不能视为完成。

## 7. Verdict

- Status: passed
- Next: 交给用户 review；用户确认后把 roadmap 标为 active，再连续推进 5 个子 feature design 与 design review。
