---
doc_type: feature-design
feature: 2026-07-14-shawnvim-core-fork
requirement: nvim-dot
roadmap: shawnvim-fork
roadmap_item: shawnvim-core-fork
execution_lane: goal
status: approved
summary: 将固定 LazyVim 16.0.0 源码分叉为本地 ShawnVim 0.1.0 核心
tags: [neovim, lua, fork, distribution, shawnvim]
---

# ShawnVim Core Fork

## 0. 术语约定

| 术语 | 定义 | 防冲突结论 |
|---|---|---|
| source snapshot | LazyVim commit `459a4c3b...` 的固定源码输入 | 不是 remote/submodule，不自动更新 |
| Distribution Core | 本仓库 `lua/shawnvim/` 下的默认行为、plugins、extras、util 与 health | 与用户 override `lua/plugins/` 分离 |
| local self-spec | lazy.nvim 中以配置根目录作为 `dir`、名称为 ShawnVim 的本地 plugin spec | 不声明 `LazyVim/LazyVim` |
| release version | `ShawnVim.config.version == "0.1.0"` | 与整数 JSON schema version 分离 |
| source manifest | `UPSTREAM-SOURCE.json` 中的 source path/hash/destination/transform 记录 | 与文档 `SOURCE.json` 分离 |

## 1. 决策与约束

### 需求摘要

把固定上游源码直接纳入仓库并完成可运行的 ShawnVim 核心：目录/require/global/types/events/commands/state/health/doc/plugin identity 全面改名，本地 self-spec 负责 setup，运行时不下载 LazyVim 或 starter。core feature 在不切换真实 `init.lua`、不删除旧配置的前提下，通过隔离 minit 证明最小闭环。

### 明确不做

- 不迁移旧 `lua/custom`、`lua/core`、`after/ftplugin` 行为。
- 不修改真实配置入口或删除旧运行时；由 config cutover 负责。
- 不导入上游翻译 README、release tooling、issue templates 或文档网站。
- 不保持 upstream remote/submodule，也不承诺行为长期与 LazyVim 同步。
- 不在首次机械分叉中加入个人主题、语言 extras 或快捷键。

### 复杂度档位

迁移/公共契约 = 高：数百文件 namespace 与 plugin lifecycle 同时变化，必须有结构化 manifest、identity audit 和隔离运行测试。生命周期 = 长期维护资产，不能使用兼容 alias 或占位实现。

### 关键决策

1. Core module 路径从 `lua/lazyvim` 整体改为 `lua/shawnvim`；不保留旧 Lua alias，避免后续代码继续依赖上游身份。
2. lazy.nvim 生命周期采用 local self-spec：`dir = vim.g.shawnvim_root or vim.fn.stdpath("config")`、`name = "ShawnVim"`、`lazy = false`、高优先级、`opts = {}`。
3. `vim.g.shawnvim_root` 只作为 test/dev seam；生产不设置，始终使用真实 config root。
4. 发行版本从 0.1.0 开始；JSON schema 整数按状态迁移需要保留但不公开为发行版本。
5. 新建 ShawnVim NEWS/CHANGELOG，不复制或改牌上游发布历史；上游来源只在 `UPSTREAM.md`/manifest 中出现。
6. Apache `LICENSE`、`UPSTREAM.md` 和源码同一提交落地，删除旧 MIT `LICENSE.md`；转载文档的权利边界不在本 feature 扩张。

### 基线风险、依赖与证据

- 前置依赖：legacy tag 已通过；Neovim >= 0.11.2；网络可获取固定 snapshot 与 lazy.nvim test bootstrap。
- Top 3 风险：动态字符串漏改（全树 identity + runtime spec）、self-spec setup 顺序错误（minit）、机械改名夹带行为漂移（source/destination manifest +结构审查）。
- 基线风险：上游测试默认下载 starter，CI/repo identity 写死 LazyVim；必须由本地 smoke 替换。
- 关键假设：固定 snapshot 在当前 Neovim 0.12-dev 可运行；最低版本兼容留待 release matrix。
- 证据：双路径 hash manifest、Lua/static audit、minit assertions、resolved spec dump、diff review。
- 清洁度：不保留临时 clone、sed 脚本输出、旧 namespace alias、TODO/FIXME 或注释掉的 self-spec。

