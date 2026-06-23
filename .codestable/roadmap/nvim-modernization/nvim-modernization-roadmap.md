---
doc_type: roadmap
slug: nvim-modernization
status: active
created: 2026-06-22
last_reviewed: 2026-06-22
tags: [neovim, modernization, refactor, ide, python, frontend, rust, markdown, architecture]
related_requirements: [nvim-dot]
related_architecture: [ARCHITECTURE]
---

# nvim.dot Modernization

## 1. 背景

`nvim.dot` 当前已经不是一份简单的 Neovim 配置，而是一套围绕 Python / React / Rust / Markdown 开发场景逐步演进出来的个人 IDE layer。它已经具备 LSP、completion、format、lint、debug、test、statusline、diagnostics、file manager、Git、Markdown preview、Obsidian 等能力。

当前主要问题不是“插件不够新”，而是配置系统已经进入需要架构化治理的阶段：

- `_G.tools` 成为隐式依赖中心，UI、statusline、Git/path/diagnostics helper 混在一起。
- `lua/custom/plugins/` 目录承载了过多业务逻辑，plugin spec 与模块逻辑边界不清。
- DAP/debug 存在多个入口：`dap.lua`、`debug.lua`、`rustaceanvim.lua`。
- keymap namespace 存在语义冲突与 which-key 漂移。
- Obsidian vault、Conda env、RPC pipe、系统 open/reveal 命令存在硬编码。
- Python / Frontend / Rust 的语言能力还没有统一抽象成可维护的 workflow profile。
- UI / 外观层目前和全局工具、statusline、diagnostics 等存在耦合，未来如果重写外观会牵动过多模块。

本 roadmap 的目标是把这套配置升级为一个低耦合、高内聚、可配置、可扩展、可重写 UI 的现代 Neovim IDE layer。推进顺序采用用户确认的路线：

1. **A：工程化地基优先**
2. **B：语言 IDE 能力补齐**
3. **C：现代体验与 UI 升级**

核心原则：

- UI / 外观层必须可以被单独替换或重写，不牵连 LSP、language workflow、debug/test/core。
- 每个模块必须有清晰职责边界。
- plugin spec 只描述插件安装和加载，不承载复杂业务逻辑。
- 复杂函数和模块必须使用英文注释说明意图、输入、输出、边界和副作用。
- 面向 2026 Neovim 生态：Neovim 0.11+ 原生 LSP API、Neovim 0.12+ LSP 能力、blink.cmp stable、render-markdown、mini/snacks 评估，但不在第一阶段盲目大换插件。

## 2. 范围与明确不做

### 本 roadmap 覆盖

- 目录结构与模块边界重构。
- `_G.tools` 拆分与全局状态收敛。
- 配置层 / 环境层外置。
- keymap taxonomy 与 which-key registry 统一。
- DAP / debug / test 架构统一。
- LSP / formatter / linter registry 现代化。
- Python / Frontend / Rust / Markdown language workflow profiles。
- UI / diagnostics / statusline / theme 层解耦，使未来外观可单独重写。
- Markdown 与 Obsidian 分模式治理。
- 插件版本和工具更新策略。
- 代码可读性、英文注释规范、模块化治理规则。

### 明确不做

- 不在 roadmap 阶段直接修改代码。
- 不在第一阶段大规模替换插件，例如直接把 Telescope 全部换成 Snacks picker，或把自研 statusline 换成 lualine。
- 不把 UI 现代化放在地基之前。
- 不把 Python / Frontend / Rust 强行塞进同一个通用模板；它们共享接口，但各自有独立 workflow profile。
- 不把普通 Markdown 和 Obsidian vault 继续混为一个模式。
- 不在 roadmap 中决定每个插件最终是否保留；具体替换进入对应 feature-design。
- 不顺手修改 `.codestable/architecture/` 或 `.codestable/requirements/`；落地完成后由 feature acceptance 回写现状架构。

## 3. 模块拆分（概设）

```text
nvim-modernization
├── Foundation Architecture：目录结构、模块边界、注释规范、plugin spec 边界
├── Config & Environment：用户配置、环境变量、本机路径、平台差异、外部工具探测
├── Shared Library：icons、git、path、system、diagnostics、highlight 等无 UI 业务模块
├── Keymap Registry：统一 keymap taxonomy、which-key 权威注册、冲突检测
├── Plugin Boundary：Lazy specs 与实际业务逻辑解耦
├── LSP Platform：native LSP config、capabilities、attach、diagnostics、server registry
├── Format & Lint Platform：formatter/linter resolver、project-aware policy
├── Language Profiles：Python、Frontend、Rust、Markdown/Lua 工作流
├── Debug & Test Platform：统一 DAP、adapter、neotest、语言调试/测试入口
├── UI Platform：theme、statusline、diagnostics UI、Noice、picker/explorer 评估
├── Markdown & Knowledge：普通 Markdown、render、preview、Obsidian vault 分模式
└── Version Governance：lazy-lock、plugin pinning、Mason tools、Treesitter 更新策略
```

