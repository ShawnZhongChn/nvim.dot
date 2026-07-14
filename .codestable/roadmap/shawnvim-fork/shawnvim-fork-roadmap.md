---
doc_type: roadmap
slug: shawnvim-fork
status: active
created: 2026-07-14
last_reviewed: 2026-07-14
tags: [neovim, distribution, fork, lazyvim, shawnvim]
related_requirements: [nvim-dot]
related_architecture: [ARCHITECTURE]
---

# ShawnVim 独立发行版分叉

## 1. 背景

当前 `nvim.dot` 是一套从 kickstart.nvim 演进而来的个人配置。新的目标不是在现有配置上安装 LazyVim starter，也不是继续把 `LazyVim/LazyVim` 当作远程插件，而是以 LazyVim 16.0.0 的源码快照为新基线，建立名为 **ShawnVim** 的独立 Neovim 发行版与个人配置。

分叉后，ShawnVim 核心源码直接位于本仓库的 `lua/shawnvim/` 并由 `~/.config/nvim` 运行；运行时只把 `lazy.nvim` 当作通用插件管理器，不下载、不加载、不引用 `LazyVim/LazyVim`。后续功能、默认值、extras、测试和发布均在本仓库独立演进。

基线事实：规划时 LazyVim `main` 的源码快照为 `459a4c3b1059671e766a46c7cc223827dc67e3d0`，内部版本为 `16.0.0`，许可证为 Apache-2.0；官方开发文档仓库当前快照为 `85e5b49e5bf0a4208bd9d1600e1710f4bb6c0e9c`，本次选取其中 138 个 Markdown 文件，明确不复制 3 个 `_category_.yml` 文件。

## 2. 范围与明确不做

### 本 roadmap 覆盖

- 在任何替换动作前，把当前领先远端的 6 个提交和 4 个未提交代码修改保存为可恢复的 Git 历史，并建立明确的 legacy 锚点。
- 按显式 import manifest 导入 LazyVim 核心源码快照、默认插件 specs、extras、queries、测试与成套开发资产，并为 ShawnVim 新建独立 news/changelog。
- 在用户已确认持有转载权的前提下，完整接收官方文档快照中选定的 138 个 Markdown，记录逐文件来源/hash/变换，并适配为 ShawnVim 0.1.0 的版本化开发文档。
- 将运行时 Lua 命名空间从 `lazyvim` 改为 `shawnvim`，全局 API 从 `LazyVim` 改为 `ShawnVim`。
- 将用户可见品牌、命令、health、augroup、状态文件和配置变量改为 ShawnVim 身份。
- 用本地 self-spec 启动 ShawnVim，移除 `LazyVim/LazyVim` 远程插件依赖和 starter 依赖。
- 用新的 `init.lua`、`lua/config/` 与 `lua/plugins/` 接管 `~/.config/nvim`，删除旧配置运行时文件，默认从 ShawnVim 基线启动。
- 源码导入时同步用 Apache-2.0 `LICENSE` 替换现有 MIT `LICENSE.md`，保留上游归属并记录固定快照及变更边界，但不配置上游 remote、submodule 或自动同步。
- 适配本地测试、格式化、静态检查和 GitHub CI，并完成隔离首次安装与 headless 启动验证。
- 更新安装、开发、架构与迁移说明，提交并同步至现有 `origin` 仓库。

### 明确不做

- 不迁移旧 `lua/custom/`、`lua/core/` 或 `after/ftplugin/` 中的个人行为到 ShawnVim；Git 历史负责保留它们，避免把旧实现混入新基线。
- 不保持与 LazyVim 上游的 Git remote、submodule、自动 merge 或持续同步关系；未来如需手工借鉴上游，另行设计流程。
- 不在首次分叉中新增超出 LazyVim 默认基线的语言 extras、主题或个人快捷键。
- 不把 `lazy.nvim` 自身源码 vendor 进仓库；它仍通过独立、通用的 bootstrap 安装。
- 不导入文档网站的 Docusaurus/Yarn/React 构建工程、部署 workflow 或站点品牌资产；本次交付是版本化开发文档内容，不是 ShawnVim 文档网站。
- 不删除历史 `.codestable/features/`、issues 或旧提交；这些内容保留为项目演进证据，现状文档在 cutover 后更新。

### Granularity Gate

| 判断项 | 结论 |
|---|---|
| 为什么不是 single feature | 涉及 Git 历史保护、数百个源码文件与 138 个 Markdown 文档的版本化分叉、启动架构切换、开发测试体系和发布同步，且各阶段需要独立回滚与验证。 |
| 为什么不是 brainstorm | 目标、品牌、切割边界和成功标准已经明确；核心技术选择可由仓库事实验证。 |
| roadmap 边界 | 只完成 LazyVim 源码到 ShawnVim 独立发行版的首次分叉与仓库接管，不迁移旧个性化行为。 |
| 最小闭环 | `shawnvim-core-fork` 完成后，隔离测试入口可只加载本仓库的 `shawnvim` 核心与默认 specs，且 lazy.nvim spec 中没有 `LazyVim/LazyVim`。 |

## 3. 模块拆分（概设）

```text
ShawnVim fork
├── Legacy Safety：保存当前工作树、提交历史与可恢复锚点
├── Distribution Core：shawnvim 命名空间、默认 specs、extras 与核心 API
├── Config Shell：init/bootstrap、用户 overrides、状态文件与本地 self-spec
├── Documentation Baseline：固定官方文档快照并适配 ShawnVim 0.1.0
└── Verification & Release：测试、CI、许可证、文档审计与 Git 同步
```

### 3.1 Legacy Safety · 旧配置安全层

