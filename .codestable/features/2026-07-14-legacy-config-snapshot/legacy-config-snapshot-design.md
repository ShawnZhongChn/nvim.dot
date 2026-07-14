---
doc_type: feature-design
feature: 2026-07-14-legacy-config-snapshot
requirement: nvim-dot
roadmap: shawnvim-fork
roadmap_item: legacy-config-snapshot
execution_lane: goal
status: approved
summary: 在替换旧 Neovim 配置前建立不可变 Git 恢复锚点
tags: [git, migration, backup, shawnvim]
---

# Legacy Config Snapshot

## 0. 术语约定

| 术语 | 定义 | 防冲突结论 |
|---|---|---|
| legacy snapshot | 任何旧运行时文件被删除前，包含当前分支全部祖先与工作树有效修改的提交 | 不等同于文件系统 `.bak`，唯一权威是 Git object |
| legacy tag | 指向 legacy snapshot 的 annotated tag `legacy-nvim-config-2026-07-14` | 不复用 release tag；它只承担恢复用途 |
| snapshot inventory | 提交前记录 branch、HEAD、ahead/dirty 状态和待纳入路径的证据 | 不是长期状态文件，落入 feature evidence/acceptance |

## 1. 决策与约束

### 需求摘要

在 ShawnVim 大规模导入和旧配置删除之前，把当前 `master` 比 `origin/master` 领先的提交、4 个用户代码修改、CodeStable runtime/epic 产物及其他有效工作树变化保存为一个可验证提交，并用 annotated tag 建立恢复入口。

成功标准：tag target 是完整包含 legacy runtime/worktree 的命名 snapshot；当前本地提交都是它的祖先；tracked、普通 untracked、ignored 但运行时有效的源码/lock 均经过分类并可从该 commit 读取；本 feature 不推送、不删除、不改写旧历史。首次 destructive commit 必须在 cutover 中再次证明以该 snapshot 为受保护祖先/基线。

### 明确不做

- 不执行 `reset --hard`、force push、rebase 或历史重写。
- 不创建文件系统备份目录或复制整个 `~/.config/nvim`。
- 不在本 feature 导入 ShawnVim 源码、删除旧配置或推送 origin。
- 不把日志、缓存、插件数据等未跟踪机器产物强行加入 Git。

### 复杂度档位

迁移安全 = 高于普通 Git 提交：目标操作不可由后续文件 diff替代，必须先验证 object/tag 可恢复。其他维度走配置仓库默认档位。

### 关键决策

1. 使用普通 snapshot commit + annotated tag，不使用 orphan branch。这样后续 ShawnVim 历史自然保留旧配置祖先，恢复和 blame 都可用。
2. tag 在任何旧运行时删除前创建；若同名 tag 已存在，只接受它已经指向本次 snapshot，否则阻塞而不覆盖。
3. inventory 必须覆盖 tracked、普通 untracked、ignored 三类。被运行时引用的 ignored 源码和旧 lockfile 要显式强制纳入；`.tests`、cache/log 等机器产物只能在写明理由后排除。
4. 本 feature 仅建立本地锚点；两个 tags 和最终 branch 的远端同步由 `shawnvim-release-hardening` 统一完成，避免部分迁移提前暴露。

### 基线风险、依赖与证据

- 基线风险：`.gitignore` 的 `debug` 会命中实际被 `require("custom.debug")` 使用的 `lua/custom/debug/init.lua`，且旧 `lazy-lock.json` 也被忽略；普通 `git status` 看不到这些有效资产。
- 非显然依赖：Git author 配置必须可用；tag 名不得冲突；origin 可能已前进，但本 feature不 fetch/push。
- Top 3 风险：漏 ignored 有效文件（三类 inventory + tree blob assertions）、tag 指错 commit（对象断言）、误推送或重写（local remote-tracking + `git ls-remote` 前后对比）。
- 关键假设：当前仓库 `/home/shawn/.config/nvim` 是唯一待接管的配置仓库；用户不要求把本地插件数据纳入恢复。
- 证据类型：Git command output、commit/tree diff review、annotated tag object。
- 清洁度：不新增临时 patch、日志、TODO/FIXME 或备份目录。

## 2. 名词与编排

### 2.1 名词层