### 3.1 Foundation Architecture · 工程化地基

- **职责**：定义未来目录结构、模块边界、注释规范和重构纪律。
- **不做**：不引入新插件，不改变用户可见行为。
- **承载的子 feature**：`foundation-architecture`
- **触碰的现有代码 / 模块**：`init.lua`, `lua/core/`, `lua/custom/plugins/`, 新增 `lua/custom/config/`, `lua/custom/lib/`, `lua/custom/ui/`, `lua/custom/lang/`, `lua/custom/debug/`, `lua/custom/test/`

### 3.2 Config & Environment · 配置与环境层

- **职责**：集中管理个人路径、环境变量、平台差异、外部命令探测和本机配置。
- **不做**：不把敏感信息提交进仓库，不负责插件业务逻辑。
- **承载的子 feature**：`env-config-layer`
- **触碰的现有代码 / 模块**：`init.lua`, `lua/custom/plugins/obsidian.lua`, `lua/custom/plugins/python-env.lua`, `lua/custom/plugins/snacks-scratch.lua`, `lua/globals.lua`, `scripts/setup_editor.sh` 只作为观察对象，不运行

### 3.3 Shared Library · 共享库层

- **职责**：从 `_G.tools` 中拆出纯工具模块，提供显式 require 的低层能力。
- **不做**：不包含 UI 渲染策略，不包含具体 plugin config。
- **承载的子 feature**：`shared-lib-extraction`
- **触碰的现有代码 / 模块**：`lua/globals.lua`, `lua/custom/plugins/status-line.lua`, `lua/custom/plugins/lazygit.lua`, `lua/custom/plugins/yazi.lua`, 其他使用 `tools.*` 的模块

### 3.4 Keymap Registry · 快捷键注册中心

- **职责**：定义 keymap namespace、which-key 分组、冲突规则和注册 helper。
- **不做**：不在各插件中随意定义 group，不让 which-key 描述和实际映射漂移。
- **承载的子 feature**：`keymap-taxonomy`
- **触碰的现有代码 / 模块**：`lua/core/keymaps.lua`, `lua/custom/plugins/which-key.lua`, `lua/custom/plugins/telescope.lua`, `lua/custom/plugins/trouble.lua`, `lua/custom/plugins/yazi.lua`, `lua/custom/plugins/lazygit.lua`, DAP/test/lang 相关 keymaps

### 3.5 Plugin Boundary · 插件边界层

- **职责**：让 `lua/custom/plugins/` 只描述 Lazy plugin specs、依赖、加载事件和入口。
- **不做**：不在 plugin spec 文件中堆复杂业务函数。
- **承载的子 feature**：`plugin-boundary-refactor`
- **触碰的现有代码 / 模块**：`lua/custom/plugins/*.lua`，尤其 `obsidian.lua`、`status-line.lua`、`lazydocker.lua`、`debug.lua`、`dap.lua`

### 3.6 LSP Platform · LSP 平台层

- **职责**：以 Neovim 原生 `vim.lsp.config()` / `vim.lsp.enable()` 为中心，统一 capabilities、attach、diagnostics、server registry、profiles。
- **不做**：不把 formatter/linter 和 LSP server 配置混在一起。
- **承载的子 feature**：`lsp-platform-modernization`, `language-profile-registry`
- **触碰的现有代码 / 模块**：`lua/custom/lsp/init.lua`, `lua/custom/lsp/servers.lua`, `lua/custom/lsp/attach.lua`, `lua/custom/lsp/server_settings/*.lua`, `lua/custom/plugins/lsp.lua`, `lua/custom/plugins/blink-cmp.lua`

### 3.7 Format & Lint Platform · 格式化与静态检查平台

- **职责**：统一 Conform / nvim-lint / LSP formatter 的职责，建立 project-aware resolver。
- **不做**：不硬编码所有前端项目都使用 Biome。
- **承载的子 feature**：`format-lint-resolver`
- **触碰的现有代码 / 模块**：`lua/custom/plugins/conform.lua`, `lua/custom/plugins/lint.lua`, `lua/custom/lsp/server_settings/ruff.lua`, `lua/custom/lsp/server_settings/biome.lua`

### 3.8 Language Profiles · 语言工作流层

- **职责**：为 Python / Frontend / Rust / Markdown / Lua 建立独立 workflow profile。
- **不做**：不把语言差异抹平成同一个万能模块。
- **承载的子 feature**：`python-workflow-profile`, `frontend-workflow-profile`, `rust-workflow-profile`, `markdown-workflow-profile`
- **触碰的现有代码 / 模块**：`lua/custom/lsp/server_settings/basedpyright.lua`, `lua/custom/lsp/server_settings/ruff.lua`, `lua/custom/lsp/server_settings/vtsls.lua`, `lua/custom/lsp/server_settings/tailwindcss.lua`, `lua/custom/lsp/server_settings/biome.lua`, `lua/custom/plugins/python-env.lua`, `lua/custom/plugins/rustaceanvim.lua`, `lua/custom/plugins/crates.lua`, `lua/custom/plugins/render-markdown.lua`, `lua/custom/plugins/obsidian.lua`