## 2. 名词与编排

### 2.1 名词层

**现状**：当前仓库没有 `shawnvim` module；真实 `init.lua` 只加载旧 custom 配置。固定上游提供 `require("lazyvim")`、`_G.LazyVim`、`lazyvim.plugins` 和远程 self plugin identity。

**变化**：

```lua
---@class ShawnVimConfig
local ShawnVim = require("shawnvim")
ShawnVim.setup(opts)

assert(_G.ShawnVim ~= nil)
assert(ShawnVim.config.version == "0.1.0")
assert(type(ShawnVim.config.json.version) == "number")
```

Local self-spec：

```lua
{
  dir = vim.g.shawnvim_root or vim.fn.stdpath("config"),
  name = "ShawnVim",
  priority = 10000,
  lazy = false,
  opts = {},
}
```

状态/入口映射以 roadmap §4.2 为硬约束，包括 `ShawnExtras`、`ShawnHealth`、`shawnvim.json`、`vim.g.shawnvim_*`、`ShawnVim*` events 和 `doc/ShawnVim.txt`。

`UPSTREAM-SOURCE.json`：

```text
source_repository + source_commit + source_version
source_files[]:
  source, destination, source_sha256, destination_sha256, transform
  modified: true|false
  modification_notice:
    status: modified|unmodified
    kind: lua-comment|vimdoc-line|scm-comment|yaml-comment|toml-comment|other-comment|none
    locator: line/JSON-pointer-or-null
    marker_sha256: sha256-or-null
generated_files[]: ShawnVim original files
excluded_files[]: source, reason
test_dependencies.lazy_nvim_commit: 306a05526ada86a7b30af95c5cc81ffba93fef97
```

Identity allowlist 使用精确 JSON Pointer：仅 `/source_repository`、`/source_files/*/source`、`/excluded_files/*/source` 可包含大小写 `lazyvim`；`destination`、`transform`、`generated_files`、notice字段和值均不豁免。`modified=false` 时必须 `source_sha256 == destination_sha256`、transform为空且notice status为`unmodified`；`modified=true` 时notice locator必须解析到目标文件内显著包含 ShawnVim 与 `UPSTREAM.md` 的语言对应标记，audit逐文件验证marker hash，并拒绝`modified`与notice status矛盾。不能添加注释的格式若需改写，必须改为可承载显著notice的等价格式、归类为ShawnVim generated file，或明确排除；不得用顶层总声明代替逐文件状态。

Version gate seam：

```lua
---@param has fun(feature:string):boolean
---@return boolean supported
function ShawnVim.version_supported(has) end
```

production callback固定为`function(feature) return vim.fn.has(feature) == 1 end`；`shawnvim.plugins` 的真实首个版本 gate 必须调用该 seam，而不是只测试孤立函数。窄测试接口位于`shawnvim.version._with_probe_for_test(probe, fn)`：只有`vim.g.shawnvim_test_mode == true`时可调用；它临时替换module-private probe、清除`package.loaded["shawnvim.plugins"]`后执行`fn`，无论成功/失败都恢复probe与module cache并重抛原错误。minit顺序固定为设置test_mode → `_with_probe_for_test(false_probe, function() return require("shawnvim.plugins") end)` → 断言真实import错误文本/非交互路径 → 确认恢复 → 清除test_mode；生产Config Shell禁止设置该global或调用test helper。headless分支通过Lua error/进程错误非零退出、绝不调用`getchar()`；只有检测到真实UI的interactive分支可提示后退出。core中该注入seam是blocking，release matrix只验证真实最低支持版本v0.11.2与stable，不负责低于最低版本的函数契约。