**现状**：`master` 已有本地提交和未提交修改，`origin/master` 是现有同步基线；尚无 `legacy-nvim-config-2026-07-14` tag。

**变化**：新增不可变对象契约：

```text
LegacySnapshot
  branch: master
  pre_head: <HEAD before snapshot staging/commit>
  commit: <snapshot commit oid>
  parent_history_contains: <pre-snapshot HEAD>
  tag: legacy-nvim-config-2026-07-14
  tag_type: annotated
  remote_mutation: none
```

错误语义：tag 冲突、staged 内容缺失、Git identity 缺失或对象校验失败时停止，不进入后续 destructive migration。

##### Interface 设计检查

- Module：Git object database（现有）。
- Interface：commit OID + annotated tag；caller 只需知道固定 tag 名和恢复命令。
- Seam：tag 是迁移前后共同可见的恢复 seam。
- Depth / locality：所有旧树内容由一个 commit 隐藏；删除 tag 后恢复入口消失但历史对象仍在。
- Dependency strategy：local-substitutable，本地 Git 仓库可完整验证。
- Adapter：无。
- Test surface：`git show`、`git cat-file`、ancestor/object assertions。

### 2.2 编排层

```mermaid
flowchart LR
  A[读取 branch/HEAD/status] --> B[分类有效工作树路径]
  B --> C[分类 tracked/untracked/ignored]
  C --> D[显式 stage 有效文件并审计]
  D --> E[创建 snapshot commit]
  E --> F[创建 annotated legacy tag]
  F --> G[验证 tag/ancestor/tree/remote]
```

**现状**：本地历史和工作树是可变状态，没有一个“替换前最后状态”的命名对象。

**变化**：流程升级为线性、fail-closed 的迁移前 gate。只有 inventory、commit、tag、对象验证全部通过，epic 才允许进入 core fork。

流程级约束：

- 顺序固定：三类 inventory → 逐项分类 → staged diff → commit → tag → verify。
- 幂等：已有正确 snapshot/tag 可重复验证；错误同名 tag 不自动移动。
- 原子性：commit 成功但 tag 失败时保留 commit并重试 tag，不回滚用户内容。
- 可观测点：`PRE_HEAD`/snapshot OID、tag target/type、两个 ancestor checks、命名的 pre/post remote ref snapshots。

### 2.3 挂载点清单

1. Git `master` history：新增 snapshot commit。
2. Git refs：新增 annotated tag `legacy-nvim-config-2026-07-14`。
3. Parent roadmap item：保留本 feature 的 status/feature 恢复指针。

### 2.4 推进策略

1. 基线 inventory：列出分支、历史、tracked、普通 untracked、ignored 和 local/remote refs；用`git rev-parse HEAD > .tests/evidence/legacy-pre-head.txt`与`git ls-remote origin refs/heads/master refs/tags/legacy-nvim-config-2026-07-14 > .tests/evidence/legacy-origin-before.tsv`固化权威before证据；退出信号是每个路径都有纳入/排除理由，ignored runtime源码/lock被识别。
2. Snapshot commit：stage 并提交确认后的有效状态；退出信号是工作树无遗漏的有效修改且 commit 可读取。
3. Legacy tag：在 snapshot OID 创建 annotated tag；退出信号是 tag object type/target 正确。
4. 恢复验证：核对pre-head文件中的OID与origin/master都是tag peeled snapshot祖先、tree关键blobs存在；用与S1完全相同的`git ls-remote`参数写`legacy-origin-after.tsv`并与before逐字比较；退出信号是所有Git assertions通过。

### 2.5 结构健康度与微重构

##### 评估

- 文件级：本 feature 不修改运行时代码文件，仅提交当前事实。
- 目录级：不新增源码目录；feature evidence 位于既有 `.codestable/features/` 层级。
- Interface 深度：Git commit/tag 已是足够深的恢复接口，不需要包装脚本或备份模块。

##### 结论：不做

## 3. 验收契约

### 3.1 关键场景

1. 当前 dirty/ahead 仓库触发 snapshot → 生成可读取 commit，pre-snapshot HEAD 是其祖先。
2. 查询 legacy tag → object type 为 tag，peeled target 等于 snapshot commit。
3. 从 tag 查看用户代码修改、本地提交、`lua/custom/debug/init.lua` 和旧 `lazy-lock.json` → 对应 blob/祖先均存在。
4. 比较 feature 前后 origin refs → 没有远端 mutation。
5. 同名 tag 已错误存在 → 流程阻塞且不移动 tag。