- **职责**：在大规模替换前保存当前 tracked/untracked 状态，记录 legacy commit/tag 与恢复方法；不参与新运行时。
- **承载的子 feature**：`legacy-config-snapshot`
- **触碰的现有代码 / 模块**：当前 Git 工作树、`master` 历史、迁移说明。
- **Depth 判断**：这是一次性迁移边界，不抽象通用备份框架；一个可验证 commit 与一个 annotated tag 足以隐藏恢复细节。

### 3.2 Distribution Core · 发行版核心

- **职责**：承载由 LazyVim 16.0.0 分叉而来的默认行为、插件 specs、extras、工具 API、health 与 queries；对其他模块只暴露 `shawnvim` Lua 命名空间与 `_G.ShawnVim`。
- **承载的子 feature**：`shawnvim-core-fork`
- **触碰的现有代码 / 模块**：新增 `lua/shawnvim/`、`queries/`、`doc/ShawnVim.txt`、`NEWS.md`、`CHANGELOG.md`；`tests/minit.lua` 只提供本地 self-spec 与 namespace/spec smoke assertions；同批落地 `LICENSE`、`UPSTREAM.md` 和开发配置。
- **Depth 判断**：deep module。插件选择、默认值、extras 发现、格式化、LSP、root 与 UI 策略均隐藏在 `require("shawnvim")` 和 specs import 背后；调用方不感知上游原命名空间。

### 3.3 Config Shell · 配置壳层

- **职责**：作为真实 `~/.config/nvim` 入口 bootstrap lazy.nvim，按固定顺序导入 ShawnVim 核心、extras 和用户 overrides；持有少量用户可编辑文件。
- **承载的子 feature**：`shawnvim-config-cutover`
- **触碰的现有代码 / 模块**：重写 `init.lua`，新增/重置 `lua/config/`、`lua/plugins/`、`shawnvim.json`，删除旧 `lua/core/`、`lua/custom/`、`after/` 和旧辅助运行时。
- **Depth 判断**：薄但必要的 composition root，不承载业务逻辑；它是 Neovim 与 Distribution Core 之间唯一启动 seam，不再增加第二层透传 wrapper。

### 3.4 Documentation Baseline · 开发文档基线层

- **职责**：把固定官方文档快照中选定的 138 个 Markdown 完整接收到版本化目录，保留逐文件 provenance，把配置/API/插件/extras/keymaps 等当前用法适配为 ShawnVim 0.1.0；上游新闻历史保持原文且明确隔离。
- **承载的子 feature**：`shawnvim-development-docs`
- **触碰的现有代码 / 模块**：新增 `docs/development/0.1.0/`、`UPSTREAM-DOCS.md` 与机器可读 `SOURCE.json`；读取 `lua/shawnvim/` 核对代码链接和生成型参考。
- **Depth 判断**：版本目录是独立、可冻结的文档 module；它隐藏来源路径、品牌变换和代码链接校准细节，对用户只暴露 ShawnVim 0.1.0 的导航入口。Docusaurus 站点工程不进入该 module。

### 3.5 Verification & Release · 验证与发布层

- **职责**：证明源码分叉在干净环境可安装、启动和测试，提供独立 CI、许可证归属、开发说明及远端同步证据。
- **承载的子 feature**：`shawnvim-release-hardening`
- **触碰的现有代码 / 模块**：除 core smoke 以外的 `tests/`、`scripts/test`、`.github/workflows/ci.yml`、`README.md`、`CONTRIBUTING.md`、identity/lockfile/docs audit 与 Git remote。
- **Depth 判断**：验证入口集中封装环境隔离和命令细节；CI 调用同一脚本，不另造与本地不同的测试路径。

## 4. 模块间接口契约 / 共享协议（架构层详设）

### 4.1 ShawnVim Core Module Contract

**方向**：Config Shell → Distribution Core
**形式**：Lua module API + lazy.nvim spec import

**契约**：

```lua
---@class ShawnVimConfig
local ShawnVim = require("shawnvim")

ShawnVim.setup(opts)

-- lazy.nvim import roots
{ import = "shawnvim.plugins" }
{ import = "shawnvim.plugins.extras.<category>.<name>" }
```

核心初始化后必须满足：

```lua
_G.ShawnVim ~= nil
package.loaded["shawnvim.config"] ~= nil
ShawnVim.config.version == "0.1.0"
type(ShawnVim.config.json.version) == "number" -- 独立 state schema，不是发行版本
```

**约束**：

- 运行时代码不得 `require("lazyvim...")` 或 import `lazyvim.plugins...`。
- 默认 spec 不得包含 `"LazyVim/LazyVim"` 或 `"LazyVim/starter"`。
- `lua/shawnvim/plugins/init.lua` 必须声明本地 self-spec：`dir = vim.g.shawnvim_root or vim.fn.stdpath("config")`、`name = "ShawnVim"`、`lazy = false`、高优先级，并通过 `opts = {}` 触发 `require("shawnvim").setup(opts)`。
- `vim.g.shawnvim_root` 只允许隔离测试/开发入口在 import 前设置；正常配置不设置它，生产路径固定使用 `stdpath("config")`。
- 上游 `M.version = "16.0.0"` 必须改为 `ShawnVim.config.version == "0.1.0"`；core smoke 必须断言该值，不能只靠 identity audit 检查品牌字符串。
- Neovim 最低版本继承源码快照的 `>= 0.11.2` 要求，不沿用旧配置文档中的 `>= 0.10.0`。

**Interface 设计检查**：

- **Module / interface**：`shawnvim` 暴露一个 `setup(opts)` 入口；调用方只需知道 import 顺序和可选配置表。
- **Seam placement**：seam 位于 lazy.nvim 的本地 self-spec；插件生命周期、opts merge 与加载顺序都穿过 lazy.nvim 的标准机制。
- **Depth / locality**：命名空间、默认插件和 extras 的变化集中在 `lua/shawnvim/`，Config Shell 保持稳定。
- **Dependency strategy**：in-process；不需要 adapter 或 test double，测试直接导入本地目录。
- **Adapter**：无。再包装一层 adapter 只会形成 pass-through module。