### 3.9 Debug & Test Platform · 调试与测试平台

- **职责**：统一 DAP 和 neotest 入口，为 Python / Frontend / Rust 提供 test/debug 闭环。
- **不做**：不保留多个 `nvim-dap` 权威配置入口。
- **承载的子 feature**：`debug-test-platform`
- **触碰的现有代码 / 模块**：`lua/custom/plugins/dap.lua`, `lua/custom/plugins/debug.lua`, `lua/custom/plugins/neotest.lua`, `lua/custom/plugins/rustaceanvim.lua`

### 3.10 UI Platform · UI / 外观平台层

- **职责**：隔离 theme、statusline、diagnostics UI、Noice、picker/explorer 等外观与交互层。
- **不做**：不让 UI 直接依赖语言模块、debug/test 模块或 LSP 内部细节。
- **承载的子 feature**：`ui-decoupling`, `statusline-componentization`, `diagnostic-ui-unification`, `modern-ui-evaluation`
- **触碰的现有代码 / 模块**：`lua/custom/plugins/theme.lua`, `lua/custom/plugins/status-line.lua`, `lua/custom/plugins/noice.lua`, `lua/custom/plugins/tiny-inline-diagnostic.lua`, `lua/custom/plugins/trouble.lua`, `lua/custom/plugins/telescope.lua`, `lua/custom/plugins/yazi.lua`, `lua/custom/plugins/namu.lua`

### 3.11 Markdown & Knowledge · Markdown / 知识库层

- **职责**：分离普通 Markdown 编辑、项目文档阅读、Obsidian vault workflow。
- **不做**：不让 Obsidian vault 逻辑污染普通项目 Markdown。
- **承载的子 feature**：`markdown-workflow-profile`
- **触碰的现有代码 / 模块**：`lua/custom/plugins/render-markdown.lua`, `lua/custom/plugins/peek.lua`, `lua/custom/plugins/obsidian.lua`, `lua/custom/plugins/lint.lua`, `lua/custom/plugins/conform.lua`

### 3.12 Version Governance · 版本治理层

- **职责**：统一插件版本、Mason tool、Treesitter parser、Neovim 版本目标和 update policy。
- **不做**：不无脑全部更新到 latest。
- **承载的子 feature**：`version-governance`
- **触碰的现有代码 / 模块**：`lazy-lock.json`, `lua/custom/lsp/init.lua`, `lua/custom/plugins/treesitter.lua`, `lua/custom/plugins/blink-cmp.lua`, `lua/custom/plugins/rustaceanvim.lua`, `lua/custom/plugins/obsidian.lua`

## 4. 模块间接口契约 / 共享协议（架构层详设）

本节是后续 feature-design 的硬约束输入。所有子 feature 设计时必须遵守；如果发现契约不合理，需要先回到 `cs-roadmap update` 修改。

### 4.1 Runtime Config Contract

**方向**：Config & Environment → 所有模块  
**形式**：Lua module API

**模块路径**：

```lua
require('custom.config')
```

**契约**：

```lua
---@class CustomConfig
---@field env CustomEnvConfig
---@field ui CustomUiConfig
---@field lang CustomLangConfig
---@field features CustomFeatureFlags

---@class CustomEnvConfig
---@field obsidian_vault string|nil
---@field conda_envs_path string|nil
---@field nvim_server_pipe string
---@field system_open_cmd string|nil
---@field file_reveal_cmd string|nil

---@class CustomUiConfig
---@field theme string
---@field icons boolean
---@field statusline_enabled boolean
---@field noice_enabled boolean
---@field diagnostics_style 'inline'|'virtual_text'|'minimal'

---@class CustomLangConfig
---@field python CustomPythonConfig
---@field frontend CustomFrontendConfig
---@field rust CustomRustConfig
---@field markdown CustomMarkdownConfig

---@class CustomFeatureFlags
---@field obsidian boolean
---@field markdown_preview boolean
---@field lazydocker boolean
---@field auto_install_tools boolean
---@field auto_update_tools boolean
```

**Required API**：

```lua
---@return CustomConfig
function M.get() end

---@param path string[]
---@param fallback any
---@return any
function M.get_value(path, fallback) end

---@param name string
---@return boolean
function M.is_enabled(name) end
```

**约束**：

- 所有个人路径必须通过 `custom.config` 读取，不允许直接散落在 plugin spec 中。
- 默认值必须安全可用；缺少 Obsidian vault 时应禁用 Obsidian workflow，而不是报错。
- local override 文件如存在，必须可被 gitignore；roadmap 不要求立即实现具体文件名，但 feature-design 必须定义。
- 环境变量优先级必须高于默认值。
- 不允许在 `custom.config` 中 require UI、LSP、debug、test 或 plugin spec，避免反向依赖。

### 4.2 Shared Library Contract

**方向**：Shared Library → UI / LSP / Lang / Debug / Plugin specs  
**形式**：Lua module API

**目标模块**：

