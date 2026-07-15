---
doc_type: feature-acceptance
feature: 2026-07-15-upgrade-blink-cmp
status: passed
accepted: 2026-07-15
round: 1
---

# Neovim 0.12.4 与 blink.cmp v1.10.2 升级验收报告

> 阶段：阶段 3（验收闭环）
> 验收日期：2026-07-15
> 关联方案 doc：`.codestable/features/2026-07-15-upgrade-blink-cmp/upgrade-blink-cmp-design.md`

## 1. 接口契约核对

**接口示例逐项核对**：

- [x] 隔离运行时选择性更新：`lazy-lock.json` 唯一变化 key 为 `blink.cmp`，commit 为 `78336bc89ee5365633bcf754d93df01678b5c08f`。
- [x] 错误路径：cold-start、matcher、notification、UI、rollback 任一失败均产生非零退出或阻塞证据；未关闭检查绕过。

**名词层“现状 → 变化”逐项核对**：

- [x] 宿主从 apt `0.12.0-dev` 切换到官方 `0.12.4` Release；旧 apt 包与历史 opt 目录已删除。
- [x] blink.cmp 从 v0.14.2 lock 升至 v1.10.2 peeled commit；stable spec pin 为 `1.10.2`。
- [x] 无新增公共 module interface、seam 或 adapter。

**流程图核对**：

- [x] 官方 binary 验证、PATH 切换、apt 删除、target update、lock guard、smoke/health/UI、rollback、acceptance cleanup 均有实现证据。

## 2. 行为与决策核对

**需求摘要逐项验证**：

- [x] `~/.local/bin/nvim --version` 为 `NVIM v0.12.4`、`Build type: Release`。
- [x] `~/.local/bin/nvim` realpath 为 `~/.local/opt/nvim/bin/nvim`，PATH 按 realpath 去重只有一个实体。
- [x] blink.cmp stable spec 与 lock 精确固定 v1.10.2，target runtime 已完成全场景验证。

**明确不做逐项核对**：

- [x] 未跟踪 blink main、未启用本地 Rust build、未全量升级其他插件。
- [x] 未重设计 sources、snippet、UI 或 cmdline 左右键；`<C-y>` 仅补官方 fallback 链，保持有候选接受/无候选原生语义。
- [x] 未保留 apt dev 包、`~/.local/opt/nvim-*` 历史目录或第二套 canonical binary。

**关键决策落地**：

- [x] 精确 pin、target/rollback XDG 隔离、Rust matcher 不降级、单版本安装布局均与 design 一致。
- [x] target 与 rollback 在清理前分别断言 v1.10.2/v0.14.2，rollback 强制加载通过。

**挂载点反向核对**：

- [x] `lazy-lock.json` 的 `blink.cmp` 条目与 `blink.lua` 的 stable spec 是全部持久化挂载点；`git diff`/`rg` 未发现清单外 production 引用。
- [x] 拔除沙盘：恢复旧 lock + stable spec 后执行 Lazy restore 可回到 v0.14.2；独立 rollback 已实演。

## 3. 验收场景核对

- [x] S1 宿主：官方 API/asset digest、SHA256、架构、Release、realpath/PATH、apt absence 全通过。
- [x] S2 选择性升级：唯一 lock key 为 blink.cmp，精确 commit 通过。
- [x] S3 cold-start：Neovim/stdpath/ShawnVim/lazy/blink/Notifications/messages 通过；大小写混合 WARN 注入返回 1。
- [x] S4 matcher：Rust implementation 与 checkhealth 两条正向文案通过，无 Lua fallback。
- [x] S5 Insert sources：真实 UI 取得 buffer/path/snippets/LSP/lazydev 的 `source_id + label`。
- [x] S6 cmdline：`: / ?` 候选可见时左右键保持原生光标移动。
- [x] S7 lazydev：真实 UI 取得 `lazydev:snacks`。
- [x] S8 snippet/fallback：snippet 与 LSP 接受通过，Tab placeholder 前进；单次 `<C-y>` 精确得到 `zbz`。
- [x] S9 rollback：独立 v0.14.2 checkout 强制加载通过，target 保持 v1.10.2，apt 未恢复。
- [x] S10 失败/清洁度：非零失败注入有效；acceptance 最后删除全部临时 XDG、tarball、venv、fixture/output。

**review 与 accept-inline 重点复核**：