**Design It Twice 结论**：

- 候选 A：在 `init.lua` 手工调用 `require("shawnvim").setup()`，再让 lazy.nvim 导入默认 plugins。
- 候选 B：把配置根声明为 lazy.nvim 本地 self-spec，由 lazy.nvim 调用 `setup(opts)`。
- 选择 B，因为它保留上游源码对 plugin lifecycle、opts 和 import order 的不变量，测试也能使用同一个入口；A 会产生一条仅生产环境存在的额外初始化路径。

### 4.2 Namespace and State Contract

**方向**：Distribution Core ↔ Config Shell / 用户
**形式**：Lua globals、Vim commands、JSON 文件与 Vim globals

| 原身份 | ShawnVim 身份 |
|---|---|
| `lua/lazyvim/**` | `lua/shawnvim/**` |
| `_G.LazyVim` | `_G.ShawnVim` |
| `LazyVim*` LuaDoc types | `ShawnVim*` |
| `LazyExtras` | `ShawnExtras` |
| `LazyHealth` | `ShawnHealth` |
| `lazyvim.json` | `shawnvim.json` |
| `vim.g.lazyvim_json` | `vim.g.shawnvim_json` |
| `vim.g.lazyvim_check_order` | `vim.g.shawnvim_check_order` |
| 其他 `vim.g.lazyvim_*` / `LazyVim*` events | 对应 `vim.g.shawnvim_*` / `ShawnVim*` events |
| `checkhealth lazyvim` | `checkhealth shawnvim` |
| `doc/LazyVim.txt` | `doc/ShawnVim.txt` |

**约束**：

- 兼容 alias 不在首次分叉范围内；旧名字出现即视为迁移遗漏。identity audit 对所有 tracked path 和内容做大小写不敏感的 `lazyvim` 检查，仅 allowlist `UPSTREAM.md`、`UPSTREAM-DOCS.md`、`docs/development/0.1.0/SOURCE.json`、`docs/development/0.1.0/upstream/lazyvim-news.md`、`.codestable/` 历史/规划证据，以及 `UPSTREAM-SOURCE.json` 的精确 JSON Pointer `/source_repository`、`/source_files/*/source`、`/excluded_files/*/source`；`destination`、`transform`、`generated_files`、modification notice字段和值不得豁免。其余运行时、working docs、tests、scripts、CI、文件名、health/plugin identity、events、globals 和状态字段不得豁免。
- 状态迁移不读取旧 `lazyvim.json`；ShawnVim 首次启动建立自己的 `shawnvim.json` 状态。
- 上游源码/文档仓库 URL 只允许出现在 `UPSTREAM.md`、`UPSTREAM-DOCS.md`、版本化文档的 `SOURCE.json`、许可证/归属说明与明确标注的历史参考中，不得参与运行时解析。

**Interface 设计检查**：

- **Module / interface**：全局 API 与状态 schema 属于 Distribution Core；用户只通过新身份交互。
- **Seam placement**：文件名和 global 名称是持久化边界，必须在 cutover 时一次切换，不能双写。
- **Depth / locality**：所有身份映射可由仓库级搜索与启动测试验证。
- **Dependency strategy**：in-process + local filesystem state。
- **Adapter**：无；不提供旧名兼容层，符合与 LazyVim 切割目标。

### 4.3 Config Import Order Contract

**方向**：Config Shell → lazy.nvim → Distribution Core / 用户 overrides
**形式**：lazy.nvim setup spec 顺序

```lua
require("lazy").setup({
  spec = {
    { import = "shawnvim.plugins" },
    -- shawnvim.json 中启用的 shawnvim.plugins.extras.* 由 core 处理
    { import = "plugins" },
  },
})
```

**约束**：

- `shawnvim.plugins` 必须是第一个 distribution import；用户 `plugins` 必须在 extras 之后。
- `lua/config/options.lua`、`keymaps.lua`、`autocmds.lua` 仅承载用户覆盖，不复制核心默认实现。
- 首次 cutover 的用户覆盖保持为空或仅含注释，以保证实际行为就是 ShawnVim 源码基线。
- bootstrap 只下载 `folke/lazy.nvim`；不得 clone LazyVim 或 starter。
- `lazy-lock.json` 是可复现配置资产：cutover 必须从 `.gitignore` 移除对应 ignore 并强制纳入 Git。

**Interface 设计检查**：

- **Module / interface**：Config Shell 是 composition root，暴露固定顺序而非通用 import registry。
- **Seam placement**：唯一 seam 位于根 `init.lua`，便于首次安装和测试定位。
- **Depth / locality**：用户改动集中在 `lua/config/` 与 `lua/plugins/`，核心演进集中在 `lua/shawnvim/`。
- **Dependency strategy**：lazy.nvim 是 true external Git dependency；用隔离 data dir 验证 bootstrap。
- **Adapter**：生产与测试都执行同一 bootstrap/import 逻辑，测试只替换 stdpath 根，不替换核心逻辑。

### 4.4 Source Provenance Contract

**方向**：上游源码快照 → ShawnVim 仓库
**形式**：Git history + `UPSTREAM.md` + Apache-2.0 license

```text
upstream_source_repository: https://github.com/LazyVim/LazyVim
upstream_source_commit: 459a4c3b1059671e766a46c7cc223827dc67e3d0
upstream_source_version: 16.0.0
upstream_docs_repository: https://github.com/LazyVim/lazyvim.github.io
upstream_docs_commit: 85e5b49e5bf0a4208bd9d1600e1710f4bb6c0e9c
imported_at: 2026-07-14
ongoing_git_relationship: none
shawnvim_initial_version: 0.1.0
```