```text
custom.lib.icons
custom.lib.git
custom.lib.path
custom.lib.system
custom.lib.diagnostics
custom.lib.highlight
```

**契约**：

```lua
-- custom.lib.icons
---@return table
function M.get_icons() end

---@param kind string
---@return string|nil
function M.get_kind_icon(kind) end

-- custom.lib.git
---@param root string
---@return string|nil
function M.get_remote_name(root) end

---@param root string
---@return string|nil
function M.get_branch(root) end

-- custom.lib.path
---@param path string
---@return string|nil
function M.get_project_root(path) end

---@param path string
---@param root string
---@return string
function M.relative_to_root(path, root) end

-- custom.lib.system
---@param path string
---@return nil
function M.reveal_in_file_manager(path) end

---@param url string
---@return nil
function M.open_url(url) end

---@param cmd string
---@return boolean
function M.executable(cmd) end

-- custom.lib.diagnostics
---@return boolean
function M.available() end

---@param bufnr integer|nil
---@return table
function M.count(bufnr) end

-- custom.lib.highlight
---@param hl string
---@param text string
---@return string
function M.statusline(hl, text) end
```

**约束**：

- `custom.lib.*` 不得依赖 `custom.ui.*`。
- `custom.lib.*` 不得读取 plugin-local state。
- 允许读取 `custom.config`，但不能反过来让 `custom.config` 依赖 lib。
- `_G.tools` 迁移期可以作为 compatibility bridge，但新代码不得新增对 `_G.tools` 的直接依赖。
- 保留 `_G.statusline_render` 这类 Neovim runtime 必需 bridge，但 bridge 内部必须委托给模块函数。

### 4.3 Plugin Spec Boundary Contract

**方向**：Plugin Boundary → 所有 plugin files  
**形式**：目录职责协议

**契约**：

```text
lua/custom/plugins/{domain}.lua
  只允许：
    - 返回 Lazy.nvim plugin spec
    - 声明 dependencies / event / ft / cmd / keys
    - 调用 custom.* 模块的 setup(opts)
    - 放置非常短的 adapter function

  不允许：
    - 放置复杂业务逻辑
    - 定义跨模块 helper
    - 硬编码个人路径
    - 写长 autocmd 逻辑
    - 写大型 keymap registry
    - 直接处理平台差异
```

**推荐结构**：

```lua
return {
  {
    'plugin/name',
    opts = function()
      return require('custom.domain.module').opts()
    end,
    config = function(_, opts)
      require('custom.domain.module').setup(opts)
    end,
  },
}
```

**约束**：

- 超过一个屏幕的业务逻辑默认必须移出 plugin spec。
- plugin spec 可以依赖模块，但模块不得依赖 plugin spec。
- plugin spec 不作为模块公共 API。
- feature-design 若要新增复杂逻辑，必须优先新增 `custom/{domain}/...` 模块。

### 4.4 Keymap Registry Contract

**方向**：Keymap Registry → Core / UI / Lang / Debug / Test / Plugins  
**形式**：Lua module API + namespace protocol

**模块路径**：

```lua
require('custom.keymaps')
```

**Namespace**：

```text
<leader>f    find / files / fuzzy search
<leader>g    git
<leader>l    lsp / language intelligence
<leader>d    debug
<leader>t    test
<leader>x    diagnostics / problems / trouble
<leader>m    markdown
<leader>o    obsidian
<leader>u    ui toggles
<leader>p    project / workspace
<leader>w    windows
<leader>c    code actions / format / refactor
```

**契约**：

```lua
---@class KeymapSpec
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field desc string
---@field group string|nil
---@field buffer integer|nil
---@field opts table|nil

---@param spec KeymapSpec
function M.register(spec) end

---@param specs KeymapSpec[]
function M.register_many(specs) end

---@param prefix string
---@param name string
function M.register_group(prefix, name) end
```

**约束**：

- 所有新 keymap 必须带英文 `desc`。
- which-key group 必须由 registry 统一管理。
- 不允许同一个 lhs 在全局 normal mode 中被两个模块注册为不同语义。
- buffer-local keymaps 允许覆盖，但必须通过 `buffer` 字段显式声明。
- diagnostics 统一使用 `<leader>x` 作为问题列表入口；debug 统一使用 `<leader>d`；test 统一使用 `<leader>t`。
- feature-design 必须处理现有冲突：`<leader>cw`、`<leader>cdd`、`<leader>cdp`、`<leader>l*`、`<leader>t*`。

### 4.5 LSP Platform Contract

**方向**：LSP Platform → Language Profiles / Completion / Diagnostics UI  
**形式**：Lua module API + server registry protocol

**目标结构**：

```text
custom/lsp/
├── init.lua
├── capabilities.lua
├── attach.lua
├── diagnostics.lua
├── registry.lua
├── roots.lua
├── servers/
└── profiles/
```

**契约**：