Audit CLI contract：`audit-source-manifest --fetch-missing` 在 source cache缺失时只fetch固定commit `459a4c3b1059671e766a46c7cc223827dc67e3d0` 到 `.tests/upstream/`，不向项目添加remote；cache存在时必须验证HEAD/tree等于固定commit且clean，并支持不联网的cache-hit重跑。JSON evidence至少包含source commit/tree、imported/generated/excluded counts、modified/unmodified notice counts、逐文件失败列表和test dependency commit。cache/evidence均ignored，成功可复用、失败保留日志。`audit-identity` 按上述JSON Pointer解析字段而不是整文件跳过。所有核心audit失败返回非零。

##### Interface 设计检查

- Module：Distribution Core（新增）。
- Interface：`require("shawnvim").setup(opts)`、`_G.ShawnVim`、`shawnvim.plugins` import、状态/命令/event names。
- Seam：lazy.nvim local self-spec；production/test 都穿过同一 setup lifecycle。
- Depth / locality：默认插件、extras、root、format、LSP、UI 与状态迁移隐藏在 core 内，Config Shell 只知道 import 顺序。
- Dependency strategy：in-process；lazy.nvim/插件是外部 Git dependencies，由 specs 管理。
- Adapter：无。`shawnvim_root` 是 root override，不创建第二套 adapter。
- Test surface：minit 导入 local spec、runtime assertions、resolved spec dump、health/news path。

### 2.2 编排层

```mermaid
flowchart LR
  A[读取固定 source snapshot] --> B[建立 source manifest]
  B --> C[路径/namespace/identity 变换]
  C --> D[local self-spec + 0.1.0 state]
  D --> E[新 NEWS/CHANGELOG + License provenance]
  E --> F[minit local import]
  F --> G[identity/spec/version/news assertions]
```

**现状**：上游 core 依赖 LazyVim plugin identity，旧配置仓库尚未加载它；上游 test又引入 starter。

**变化**：新增一条隔离编排支线，测试将 `vim.g.shawnvim_root` 指向 checkout，导入 `shawnvim.plugins`，由 local self-spec setup core，再验证 namespace/spec/state/news。真实 `init.lua` 暂时保持旧入口。

流程级约束：

- 所有 copy/transform 以固定 commit 为输入；动态 HEAD 不可参与。
- namespace transform 后，除 provenance-only `UPSTREAM-SOURCE.json` 的 `/source_repository`、`/source_files/*/source`、`/excluded_files/*/source` 三类JSON Pointer及其他roadmap路径allowlist外，path/content不得含大小写`lazyvim`；该JSON的destination/transform/generated/notice字段不豁免。
- 每个被改写的Apache源码文件带语言对应的ShawnVim modification notice；manifest每个source entry记录modified与结构化notice对象，audit按locator/marker逐文件验证，遵守Apache §4(b)。
- minit bootstrap固定lazy.nvim commit `306a05526ada86a7b30af95c5cc81ffba93fef97`，不得从`main`动态下载bootstrap；resolved evidence记录实际commit。
- minit不能直接信任固定commit中的通用`bootstrap.lua`默认clone行为：cache缺失时clone后必须detached checkout上述commit并验证`HEAD`精确相等且worktree clean；已有`LAZY_PATH`/cache只有在HEAD相等且clean时可复用，否则fail-closed，不reset或覆盖用户checkout。minit resolved-spec evidence同时记录expected/actual lazy.nvim OID。
- `tests/minit.lua --minitest` 默认原子写ignored `.tests/evidence/core-minit.json`，覆盖cache-miss clone、正确clean cache-hit、错误OID cache和dirty cache fail-closed四条分支，并记录expected/actual OID、clean状态、cache mode与resolved local ShawnVim spec。
- setup 必须只执行一次；import order checker以 `shawnvim.plugins` 为第一 distribution import。
- 失败语义：任一 manifest、identity、Lua load 或 smoke assertion 失败则 core feature 不完成。
- 可观测点：file counts/hashes、resolved specs、global/version/schema、command/health/news path。
- Tool preflight：`command -v stylua` / `command -v selene`；缺失只记录 supporting baseline，由 release CI 安装 pinned tools，不在本 feature全局安装。