**约束**：

- Apache-2.0 `LICENSE`、`UPSTREAM.md` 与导入源码必须处于同一个 core feature/commit；删除现有 MIT `LICENSE.md`，避免源码双许可证歧义。根 Apache-2.0 只覆盖导入的 Apache 源码及 ShawnVim 明确原创内容；替换前历史提交中的自有代码仍按其当时声明保留历史许可事实。
- 按 Apache-2.0 §4(b)，每个被改写的上游源码文件必须带对应语言可识别的显著 ShawnVim 修改通知并指向 `UPSTREAM.md`；`source_files[]` 每项记录 `modified` 与 `modification_notice {status, kind, locator, marker_sha256}`，audit 按 locator/marker逐文件验证。仅 source/destination hash相等、transform为空且notice status为`unmodified`的原样文件可标记未修改；不能用顶层总声明代替逐文件状态。
- 文档仓库未声明独立 LICENSE；项目 owner 已于 2026-07-14 明确确认持有转载权。转载/适配的 `docs/development/0.1.0/**` 不受根 Apache-2.0 自动覆盖，其原版权归属、授权事实和下游再使用条件以 `UPSTREAM-DOCS.md` 为准；README 的许可证说明必须重复该边界。
- `origin` 继续只指向用户现有仓库；不得新增名为 upstream 的 remote。
- 旧配置快照必须先提交，再用 annotated tag `legacy-nvim-config-2026-07-14` 指向该提交；替换后可从 tag 恢复，最终同步时显式把该 tag 推送到 origin。
- ShawnVim 不继承 LazyVim 的发布版本号；首次独立版本为 `0.1.0`。运行时 JSON schema 版本可保留技术兼容所需的独立整数，但不得当作发行版本展示。
- release validation 采用两阶段提交：先创建包含code/config/docs/tests payload的immutable candidate并按精确SHA通过CI，再在该candidate创建annotated tag `v0.1.0`；publish evidence与roadmap completion进入只改`.codestable/`的post-release admin commit，最终master可领先tag一个管理提交。首次 epic 不创建 GitHub Release。

**Interface 设计检查**：

- **Module / interface**：这是审计契约，不参与运行时。
- **Seam placement**：Git commit/tag 是不可变恢复 seam，`UPSTREAM.md` 是源码归属 seam。
- **Depth / locality**：恢复与归属信息不散落到实现文件中。
- **Dependency strategy**：一次性源码导入，不存在运行时或 Git 依赖。
- **Adapter**：无。

### 4.5 Source Import Manifest

**方向**：固定上游快照 → ShawnVim 各交付层
**形式**：路径分类与变换规则

| 分类 | 导入资产 | 处理 |
|---|---|---|
| runtime-required | `lua/lazyvim/**`, `queries/**` | 移至/改写 ShawnVim namespace 与品牌 |
| ShawnVim history | 新 `NEWS.md`, 新 `CHANGELOG.md` | 不复制或机械改牌上游历史；只记录 `0.1.0` 首次分叉事实与后续 ShawnVim 变化 |
| core smoke | `tests/minit.lua` 与最小 namespace/spec assertions | 去除 starter，设置 `vim.g.shawnvim_root = vim.uv.cwd()`，验证本地 self-spec、`ShawnVim.config.version == "0.1.0"` 与 news/changelog 路径解析 |
| test/dev | 其余 `tests/**`, `scripts/test`, `stylua.toml`, `selene.toml`, `vim.yml`, `.editorconfig`, `.neoconf.json` | 在 release hardening 中适配/执行；采用上游 120 列、双引号/默认括号 Stylua 基线 |
| docs/provenance | `LICENSE`, `doc/LazyVim.txt`, README/CONTRIBUTING 所需事实 | LICENSE 原文保留；doc 改为 `ShawnVim.txt`；README/CONTRIBUTING 重写；新增 `UPSTREAM.md` |
| explicitly dropped | 上游翻译 README、release-please、labeler/stale/update workflow、上游 issue/PR 模板 | 不属于首次独立运行或最小开发闭环，不导入 |

**约束**：

- core import 必须保存机器可核对的固定 commit、路径分类和结构化 rename 说明，不能只依赖最终大 diff 推断来源。
- `UPSTREAM-SOURCE.json.source_files[]` 必须记录 source/destination双hash、transform、`modified`和结构化`modification_notice`；identity audit只按§4.2列出的精确JSON Pointer放行provenance值。
- core minit使用固定lazy.nvim bootstrap commit `306a05526ada86a7b30af95c5cc81ffba93fef97`，不得动态读取`main`。
- 源码只做 namespace/brand/self-spec 必需变换，不在首次导入顺手应用现有个人格式规则或功能重写。
- 根格式配置改用上游 `stylua.toml` 基线并删除旧 `.stylua.toml`；cutover acceptance 同步更新 attention。
- 新 `NEWS.md` / `CHANGELOG.md` 必须随 core 落地，保持默认 news/changelog API 行为；完整上游历史只由 `UPSTREAM.md` 链接固定仓库/commit，不复制、不改牌、不伪装成 ShawnVim 历史。

### 4.6 Versioned Development Docs Contract

**方向**：固定官方文档快照 + Distribution Core → ShawnVim 0.1.0 开发文档
**形式**：版本化 Markdown 文档树 + provenance manifest

**来源与落点**：

```text
source_repository: https://github.com/LazyVim/lazyvim.github.io
source_commit: 85e5b49e5bf0a4208bd9d1600e1710f4bb6c0e9c
source_markdown_files: 138
source_filter: docs/<recursive>/*.md
destination: docs/development/0.1.0/
manifest: docs/development/0.1.0/SOURCE.json
```