```lua
-- custom.lsp.capabilities
---@return table
function M.make() end

-- custom.lsp.roots
---@param markers string[]
---@param opts { fallback_to_file_dir?: boolean }|nil
---@return fun(bufnr: integer, on_dir: function)
function M.root_dir(markers, opts) end

-- custom.lsp.registry
---@class LspServerSpec
---@field name string
---@field package string|nil
---@field config table
---@field profile string|nil

---@return LspServerSpec[]
function M.servers() end

---@return string[]
function M.mason_packages() end

-- custom.lsp
function M.setup() end
```

**约束**：

- Neovim 0.11+ 原生 `vim.lsp.config(name, config)` / `vim.lsp.enable(name)` 是主路径。
- `nvim-lspconfig` 只作为 server config provider，不再作为 setup 框架。
- common capabilities 必须只在 `custom.lsp.capabilities` 中合成。
- `LspAttach` 是 buffer-local keymap 和 per-buffer feature 的唯一权威入口。
- LSP diagnostics config 不直接决定 UI 展示插件，只暴露 native diagnostic policy。
- formatter/linter policy 不塞进 LSP server settings，除非 language server 自身需要关闭 formatter capability。

### 4.6 Format & Lint Resolver Contract

**方向**：Format & Lint Platform → Language Profiles  
**形式**：Lua module API

**目标模块**：

```text
custom/format/registry.lua
custom/lint/registry.lua
```

**契约**：

```lua
---@class FormatResolverResult
---@field formatters string[]
---@field stop_after_first boolean
---@field lsp_format 'never'|'fallback'|'prefer'|nil

---@param bufnr integer
---@return FormatResolverResult|nil
function M.resolve_formatters(bufnr) end

---@param bufnr integer
---@return string[]
function M.resolve_linters(bufnr) end
```

**项目检测规则**：

```text
Frontend:
  if biome.json or biome.jsonc exists:
    use biome primary
  else if eslint config exists:
    use eslint diagnostics/fixes where configured
  else if prettier config exists:
    use prettierd/prettier
  else:
    use safe fallback

Python:
  if pyproject.toml exists:
    respect project tool config
  else:
    use default ruff/basedpyright profile

Markdown:
  project docs use markdownlint/prettier only when available
  Obsidian vault may apply separate policy
```

**约束**：

- 不允许硬编码所有 JS/TS/React 都使用 Biome。
- `Conform.nvim` 是 formatter execution layer，不是 policy layer。
- `nvim-lint` 是 lint execution layer，不是 policy layer。
- resolver 必须允许 project-local config 覆盖默认策略。
- save format 必须继续支持禁用特定 filetype 和 fallback。

### 4.7 Language Profile Contract

**方向**：Language Profiles → LSP / Format / Lint / Debug / Test / UI  
**形式**：Lua module API

**目标模块**：

```text
custom/lang/python.lua
custom/lang/frontend.lua
custom/lang/rust.lua
custom/lang/markdown.lua
custom/lang/lua.lua
```

**契约**：

```lua
---@class LanguageProfile
---@field name string
---@field filetypes string[]
---@field lsp_servers string[]
---@field formatter_policy string
---@field linter_policy string
---@field test_adapters string[]
---@field debug_adapters string[]
---@field keymaps KeymapSpec[]
---@field notes string[]

---@return LanguageProfile
function M.profile() end

---@return nil
function M.setup() end
```

**约束**：

- profile 是语言工作流入口，不是 plugin spec。
- Python / Frontend / Rust / Markdown 必须允许策略差异。
- profile 可以消费 LSP / format / lint / debug / test 平台，但不得让平台反向依赖具体语言。
- UI 不直接读取 language profile；如果需要展示状态，通过 diagnostic/test/debug 公共 API。

### 4.8 Debug & Test Contract

**方向**：Debug & Test Platform → Language Profiles  
**形式**：Lua module API

**目标结构**：

```text
custom/debug/
├── init.lua
├── ui.lua
├── keymaps.lua
└── adapters/
    ├── rust.lua
    ├── python.lua
    └── frontend.lua

custom/test/
├── init.lua
└── adapters/
    ├── rust.lua
    ├── python.lua
    └── frontend.lua
```

**契约**：

```lua
-- custom.debug
function M.setup() end

---@param lang 'rust'|'python'|'frontend'
function M.setup_adapter(lang) end

-- custom.test
function M.setup() end

---@param lang 'rust'|'python'|'frontend'
function M.setup_adapter(lang) end
```

**约束**：

- `mfussenegger/nvim-dap` 只能有一个权威 setup 入口。
- `nvim-dap-ui` listener 只能注册一次。
- `debug.lua` 与 `dap.lua` 的重复职责必须收敛。
- Rust 可以继续由 `rustaceanvim` 提供 Rust-specific actions，但 DAP UI / global keymaps 仍归 Debug Platform。
- Python debug 目标是 `debugpy`。
- Frontend debug 目标是 Node / browser debugging，具体 adapter 在 feature-design 决定。
- neotest adapter 按语言拆分，Rust 现有 adapter 保留，Python / Frontend 补齐。

### 4.9 UI Boundary Contract

**方向**：UI Platform → Core / Lib / Diagnostics / Keymaps  
**形式**：模块边界协议 + Lua module API