- [x] review 为 `passed`，REV-001..004 已 focused closure，无 unresolved blocking。
- [x] Inline Verification Matrix 覆盖 design 10 个场景与 review QA focus；failed/blocked 为 none。
- [x] residual risks 未承载核心验收缺口。

## 4. 术语一致性

- 目标版本、宿主版本、选择性升级、隔离运行时、行为基线等术语在 design/checklist/evidence/代码中一致。
- `rg` 确认 production 只使用 `version = ... "1.10.2"` 与目标 lock commit；无第二套升级概念或禁用检查的命名。

## 5. 领域影响盘点

- [x] 新名词：none；本次是内部工具链/依赖升级，不新增领域实体或公开契约。
- [x] 结构性选择：安装布局和版本 pin 已由 feature design 约束，但不构成项目长期架构 ADR。
- [x] 流程级约束：无跨 feature 的新业务错误语义、并发或扩展点规约；无需 `cs-domain`。

## 6. requirement delta / clarification 回写

- `requirement` 为空；本次更新现有编辑器宿主和补全依赖，不新增用户能力边界、用户故事或 pitch。
- 结论：无 requirement 影响，不生成 req delta/backfill。

## 7. roadmap 回写

- design 无 `roadmap` / `roadmap_item`；非 roadmap 起头，跳过。

## 8. attention.md 候选盘点

- 候选：Neovim 的 `stdpath()` 会在自定义 XDG root 后追加 `/nvim`；隔离验证命令必须按实际 appname 路径断言。
- 其他经验更适合 learning：checkhealth 是 nofile buffer，需读取 lines 后 `writefile()`；lazydev `attached[buf]` 保存 buffer number 而非 boolean。
- 本验收不直接修改 attention/compound，退出时交由用户决定是否沉淀。

## 9. 遗留

- 已知限制：未实机覆盖 Neovim 0.11.2；当前目标宿主为已验证的 0.12.4。
- 已知限制：Rust matcher 慢网/下载失败重试未做故障注入；正常下载、15 秒等待与 health 正向证据已通过。
- 操作交接：日常 `~/.local/share/nvim` 在 feature 合并前故意保持 v0.14.2；合并后需对日常 runtime 执行精确 Lazy restore/update，再复验 checkout 为 v1.10.2。
- 后续优化/顺手发现：none。

## 10. 最终审计

- 验证证据来源：accept-inline verification；implementation/review-fix evidence。
- Evidence sources：`upgrade-blink-cmp-implementation.md`、`upgrade-blink-cmp-review-fix.md`、`upgrade-blink-cmp-review.md`。

### Inline Verification Matrix

| ID | 来源 | 核心性 | 命令或动作 | 结果 |
|---|---|---|---|---|
| AV-01 | Host/runtime | core | CMD-000 + `nvim --version` | passed |
| AV-02 | Lock/spec | core | CMD-003 merge-base JSON guard | passed |
| AV-03 | Cold-start/errors | core | CMD-002/CMD-005 + mixed-case WARN injection | passed；正常 0、注入 1 |
| AV-04 | Matcher | core | CMD-004 checkhealth + Rust assertion | passed |
| AV-05 | Insert sources | core | pynvim UI public completion list | passed |
| AV-06 | Accept/fallback/cmdline | core | pynvim UI single-key and cursor assertions | passed |
| AV-07 | Rollback | core | isolated v0.14.2 restore/load + dual HEAD assertions | passed |
| AV-08 | Cleanliness | core | git/YAML/diff + final absence assertions | passed |

- 聚合命令：YAML parse、CMD-000..005、`git diff --check`、Lua parse、UI smoke、target/rollback HEAD、cleanup absence assertions 均为退出码 0；负向 notification 注入均为退出码 1。
- 场景复核：re-verified 10 / trust-prior-verify 0。
- 交付物复核：Neovim 0.12.4 binary、symlink、blink spec、lock、design/checklist/implementation/review/acceptance 均存在；无 schema/路由/requirement/roadmap 交付物。
- 完整工作区复核：tracked 与 untracked 均属于 feature；仓库根目录无 `Untitled`/fixture；临时 XDG、tarball、venv/output 已删除。
- diff 清洁度：通过；无 debug、TODO/FIXME、注释掉代码、无关 lock key 或方案外 production 文件。
- 知识沉淀出口：1 条 attention 候选、2 条 learning 候选已在第 8 节分流。
- 结论：技术验收通过；等待用户终审后进入 scoped commit/finish/merge，并在 merge 后同步日常 blink checkout。