`SOURCE.json` schema：

```json
{
  "source_repository": "https://github.com/LazyVim/lazyvim.github.io",
  "source_commit": "85e5b49e5bf0a4208bd9d1600e1710f4bb6c0e9c",
  "source_markdown_files": 138,
  "source_filter": "docs/<recursive>/*.md",
  "calibrated_core_commit": "<ancestor core commit>",
  "calibrated_core_manifest_sha256": "<UPSTREAM-SOURCE.json sha256>",
  "calibrated_core_tree_sha256": "<lua/shawnvim+doc/ShawnVim.txt digest>",
  "copied_at": "2026-07-14",
  "redistribution_basis": "project owner confirmed redistribution rights",
  "source_files": [
    {
      "source": "docs/configuration/general.md",
      "destination": "docs/development/0.1.0/configuration/general.md",
      "source_sha256": "<sha256>",
      "destination_sha256": "<sha256>",
      "transform": {
        "operations": [
          {
            "kind": "identity-rewrite",
            "input_sha256": "<sha256>",
            "output_sha256": "<sha256>",
            "selector": { "type": "exact-literal", "value": "<source literal>" },
            "parameters": { "replacement": "<destination literal>" },
            "reason": "ShawnVim identity calibration"
          }
        ]
      },
      "tab_groups": [
        {
          "group_ordinal": 1,
          "group_context": "<parent heading path>",
          "source_branches": [
            { "branch_ordinal": 1, "label": "lazy.nvim", "body_sha256": "<sha256>" }
          ],
          "destination_branches": [
            { "branch_ordinal": 1, "heading": "lazy.nvim", "body_sha256": "<sha256>" }
          ]
        }
      ]
    }
  ],
  "generated_files": [
    {
      "destination": "docs/development/0.1.0/news.md",
      "destination_sha256": "<sha256>",
      "origin": "shawnvim-original"
    }
  ],
  "excluded_upstream_files": [
    { "source": "docs/configuration/_category_.yml", "reason": "non-markdown-out-of-scope" },
    { "source": "docs/extras/_category_.yml", "reason": "non-markdown-out-of-scope" },
    { "source": "docs/plugins/_category_.yml", "reason": "non-markdown-out-of-scope" }
  ],
  "site_assets_imported": []
}
```

**约束**：

- 官方 `docs/` 树中选定的 138 个 Markdown 文件必须全部在 `source_files` 中有且仅有一条记录；3 个 `_category_.yml` 明确不复制。每条 Markdown 保存上游内容 SHA-256 和最终目标 SHA-256，不能用“目录已复制”代替逐文件证据。新增 ShawnVim 文件只进入 `generated_files`，不得混入 138 条来源 bijection。
- `excluded_upstream_files` 只记录三份 `_category_.yml` 及 `non-markdown-out-of-scope` 理由，不产生 destination，也不参与 source bijection。
- 配置、安装、plugin、extras、keymaps、tips/recipes 等 working docs 落入相同相对路径，并把 Lua namespace、commands、repo links、版本和代码链接适配为 ShawnVim 0.1.0；所有代码链接必须核对 `lua/shawnvim/` 真实路径。
- 上游 `docs/news.md` 不机械改牌：原文保存为 `docs/development/0.1.0/upstream/lazyvim-news.md`，manifest 标记 `verbatim-upstream-history`；working `docs/development/0.1.0/news.md` 只索引 ShawnVim `NEWS.md` / `CHANGELOG.md` 与该上游历史。
- MDX/Docusaurus 专用 import、JSX component、Tabs/TabItem 和 admonition 必须转换为仓库内可读的普通 Markdown：Tabs 的每个分支变成带原 label 的 heading/section，admonition 变成带粗体类型标签的 blockquote，不能丢失分支正文。
- 固定snapshot中125个Tabs文件、487个groups、975个branches按`group_ordinal + parent heading context + branch_ordinal`唯一映射；source/target groups/branches数量、顺序、规范化label一致。wrapper-only structural intermediate的规范化正文hash必须等于source；后续calibration由受限operations逐步重放。
- `transform.operations` 只允许`move-verbatim`、`strip-esm-import`、`tabs-to-sections`、`admonition-to-blockquote`、`asset-to-text`、`identity-rewrite`、`link-rewrite`、`core-reconcile`；每步带完整文档input/output hash、selector/parameters/reason，禁止无precondition的whole-file replacement。`core-reconcile`必须带旧/新block hash和core证据路径。
- Tabs 正文 hash 的规范化固定为：统一 LF，移除结构 wrapper 与首尾空行，保留正文内部空白和内容；source/target 使用同一实现，避免不同工具产生不可比 hash。
- 文档 feature 必须提供并运行忽略 fenced/inline code 的全树静态审计：working Markdown 中禁止残留 ESM `import/export`、`@theme/*`、`<Tabs>`/`<TabItem>` 或其他大写 JSX component、行首 `:::` Docusaurus admonition、未处理的 `/img/` 站点绝对路径。
- 所有Docusaurus root-relative/extensionless routes必须改为目标相对`.md`链接；fragment按GitHub`github-slugger`兼容算法校验，audit fixtures覆盖Unicode/emoji、标点、大小写和重复heading suffix。所有本地链接与图片引用必须解析到版本目录内真实目标。本快照不导入docs tree外的`/img/logo.svg`：`intro.md`的LogoSvg import/展示改为普通Markdown标题与文字，`site_assets_imported`保持空数组。
- 不复制 docs repo 根部的 `package.json`、Yarn/Docusaurus 配置、`src/`、完整 `static/`、部署 workflows 或构建脚本；未来建设 ShawnVim 文档站另开 feature。
- 除明确 allowlist 的 provenance/upstream history 外，working docs 不得出现旧 namespace、旧 commands、旧 repo 安装指令或把 LazyVim 历史版本伪装为 ShawnVim。
- 文档快照commit与源码commit是两个独立provenance锚点；`calibrated_core_commit`必须是当前HEAD祖先，`UPSTREAM-SOURCE.json` hash与核心事实路径稳定tree digest必须保持一致。对plugin/extras/generated-style页面，以ShawnVim core事实为最终正确性来源，任何校准都记录在受限`transform.operations`。
- 上游`docs/news.md`只允许以`move-verbatim`映射到`upstream/lazyvim-news.md`，source/destination bytes与SHA-256必须相等；另有唯一generated working `news.md`，因此版本目录为138个source destinations + 1个generated Markdown = 139个Markdown。