**目标结构**：

```text
custom/ui/
├── init.lua
├── theme.lua
├── statusline/
│   ├── init.lua
│   ├── components.lua
│   ├── render.lua
│   └── palette.lua
├── diagnostics.lua
├── noice.lua
├── picker.lua
└── explorer.lua
```

**契约**：

```lua
-- custom.ui
function M.setup() end

-- custom.ui.statusline
---@return string
function M.render() end

---@class StatuslineContext
---@field bufnr integer
---@field winid integer
---@field file_path string
---@field root string|nil
---@field width integer

---@param ctx StatuslineContext
---@return string
function M.render_with_context(ctx) end
```

**约束**：

- UI 层可以依赖 `custom.lib.*` 和 `custom.config`。
- UI 层不得 require `custom.lang.*`、`custom.debug.*`、`custom.test.*`。
- LSP / lang / debug / test 不得 require `custom.ui.*`。
- statusline 不得直接调用 scattered global helpers；只能通过 lib 或 statusline-local modules。
- theme / icons / diagnostics style 必须能独立替换。
- 外观重写时，只允许改 `custom/ui/**` 和对应 plugin spec adapter，不应触碰 LSP / lang / debug / test。
- Noice / Trouble / Telescope / tiny-inline-diagnostic 的职责必须明确：
  - inline diagnostics: tiny-inline-diagnostic or chosen provider
  - problem list: Trouble
  - fuzzy search: Telescope or future chosen picker
  - notifications/cmdline: Noice or future chosen provider

### 4.10 Markdown / Obsidian Mode Contract

**方向**：Markdown & Knowledge → Language Profiles / Config / UI  
**形式**：模式协议

**模式**：

```text
markdown.project
  普通项目文档和 README

markdown.preview
  外部或浏览器预览

markdown.obsidian
  Obsidian vault workflow
```

**契约**：

```lua
---@param path string
---@return 'project'|'obsidian'
function M.detect_markdown_mode(path) end

---@param mode 'project'|'obsidian'
function M.setup_mode(mode) end
```

**约束**：

- `obsidian.nvim` 只在 vault path 可用且当前文件属于 vault 时启用 vault-specific 行为。
- 普通 Markdown 不应被 Obsidian keymap、frontmatter mutation、vault path 影响。
- `render-markdown.nvim` 是 editor-internal primary reading enhancement。
- `peek.nvim` 或其他 preview provider 是 secondary。
- Obsidian vault path 必须来自 `custom.config`，不能硬编码。
- macOS `open` / Linux opener 必须通过 `custom.lib.system`。

### 4.11 Version Governance Contract

**方向**：Version Governance → Plugin specs / LSP Platform / Tool installer  
**形式**：策略协议

**契约**：

```text
Neovim target:
  prefer 0.12.x stable where available
  retain compatibility floor only if explicitly documented

Plugins:
  lazy-lock.json is source of installed plugin commit truth
  major version pins required for fast-moving plugins

Tools:
  Mason install list comes from LSP/format/lint/debug registry
  auto_update_tools controlled by custom.config.features.auto_update_tools

Treesitter:
  parser auto_install policy must be explicit

Known version policy:
  blink.cmp should use stable 1.* unless intentionally testing v2
  rustaceanvim should pin compatible major
  obsidian.nvim should avoid unbounded '*'
```

**约束**：

- 不允许 tool auto-update policy 与 plugin lock policy 矛盾而不记录。
- 核心语言工具升级必须可控。
- feature-design 需要决定是否保留 `mason-tool-installer` `auto_update = true`。
- 版本升级 feature 必须有 rollback note。

### 4.12 Commenting & Readability Contract

**方向**：Foundation Architecture → 所有代码模块  
**形式**：代码风格协议

**契约**：

所有新模块和重构后的复杂函数必须使用英文注释说明：

```lua
--- Builds the effective formatter policy for the current buffer.
--- The resolver checks project-local files before falling back to defaults.
--- It does not execute formatting; execution is delegated to conform.nvim.
---@param bufnr integer Buffer number used to inspect filetype and project root.
---@return FormatResolverResult|nil policy Formatter policy, or nil when formatting is disabled.
local function resolve_formatters(bufnr)
  ...
end
```

**必须注释的内容**：

- public module API
- non-trivial private helper
- resolver / detector / adapter / bridge function
- side-effectful function
- autocmd callback
- keymap callback if behavior is not obvious
- platform-specific branch
- compatibility bridge

**注释语言**：

- 函数 / 方法 / API 注释使用英文。
- 文档和 CodeStable spec 可以继续中文。
- 注释要解释 intent / boundary / side effects，不写“显而易见”的废话。

**约束**：

- 复杂函数无英文注释视为不合格。
- 注释不能掩盖坏抽象；如果注释需要解释太多，feature-design 应考虑拆函数。
- plugin spec 文件中的短 adapter 可以少注释，但其调用的业务模块必须完整注释。

## 5. 子 feature 清单