### 2.3 挂载点清单

1. Lua runtime namespace：`lua/shawnvim/` — 新增 Distribution Core。
2. lazy.nvim spec imports：`shawnvim.plugins` / `shawnvim.plugins.extras.*` — 新增。
3. 全局/用户入口：`_G.ShawnVim`、`:ShawnExtras`、`:ShawnHealth`、health `shawnvim` — 新增。
4. 发行状态：`ShawnVim.config.version`、`shawnvim.json` schema contract — 新增/改名。
5. 来源/许可：`UPSTREAM-SOURCE.json`、`UPSTREAM.md`、Apache `LICENSE` — 新增/替换。

### 2.4 推进策略

1. Provenance 骨架：固定 snapshot inventory、source manifest 和 Apache attribution；退出信号是每个导入/排除路径可追溯。
2. Core transform：落地 `lua/shawnvim`、queries、vimdoc 并完成 namespace/identity mapping；退出信号是 Lua files 可解析且静态 identity audit 通过。
3. Lifecycle/state：实现 local self-spec、0.1.0 version、schema/commands/events/health 映射；退出信号是 spec 可解析且无远程 LazyVim identity。
4. ShawnVim history：落地新 NEWS/CHANGELOG 并接通 core news path；退出信号是内容只描述 ShawnVim 0.1.0 来源和后续历史。
5. Audit tooling：交付 `scripts/audit-identity`、`scripts/audit-source-manifest` 与 `scripts/check-lua-syntax.lua`；实现JSON Pointer allowlist、fixed cache/cache-hit、manifest/notice/evidence schema和version seam checks；退出信号是脚本输入/输出/非零语义明确且可在当前环境执行。
6. Core smoke：适配 minit 并执行 namespace/spec/version/news assertions；低版本错误路径使用可注入 version seam、headless 非交互退出；退出信号是隔离 smoke 全通过。
7. 审计收口：核对双 hash、Apache notice、格式和残留；退出信号是 manifest、identity、diff review 全绿，Stylua/Selene 缺失时按 supporting preflight 记录而不静默安装全局工具。

### 2.5 结构健康度与微重构

##### 评估

- 文件级：固定上游包含若干 >500 行文件，但首次分叉只做 identity/lifecycle 必需变换；此时拆分会破坏 source diff 可审计性。
- 目录级：`lua/shawnvim/plugins/extras` 文件多但已有上游分类层级，不是摊平目录；保留结构。
- 当前旧 `lua/custom` 不在本 feature 修改范围。
- Interface 深度：local self-spec + setup 是 deep core 的标准 composition seam，不增加 wrapper。

##### 结论：不做

超出范围的观察：core 导入稳定后若要拆胖文件或重组 extras，应另走 `cs-refactor`，不能混入首次 snapshot。

## 3. 验收契约

### 3.1 关键场景

1. 隔离 minit 导入 `shawnvim.plugins` → `_G.ShawnVim` 存在且 setup 完成。
2. 读取 runtime version/schema → release 为 `0.1.0`，schema 为独立整数。
3. dump resolved specs → 存在本地 ShawnVim self-spec，不存在 LazyVim repo/starter。
4. 扫描 runtime/tests/path → provenance 字段级 allowlist 外没有旧 namespace/identity；`UPSTREAM-SOURCE.json` 的 destination/transform/generated 值不被豁免。
5. 打开 ShawnVim news/changelog path → 文件存在且不伪造上游版本历史。
6. 核对 source manifest → 固定 snapshot 的导入文件有 source/destination 双 hash，排除项有理由。
7. 注入不支持版本 predicate → core 显示 ShawnVim 错误提示并以非交互非零结果安全退出；真实低版本 matrix 由 release feature 验证。