**Interface 设计检查**：

- **Module / interface**：版本目录暴露静态开发文档；`SOURCE.json` 暴露可审计 provenance，`scripts/audit-docs` 暴露可重复的完整性/MDX/link gate，不把复制逻辑泄漏给读者。
- **Seam placement**：来源/变换 seam 位于逐文件 manifest，代码事实 seam 位于 `lua/shawnvim/`；后续版本不会静默改写 0.1.0 文档。
- **Depth / locality**：品牌适配、历史隔离、MDX 降级和代码链接校准集中在该 feature，release 只消费审计结果。
- **Dependency strategy**：一次性 Git snapshot；无 remote、submodule 或运行时依赖。
- **Adapter**：无站点 adapter。本次只交付 Markdown 内容，避免引入单一 Docusaurus adapter 形成额外维护面。

## 5. 子 feature 清单

1. **legacy-config-snapshot** — 把当前 6 个未推送提交、4 个未提交代码修改及 CodeStable runtime 刷新保存为可恢复 commit，并建立 annotated legacy tag。
   - 所属模块：Legacy Safety
   - 依赖：无
   - 状态：in-progress
   - 对应 feature：`2026-07-14-legacy-config-snapshot`
   - 备注：tag 是包含完整 legacy runtime/worktree 的命名 snapshot；不得丢弃或覆盖当前用户修改，首次 destructive commit 仍须证明它是受保护祖先。

2. **shawnvim-core-fork** — 按 import manifest 导入固定 LazyVim 源码快照，完成 ShawnVim 0.1.0 核心命名空间、本地 self-spec、独立 news/changelog、Apache 许可证/归属和最小 smoke 分叉。
   - 所属模块：Distribution Core
   - 依赖：`legacy-config-snapshot`，因为大规模文件替换前必须已有不可变恢复锚点。
   - 状态：in-progress
   - 对应 feature：`2026-07-14-shawnvim-core-fork`
   - 备注：最小闭环；本 feature 独占 `tests/minit.lua`、本地 self-spec、运行时 `0.1.0` 版本及 news path smoke assertions，隔离 minit 必须直接导入本仓库并证明没有远程 LazyVim 或 starter spec。

3. **shawnvim-development-docs** — 接收固定官方文档快照中的 138 个 Markdown 文件，生成逐文件 provenance/transform manifest，并适配为 ShawnVim 0.1.0 版本化开发文档。
   - 所属模块：Documentation Baseline
   - 依赖：`shawnvim-core-fork`，因为 namespace、commands、extras、代码路径和运行时版本必须以已通过 smoke 的 ShawnVim core 为适配真相。
   - 状态：in-progress
   - 对应 feature：`2026-07-14-shawnvim-development-docs`
   - 备注：项目 owner 已确认转载权；原 LazyVim news 历史保持原文隔离；working docs 通过无 MDX/Docusaurus 残留、链接/资产存在与 core 校准 gate；不导入站点工程。

4. **shawnvim-config-cutover** — 用 ShawnVim bootstrap 与空白用户覆盖层替换现有 Neovim 启动链，删除旧运行时配置并生成新的 state/lock 资产。
   - 所属模块：Config Shell + Distribution Core
   - 依赖：`shawnvim-core-fork`，因为真实配置入口只能切换到已通过隔离加载的本地核心。
   - 状态：in-progress
   - 对应 feature：`2026-07-14-shawnvim-config-cutover`
   - 备注：不得迁移旧个人配置行为；本 feature acceptance 负责更新 attention、requirements 与 architecture 的真实现状描述，并移除 `lazy-lock.json` ignore、提交新 lockfile。

5. **shawnvim-release-hardening** — 在 core smoke 之外适配完整测试脚本与独立 GitHub CI，完成 clean-room 安装、headless 启动、全树 identity/许可证/版本化文档审计，并提交推送 branch、legacy tag 与 `v0.1.0` tag 到现有 origin。
   - 所属模块：Verification & Release
   - 依赖：`shawnvim-config-cutover`、`shawnvim-development-docs`，因为发布验证必须同时针对最终真实入口、清理后的仓库树和完整 0.1.0 文档基线。
   - 状态：in-progress
   - 对应 feature：`2026-07-14-shawnvim-release-hardening`
   - 备注：CI不复用上游reusable workflow，matrix精确覆盖v0.11.2/stable；candidate精确SHA通过CI后创建annotated `v0.1.0`，publish evidence/roadmap completion进入仅改`.codestable/`的admin commit；不建GitHub Release，远端分别核对branch与两个tag的object/peeled OID。

**最小闭环**：第 2 条 `shawnvim-core-fork` 完成后，测试环境已经能通过 lazy.nvim 本地 self-spec 加载 `_G.ShawnVim` 和 `shawnvim.plugins`，且不访问 LazyVim/starter 仓库。

### Goal Coverage Matrix