1. **foundation-architecture** — 建立目标目录结构、模块边界、英文注释规范和迁移纪律，不改变用户可见行为。
   - 所属模块：Foundation Architecture
   - 依赖：无
   - 状态：planned
   - 对应 feature：未启动
   - 备注：这是最小闭环，完成后可以证明新架构骨架能加载并保留当前核心启动链路。

2. **env-config-layer** — 建立 `custom.config` / env override / feature flags，把个人路径和平台配置集中管理。
   - 所属模块：Config & Environment
   - 依赖：`foundation-architecture`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：为 Obsidian、Conda、RPC pipe、system open/reveal、auto update policy 提供统一入口。

3. **shared-lib-extraction** — 将 `_G.tools` 拆为 `custom.lib.icons/git/path/system/diagnostics/highlight`，保留必要 compatibility bridge。
   - 所属模块：Shared Library
   - 依赖：`foundation-architecture`, `env-config-layer`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：后续 UI 解耦和 statusline 组件化的前置条件。

4. **keymap-taxonomy** — 建立统一 keymap registry、which-key 权威分组和冲突清理规则。
   - 所属模块：Keymap Registry
   - 依赖：`foundation-architecture`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：必须处理 `<leader>cw`、`<leader>cdd`、`<leader>cdp`、`<leader>l*`、`<leader>t*` 等冲突。

5. **plugin-boundary-refactor** — 将复杂业务逻辑从 plugin spec 中迁出，让 `lua/custom/plugins/` 只保留 Lazy spec / adapter。
   - 所属模块：Plugin Boundary
   - 依赖：`foundation-architecture`, `shared-lib-extraction`, `keymap-taxonomy`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：优先处理 `status-line.lua`、`obsidian.lua`、`lazydocker.lua`、`dap.lua`、`debug.lua`。

6. **lsp-platform-modernization** — 重构 LSP 平台层，明确 native `vim.lsp.config` / `vim.lsp.enable`、capabilities、attach、diagnostics、server registry。
   - 所属模块：LSP Platform
   - 依赖：`foundation-architecture`, `shared-lib-extraction`, `keymap-taxonomy`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：不改变语言策略，只先把 LSP 平台边界立稳。

7. **format-lint-resolver** — 将 Conform / nvim-lint 策略抽为 project-aware formatter/linter resolver。
   - 所属模块：Format & Lint Platform
   - 依赖：`lsp-platform-modernization`, `env-config-layer`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：Frontend 必须支持 Biome / ESLint / Prettier 检测式策略。

8. **language-profile-registry** — 建立 `custom/lang/{python,frontend,rust,markdown,lua}.lua` profile 接口，统一语言能力声明。
   - 所属模块：Language Profiles
   - 依赖：`lsp-platform-modernization`, `format-lint-resolver`, `keymap-taxonomy`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：先建立 profile 机制，不要求一次补齐所有语言能力。

9. **debug-test-platform** — 统一 DAP / neotest 平台，收敛 `dap.lua`、`debug.lua`、`rustaceanvim.lua` debug 边界。
   - 所属模块：Debug & Test Platform
   - 依赖：`foundation-architecture`, `keymap-taxonomy`, `env-config-layer`
   - 状态：planned
   - 对应 feature：未启动
   - 备注：`nvim-dap` setup 和 dap-ui listener 只能有一个权威入口。

10. **python-workflow-profile** — 补齐 Python workflow：basedpyright/ruff profile、venv、pytest/neotest-python、debugpy。
    - 所属模块：Language Profiles / Debug & Test Platform
    - 依赖：`language-profile-registry`, `debug-test-platform`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：支持 relaxed / strict / project-local typing policy。

11. **frontend-workflow-profile** — 补齐 React/Frontend workflow：vtsls、Tailwind、Biome/ESLint/Prettier resolver、Vitest/Jest/Playwright 或 package scripts 入口。
    - 所属模块：Language Profiles / Format & Lint Platform / Debug & Test Platform
    - 依赖：`language-profile-registry`, `format-lint-resolver`, `debug-test-platform`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：不假设所有前端项目都是 Biome-first。

12. **rust-workflow-profile** — 收敛 Rust workflow：rustaceanvim、crates、clippy、codelldb、neotest、cargo command 入口。
    - 所属模块：Language Profiles / Debug & Test Platform
    - 依赖：`language-profile-registry`, `debug-test-platform`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：保留 rustaceanvim 优势，但统一 DAP UI / keymap / adapter 边界。

13. **markdown-workflow-profile** — 分离普通 Markdown、render、preview、lint/format 与 Obsidian vault workflow。
    - 所属模块：Markdown & Knowledge / Language Profiles
    - 依赖：`language-profile-registry`, `env-config-layer`, `plugin-boundary-refactor`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：`render-markdown.nvim` 是 primary editor-internal reading enhancement。

14. **ui-decoupling** — 建立 `custom/ui/` 边界，使 theme/statusline/diagnostic UI/Noice/picker/explorer 与 LSP/lang/debug/test 解耦。
    - 所属模块：UI Platform
    - 依赖：`shared-lib-extraction`, `plugin-boundary-refactor`, `keymap-taxonomy`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：这是用户强调的关键目标：未来外观可单独重写。