### 3.2 明确不做的反向核对

- reflog/history 中不应出现 rebase/reset/force 更新造成的旧提交丢失。
- origin refs 不应因本 feature 改变。
- 仓库不应新增 `.bak`、日志或插件数据目录。

### 3.3 Acceptance Coverage Matrix

| Scenario | Covered By Step | Evidence Type | Command / Action | Core? |
|---|---|---|---|---|
| snapshot 包含 tracked/untracked/ignored 有效基线 | S1-S2 | command + diff review | status、ignored inventory、tree blob assertions | yes |
| annotated tag 指向 snapshot | S3 | Git object | `git cat-file -t`、`git rev-parse <tag>^{}` | yes |
| 历史与用户修改可恢复 | S4 | command | ancestor/tree assertions | yes |
| origin 未变化 | S1/S4 | command | remote refs before/after | yes |
| tag 冲突 fail-closed | S3 | command/manual | 冲突分支验证 | no |

### 3.4 DoD Contract

| ID | 要求 | 证据 | 阻塞级别 |
|---|---|---|---|
| DOD-DESIGN-001 | snapshot/tag 契约可执行 | design review | blocking |
| DOD-IMPL-001 | snapshot commit 与 annotated tag 均存在 | checklist + Git objects | blocking |
| DOD-REVIEW-001 | 无历史重写或遗漏 | independent review | blocking |
| DOD-QA-001 | 恢复 assertions 全通过 | command output | blocking |
| DOD-ACCEPT-001 | roadmap 状态和证据回写 | acceptance | blocking |

Validation Commands:

| ID | 命令 | 目的 | 核心性 | 失败处理 |
|---|---|---|---|---|
| CMD-001 | `git status --short --branch && git ls-files --others --ignored --exclude-standard` | 核对三类 inventory/snapshot 后状态 | core | fix-or-block |
| CMD-002 | `git cat-file -t legacy-nvim-config-2026-07-14` | 核对 annotated tag | core | fix-or-block |
| CMD-003 | `git rev-parse legacy-nvim-config-2026-07-14^{}` | 核对 tag target | core | fix-or-block |
| CMD-004 | `git merge-base --is-ancestor origin/master legacy-nvim-config-2026-07-14^{}` | 核对历史包含远端基线 | core | fix-or-block |
| CMD-005 | `git ls-remote origin refs/heads/master refs/tags/legacy-nvim-config-2026-07-14` | 核对真实远端 refs 未被本 feature 修改 | core | fix-or-block |
| CMD-006 | `git cat-file -e legacy-nvim-config-2026-07-14:lua/custom/debug/init.lua && git cat-file -e legacy-nvim-config-2026-07-14:lazy-lock.json` | 核对两个被 ignore 但运行时有效的关键 blob 已进入 tag tree | core | fix-or-block |
| CMD-007 | `git merge-base --is-ancestor "$(cat .tests/evidence/legacy-pre-head.txt)" "$(git rev-parse 'legacy-nvim-config-2026-07-14^{}')"` | 从权威证据/tag直接核对snapshot包含替换前全部本地提交 | core | fix-or-block |
| CMD-008 | `git ls-remote origin refs/heads/master refs/tags/legacy-nvim-config-2026-07-14 > .tests/evidence/legacy-origin-after.tsv && cmp .tests/evidence/legacy-origin-before.tsv .tests/evidence/legacy-origin-after.tsv` | 用相同参数生成after并核对真实远端refs前后逐字一致 | core | fix-or-block |

Required Artifacts: snapshot commit、annotated tag、ignored PRE_HEAD/pre-post origin evidence、关键 tree blob/ancestor command evidence、review/QA/acceptance reports；acceptance 摘要必须回写 PRE_HEAD、snapshot OID 与远端前后比较结果。

## 4. 与项目级架构文档的关系

本 feature 不改变运行时架构。它建立迁移恢复约束；acceptance 应把 legacy tag 和恢复命令写入迁移说明，不需要创建系统架构 ADR。