| Goal / completion signal | Covered by item(s) | Verification entry | Evidence type | Core? |
|---|---|---|---|---|
| 当前个人配置及未提交修改可从不可变 tag 恢复 | `legacy-config-snapshot` | `git show legacy-nvim-config-2026-07-14`、tag target 与替换前 HEAD 核对 | command + Git object | yes |
| 核心源码直接位于本仓库并以 ShawnVim 身份加载 | `shawnvim-core-fork` | isolated `nvim -l tests/minit.lua --minitest`、Lua namespace assertions | test + command | yes |
| 官方当前开发文档的138个Markdown完整进入0.1.0版本目录并可追溯，另有1个generated working news（目标139） | `shawnvim-development-docs` | 138-source/139-target inventory、SOURCE.json双hash/bijection、固定Git source commit | command + manifest + diff review | yes |
| 0.1.0 working docs 脱离 Docusaurus 且 namespace、commands、links 与本地 core 一致 | `shawnvim-development-docs`, `shawnvim-release-hardening` | code-aware MDX residual audit + Tabs branch bijection + identity/link/asset/code-path audit + representative reading review | command + manifest + diff review | yes |
| 运行时不依赖 LazyVim 仓库或 starter | `shawnvim-core-fork`, `shawnvim-release-hardening` | lazy spec dump + `rg` 禁止模式 + isolated network/bootstrap log | test + diff review | yes |
| `~/.config/nvim` 默认启动 ShawnVim 而非旧配置 | `shawnvim-config-cutover` | isolated XDG/NVIM_APPNAME headless startup and `:checkhealth shawnvim` | command + health output | yes |
| 旧个人运行时不再参与加载 | `shawnvim-config-cutover` | tree audit；确认旧 `lua/core`、`lua/custom`、`after/ftplugin` 已删除且启动 trace 无旧 module | command + diff review | yes |
| 命名空间、命令、事件、globals、状态文件、health、文件路径和 docs 完整改名 | `shawnvim-core-fork`, `shawnvim-release-hardening` | 对 tracked paths/content 的大小写不敏感 identity allowlist audit + runtime assertions | test + command | yes |
| 运行时公开版本从上游 16.0.0 切换为 ShawnVim 0.1.0 | `shawnvim-core-fork`, `shawnvim-release-hardening` | `ShawnVim.config.version` smoke assertion + final annotated tag `v0.1.0` | test + Git object | yes |
| 分叉满足许可证归属并可独立二次开发 | `shawnvim-core-fork`, `shawnvim-release-hardening` | core 的 LICENSE/UPSTREAM/import manifest + CONTRIBUTING review；local test and CI use same entry | diff review + CI | yes |
| 公开最低 Neovim 版本真实可用 | `shawnvim-release-hardening` | GitHub CI matrix `v0.11.2` + `stable` | CI | yes |
| 最终提交、legacy tag 与 v0.1.0 tag 已同步到用户现有 Git origin | `shawnvim-release-hardening` | `git status --branch`、`git rev-parse HEAD`/`git rev-parse <tag>` 与 `git ls-remote origin` 比对 | command | yes |

## 6. 排期思路

先建立 legacy commit/tag，降低数百文件替换和命名空间机械改写的回滚风险。随后在不切换真实 `init.lua` 的前提下完成并测试本地 ShawnVim core，这是最窄的端到端闭环：核心已能独立加载，但用户当前编辑器入口仍可恢复。核心通过后，文档适配与真实配置 cutover 可分别推进；release 必须等两者都完成，再以 clean-room 安装、CI、文档完整性审计和远端同步收口。

### 目标完成信号

- 新环境 clone 本仓库到 `~/.config/nvim` 后，只需启动 `nvim` 即可 bootstrap lazy.nvim 并加载 ShawnVim 默认配置。
- `lua/shawnvim/` 是发行版核心的唯一源码位置；运行时没有 LazyVim/starter repo spec 或旧 `lua/custom` 加载路径。
- 用户入口只展示 ShawnVim 品牌：`_G.ShawnVim`、`:ShawnExtras`、`:ShawnHealth`、`shawnvim.json` 与 `:checkhealth shawnvim`。
- `docs/development/0.1.0/` 包含官方当前选定的 138 个 Markdown 源文件的可追溯对应项，working docs 已适配 ShawnVim，原上游 news 历史独立保真；不包含 `_category_.yml`。
- 本地 test script 与 GitHub CI 的 `v0.11.2`、`stable` matrix 通过，且包含禁止旧运行时身份/依赖的自动断言。
- legacy tag 可恢复替换前配置，最终 branch、legacy tag 与 annotated `v0.1.0` 都与现有 origin 同步；本次不创建 GitHub Release。

### Top 3 风险与缓解

1. **机械改名漏掉动态字符串或 lazy.nvim plugin identity，导致启动到中途才报错。** 缓解：分两层搜索（静态 allowlist + runtime spec dump），并使用本地 self-spec 的隔离 minit 和 clean-room 启动双重验证。
2. **替换时覆盖当前 4 个未提交修改或 6 个本地提交。** 缓解：任何删除前先创建 snapshot commit 和 annotated tag，并用 `git show` 验证对象可读。
3. **表面切割或文档机械改名后仍残留错误 namespace、代码链接或伪造历史。** 缓解：core smoke 使用 `shawnvim_root = cwd` 后走同一 local self-spec；文档用逐文件 hash/transform manifest、working docs identity/link audit 和保真 upstream news 隔离；全树审计只对明确 provenance/history 路径与 `.codestable` 证据开放例外。

### 关键假设