15. **statusline-componentization** — 将自研 statusline 拆成 context、components、render、palette，保留轻量和响应式原则。
    - 所属模块：UI Platform
    - 依赖：`ui-decoupling`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：statusline 不直接依赖 `_G.tools`，只依赖 lib 和 statusline-local modules。

16. **diagnostic-ui-unification** — 统一 native diagnostics、tiny-inline-diagnostic、Trouble、Telescope diagnostics、statusline diagnostic count 的职责边界。
    - 所属模块：UI Platform
    - 依赖：`ui-decoupling`, `lsp-platform-modernization`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：目标是降低噪音、明确 primary/secondary 问题定位入口。

17. **modern-ui-evaluation** — 在地基稳定后评估 Snacks / mini / Noice / Telescope / Yazi 的现代化取舍。
    - 所属模块：UI Platform
    - 依赖：`ui-decoupling`, `statusline-componentization`, `diagnostic-ui-unification`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：只评估和局部替换，不做无目标大换血。

18. **version-governance** — 明确 Neovim target、plugin pin、lazy-lock、Mason tools、Treesitter parser、blink.cmp stable 策略。
    - 所属模块：Version Governance
    - 依赖：`foundation-architecture`, `env-config-layer`, `lsp-platform-modernization`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：建议 blink.cmp pin stable `1.*`，避免继续使用过时或过宽版本约束。

19. **architecture-backfill-after-modernization** — 在主要重构完成后回写 `.codestable/architecture/`，记录实际落地的新架构。
    - 所属模块：Foundation Architecture / CodeStable 回写
    - 依赖：`ui-decoupling`, `language-profile-registry`, `debug-test-platform`, `version-governance`
    - 状态：planned
    - 对应 feature：未启动
    - 备注：这是收尾 feature，用于把 roadmap 中已实现的规划转为 architecture 现状文档。

**最小闭环**：第 1 条 `foundation-architecture` 做完后，项目应具备新的目录骨架、模块边界规范、英文注释规范和迁移纪律，并且 Neovim 仍可正常启动。这是后续所有重构承载“诺亚方舟地基”的最窄路径。

## 6. 排期思路

本 roadmap 按用户确认的 **A → B → C** 推进。

### A. 工程化地基

先做：

1. `foundation-architecture`
2. `env-config-layer`
3. `shared-lib-extraction`
4. `keymap-taxonomy`
5. `plugin-boundary-refactor`

原因：

- 这些 feature 不追求立刻增加能力，而是降低后续所有改动的耦合风险。
- UI 可替换性、语言 profile、debug/test 平台都依赖这些边界。
- 如果先做 UI 或语言能力，会继续把新逻辑堆进旧结构。

### B. 语言 IDE 能力

然后做：

1. `lsp-platform-modernization`
2. `format-lint-resolver`
3. `language-profile-registry`
4. `debug-test-platform`
5. `python-workflow-profile`
6. `frontend-workflow-profile`
7. `rust-workflow-profile`
8. `markdown-workflow-profile`

原因：

- Python / Frontend / Rust 的能力不能只是插件列表，必须成为 workflow profile。
- Debug/test 是 IDE 体验的关键闭环。
- Formatter/linter 必须 project-aware，否则 React/Frontend 项目会被 Biome-first 假设限制。

### C. 现代体验与 UI

最后做：

1. `ui-decoupling`
2. `statusline-componentization`
3. `diagnostic-ui-unification`
4. `modern-ui-evaluation`
5. `version-governance`
6. `architecture-backfill-after-modernization`

原因：

- UI 层必须在 lib/config/keymap/plugin boundary 稳定后再重写。
- Snacks / mini / Noice / Telescope / Yazi 的取舍必须基于架构边界，而不是喜好驱动。
- 版本治理放在地基和主要平台形成后统一收束，避免边改边升级导致问题来源不清。

## 7. 观察项

- `.codestable/architecture/ARCHITECTURE.md` 当前只记录 onboard 初版现状；roadmap 落地后需要通过 `cs-arch update` 或 acceptance 回写真实新架构。
- 当前 `lua/custom/plugins/debug.lua` 仍明显保留 kickstart.nvim 示例风格，并且包含 Go debug 相关内容；这可能不符合当前 Python / Frontend / Rust 主线。
- 当前 `lazy-lock.json` 存在但 `.gitignore` 忽略它；版本治理 feature 需要确认它究竟是提交资产还是本地状态。
- 当前 README 仍强调 GitHub Monochrome，但实际审计中发现 theme 文件使用 `kanagawa-dragon`；UI feature 或 architecture update 需要核对真实主题方向。
- `scripts/setup_editor.sh` 会修改用户 shell / Kitty 配置，不属于本 roadmap 的默认自动化范围。
- 若用户未来决定大规模采用 `snacks.nvim`，应通过 `modern-ui-evaluation` 单独评估，不应在 foundation 阶段直接替换。