### 3.2 明确不做的反向核对

- resolved specs 不应包含 `LazyVim/LazyVim` 或 starter。
- package/runtime 不应提供 `require("lazyvim")`、`_G.LazyVim`、LazyVim commands/events aliases。
- diff 不应删除旧 `lua/custom`/`lua/core` 或改写真实 `init.lua`。
- Git remotes 不应新增 upstream。

### 3.3 Acceptance Coverage Matrix

| Scenario | Covered By Step | Evidence Type | Command / Action | Core? |
|---|---|---|---|---|
| local core setup | S2/S3/S6 | test | minit | yes |
| 0.1.0/schema 分离 | S3/S6 | test | runtime assertions | yes |
| 无远程 LazyVim spec | S3/S6/S7 | test + command | spec dump/identity audit | yes |
| source provenance 完整 | S1/S5/S7 | manifest + command | dual-hash/notice verifier | yes |
| news/history 真实 | S4/S6 | test + diff review | news path assertion | yes |
| 版本错误 seam | S3/S5/S6 | test | actual import + injected version predicate | yes |
| fixed lazy.nvim harness | S5/S6 | test + JSON | clone/cache-hit/错误OID/dirty cache + expected/actual OID | yes |
| 旧配置未删除 | S7 | diff review | path audit | yes |

### 3.4 DoD Contract

| ID | 要求 | 证据 | 阻塞级别 |
|---|---|---|---|
| DOD-DESIGN-001 | core interface/transform 契约通过 review | design review | blocking |
| DOD-IMPL-001 | checklist 和 import manifest 完成 | checklist + manifest | blocking |
| DOD-REVIEW-001 | spec 合规与代码质量 review passed | review report | blocking |
| DOD-QA-001 | core minit/identity/source/syntax assertions全通过；Stylua/Selene若缺失则记录supporting baseline | QA evidence | blocking |
| DOD-ACCEPT-001 | core artifacts 与 roadmap 回写完成 | acceptance | blocking |

Validation Commands:

| ID | 命令 | 目的 | 核心性 | 失败处理 |
|---|---|---|---|---|
| CMD-001 | `nvim -l tests/minit.lua --minitest` | local core smoke、真实import version seam与fixed lazy.nvim clone/cache分支JSON | core | fix-or-block |
| CMD-002 | `scripts/audit-identity --json .tests/evidence/core-identity.json` | namespace/path/spec identity与字段级 allowlist | core | fix-or-block |
| CMD-003 | `scripts/audit-source-manifest --source-cache .tests/upstream/lazyvim-source --fetch-missing --core . --manifest UPSTREAM-SOURCE.json --json .tests/evidence/core-source.json` | fixed source/cache-hit、source/destination provenance、test dependency与Apache notice | core | fix-or-block |
| CMD-004 | `nvim -l scripts/check-lua-syntax.lua` | Lua syntax与version seam | core | fix-or-block |
| CMD-005 | `stylua --check lua tests` | Lua 格式（supporting tool） | supporting | document-baseline |
| CMD-006 | `selene lua tests` | Lua 静态检查（supporting tool） | supporting | document-baseline |

Required Artifacts: `lua/shawnvim/`、queries、vimdoc、NEWS/CHANGELOG、LICENSE、UPSTREAM、UPSTREAM-SOURCE.json及逐source notice字段、per-file modification notices、固定lazy.nvim bootstrap的minit、ignored `.tests/evidence/core-minit.json`（clone/cache-hit/错误OID/dirty cache及expected/actual OID）、`scripts/audit-identity`、`scripts/audit-source-manifest`、`scripts/check-lua-syntax.lua`、ignored core identity/source JSON evidence与supporting-tool preflight、review/QA/acceptance。

## 4. 与项目级架构文档的关系

acceptance 必须把 Distribution Core、本地 self-spec、namespace/state contract、0.1.0 版本线和无 upstream relationship 回写架构/ADR；这是系统级结构变化。