- “与 LazyVim 切割”允许保留 Apache-2.0 要求的来源归属与固定上游 URL，但不允许运行时、Git 或 CI 依赖关系。
- 用户要的是 LazyVim 默认行为作为 ShawnVim 首个基线，而不是把旧个人功能迁移到新核心。
- 项目 owner 已明确确认持有 LazyVim 官方文档内容的转载权，允许将固定快照内容纳入并同步到当前 origin；仍需保留来源与原版权归属，不把源码许可证自动套用于文档。
- 现有 `origin` `https://github.com/ShawnZhongChn/nvim.dot.git` 是最终同步目标，`master` 仍是目标分支。
- `lazy.nvim` 作为通用插件管理器继续远程 bootstrap，符合“直接使用 LazyVim 源码”的边界。
- 当前 Neovim 0.12.0-dev 满足上游源码的 >= 0.11.2 要求。

### 基线与验证入口

- Git 安全：`git status --short --branch`、`git show <tag>`、`git fsck --no-dangling`。
- Lua 格式：使用导入的上游 `stylua.toml`（120 列、双引号/默认括号）执行 `stylua --check lua tests`；使用成套 `selene.toml` + `vim.yml` 做静态检查。
- Core smoke：`nvim -l tests/minit.lua --minitest`，只使用本地 self-spec，并执行 namespace/spec/version/news path assertions。
- Release tests：`scripts/test` 承载其余测试、clean-room 与 identity audit，本地和 CI 复用。
- 文档完整性：核对官方docs commit；断言`SOURCE.json.source_files.length == 138`、所有source以`.md`结尾、source/destination一一对应且双SHA-256正确；三份YAML只在`excluded_upstream_files`，唯一generated working news单列，版本目录目标Markdown总数139。
- 文档可读性/正确性：`scripts/audit-docs`禁止MDX/Docusaurus残留；全量验证125 files/487 groups/975 branches的group context、顺序、label、wrapper-only正文hash和受限operation replay；相对`.md`链接/fragment使用GitHub slugger fixtures；core ancestor/manifest/tree digest稳定，并人工抽查installation/configuration/keymaps/plugins/extras。
- 文档审计证据：JSON输出138/139资产计数、Tabs file/group/branch计数、operation kinds/replay、slugger fixtures、byte-identical upstream news、core身份与失败文件列表，供docs acceptance与release CI消费。
- 最终启动：隔离 `XDG_CONFIG_HOME` / `XDG_DATA_HOME` / `XDG_STATE_HOME` / `XDG_CACHE_HOME` 的 headless 首次启动，再运行 `:checkhealth shawnvim`。
- 依赖/命名审计：对 `git ls-files` 的路径和内容做大小写不敏感 `lazyvim` 扫描，排除 `.codestable/**`，只允许 `UPSTREAM.md`、`UPSTREAM-DOCS.md`、`docs/development/0.1.0/SOURCE.json` 与 `docs/development/0.1.0/upstream/lazyvim-news.md`；另 dump lazy.nvim resolved specs，证明不存在 LazyVim/starter repo identity。

### 交付物落点

- legacy 恢复：Git commit + `legacy-nvim-config-2026-07-14` annotated tag。
- 核心源码：`lua/shawnvim/`、`queries/`、`doc/ShawnVim.txt`，以及从 `0.1.0` 开始的 ShawnVim `NEWS.md` / `CHANGELOG.md`。
- 配置入口：`init.lua`、`lua/config/`、`lua/plugins/`、`shawnvim.json`、`lazy-lock.json`。
- 开发文档：`docs/development/0.1.0/` 的138个source destinations + 1个generated working news（目标139 Markdown）、逐文件`SOURCE.json`、byte-identical upstream news与根`UPSTREAM-DOCS.md`。
- 开发与发布：`tests/`、`scripts/test`、`scripts/audit-docs`、`.github/workflows/ci.yml`、`README.md`、`CONTRIBUTING.md`、`UPSTREAM.md`、`UPSTREAM-DOCS.md`、`LICENSE`、`stylua.toml`、`selene.toml`、`vim.yml`、`.editorconfig`。
- 现状知识：更新 `.codestable/attention.md`、requirements 与 architecture；旧 feature/issue 证据保留。

### 知识回写点

- 在 acceptance 中把 ShawnVim 的最低 Neovim 版本、测试命令、首次启动网络行为写回 attention。
- 把本地 self-spec、namespace/state contract 与不设 upstream remote 的约束写成长期架构决定。
- 把源码批量改名中的动态 import、health 名称与 lazy.nvim identity 陷阱沉淀为 learning。
- 把文档快照的逐文件 provenance、上游历史隔离和 working docs 校准规则写入长期维护说明。
- 更新用户安装指南和贡献/二次开发指南，并以版本化开发文档为详细入口。

## 7. 观察项

- 现有 requirement 与 architecture 仍描述旧 kickstart/custom 架构；它们必须等真实 cutover 后按最终代码回写，不能在规划阶段提前伪造现状。
- 旧 `nvim-modernization` roadmap 的所有 items 已 done，但主文档仍为 `active`；本 epic 完成后应将其归档/标为 completed，并说明已被 ShawnVim 新基线取代。
- 上游源码当前测试脚本会下载 starter，CI 会复用上游专属 workflow 且写死原仓库身份；core smoke 与 release CI 必须按各自 owner 移除这些依赖。
- 当前 README 与 `LICENSE.md` 声称 MIT，而导入源码为 Apache-2.0；core 导入必须删除 `LICENSE.md`、落地 Apache `LICENSE` 与 `UPSTREAM.md`，避免双许可证歧义。
- 当前 `.stylua.toml` 与上游源码风格冲突、`.gitignore` 忽略 `lazy-lock.json`；分别由 core import 与 config cutover 明确处理。
- 官方文档仓库当前 HEAD 为 `85e5b49e...`，早于源码最终 `459a4c3...`；两者必须作为独立 snapshot 记录，plugin/extras 页面以 ShawnVim core 校准结果为准，不声称 docs commit 与 source commit 是同一次构建。
