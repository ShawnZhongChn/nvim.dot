# nvim.dot 架构总入口

> 状态：已按 nvim-modernization 初步回写
> 创建日期：2026-06-22
> 最近更新：2026-06-23

## 1. 项目简介

nvim.dot 是一套高度定制的 Neovim Lua 配置，基于 kickstart.nvim 演进而来，核心目标是：

- Minimalist Monochrome：极简黑白、高对比度视觉体验。
- 高性能：以 Lazy.nvim、轻量自研状态栏和按需加载插件为基础。
- 模块化：core、custom config/lib/lang/ui/lsp/debug/test 等能力分层组织。
- Python / Lua / Frontend / Rust / Markdown 开发工作流优化。

## 2. 启动流程

`init.lua` 是唯一入口，当前启动链路为：

1. 加载 `lua/globals.lua`，建立兼容 `_G.tools` bridge；真实实现来自 `custom.lib`。
2. 禁用 netrw，避免与外部文件管理插件冲突。
3. 加载 `lua/core/options.lua`、`lua/core/keymaps.lua`、`lua/core/autocmds.lua`。
4. 通过 `custom.config.env.nvim_server_pipe` 启动 Neovim RPC pipe，默认 `/tmp/nvim`。
5. Bootstrap Lazy.nvim。
6. 通过 `require('lazy').setup({ { import = 'custom.plugins' } })` 自动导入插件 specs。

## 3. 顶层目录结构

- `init.lua`：Neovim 配置入口与 Lazy.nvim bootstrap。
- `lua/globals.lua`：旧 `_G.tools` 兼容桥；新代码应显式 require `custom.lib.*`。
- `lua/core/`：基础选项、基础快捷键、基础 autocmd。
- `lua/custom/config/`：集中默认配置、环境变量覆盖、本地 override。
- `lua/custom/lib/`：icons、git、path、system、diagnostics、highlight 等共享低层库。
- `lua/custom/keymaps.lua`：keymap registry 和 which-key group 入口。
- `lua/custom/lsp/`：LSP capabilities、diagnostics、roots、registry、attach 与 setup。
- `lua/custom/format/` / `lua/custom/lint/`：formatter/linter policy registry。
- `lua/custom/lang/`：Python、Frontend、Rust、Markdown workflow profile。
- `lua/custom/debug/` / `lua/custom/test/`：DAP / neotest 平台边界。
- `lua/custom/ui/`：statusline、Noice、diagnostic UI、picker、explorer 等 UI 边界。
- `lua/custom/plugins/`：Lazy.nvim plugin specs 和短 adapter。
- `after/ftplugin/`：按文件类型调用 `custom.lang` 或特定插件 adapter。
- `scripts/`：本机辅助脚本，不属于 Neovim 运行时核心链路。

## 4. Core 层

- `lua/core/options.lua`：leader、Nerd Font 检测、折叠基础配置、clipboard、搜索、split、listchars 等基础编辑行为。
- `lua/core/keymaps.lua`：通过 `custom.keymaps` 注册基础编辑器快捷键、LSP 管理命令、窗口导航、终端退出等交互入口。
- `lua/core/autocmds.lua`：基础事件自动化，目前以 yank 高亮等轻量行为为主。

## 5. 配置与共享库层

`custom.config` 暴露：

- `get()`：返回 defaults + env override + `custom.config.local` override 后的配置。
- `get_value(path, fallback)`：按路径读取配置。
- `is_enabled(name)`：读取 feature flag。

`custom.lib` 显式暴露：

- `custom.lib.icons`
- `custom.lib.git`
- `custom.lib.path`
- `custom.lib.system`
- `custom.lib.diagnostics`
- `custom.lib.highlight`

`lua/globals.lua` 只保留 `_G.tools` 兼容桥；新模块不得新增直接依赖。

## 6. 插件系统

插件由 Lazy.nvim 管理，`lua/custom/plugins/` 下的 Lua 文件作为 specs 自动导入。当前规则：复杂业务逻辑应迁到 `custom.{domain}` 模块，plugin spec 只保留依赖、加载条件、opts 和短 adapter。

主要能力分组：

- UI / 视觉：Kanagawa theme、Noice、tiny-inline-diagnostic、自研 statusline。
- 搜索 / 导航：Telescope、Trouble、Namu、Which-Key。
- LSP / 补全：Mason、Mason-LSPConfig、mason-tool-installer、Blink.cmp、自定义 LSP registry。
- 格式化 / lint：Conform.nvim、nvim-lint。
- Git / 文件管理：gitsigns、LazyGit、Yazi。
- 语法结构：Treesitter、ufo、自定义 folding。
- 语言专项：Python、Lua、Rust、Markdown/YAML、前端相关配置。

## 7. LSP 架构

LSP 子系统分层：

- `lua/custom/plugins/lsp.lua`：Lazy spec 桥接入口。
- `lua/custom/lsp/init.lua`：LSP orchestration。
- `lua/custom/lsp/capabilities.lua`：Blink capabilities 与 foldingRange 能力合成。
- `lua/custom/lsp/diagnostics.lua`：native diagnostic policy。
- `lua/custom/lsp/roots.lua`：root_dir helper。
- `lua/custom/lsp/registry.lua`：server registry 与 Mason install list。
- `lua/custom/lsp/attach.lua`：`LspAttach` 后行为、LSP keymaps、document highlight、inlay hints、`gd` 聚合跳转。
- `lua/custom/lsp/server_settings/*.lua`：单 server 覆盖配置。

当前 LSP 主路径使用 `vim.lsp.config()` / `vim.lsp.enable()`；`nvim-lspconfig` 作为 server config provider。

## 8. 语言与工具链支持

- Python：`custom.lang.python` profile，Basedpyright + Ruff + venv-selector。
- Frontend：`custom.lang.frontend` profile，vtsls + tailwindcss + biome，format policy 支持 project-aware resolver。
- Rust：`custom.lang.rust` profile，rustaceanvim + crates + clippy + codelldb/neotest。
- Markdown：`custom.lang.markdown` profile，marksman + render-markdown + preview + Obsidian vault mode。
- Lua：Lua LS + lazydev + Stylua。

## 9. UI 与交互子系统

- Theme：Kanagawa Dragon，未来主题通过 `custom.config.ui.theme` 切换。
- Statusline：`lua/custom/ui/statusline/` 自研响应式状态栏，分为 context / palette / components / render。
- Command / notification UI：`custom.ui.noice` + Noice.nvim。
- Diagnostics UI：`custom.ui.diagnostics` + tiny-inline-diagnostic；问题列表由 Trouble 负责，搜索诊断由 Telescope 负责。
- Search / LSP locations UI：`custom.ui.picker` + Telescope。
- File manager：`custom.ui.explorer` + Yazi.nvim。
- Git terminal UI：LazyGit。

UI 层可以依赖 `custom.lib.*` 和 `custom.config`，不得依赖 `custom.lang.*` / `custom.debug.*` / `custom.test.*`。

## 10. 格式化、Lint 与保存时行为

- `custom.format.registry` 负责 formatter policy；Conform.nvim 负责执行。
- `custom.lint.registry` 负责 linter policy；nvim-lint 负责执行。
- 保存时格式化默认超时 500ms，使用 LSP fallback。
- 主要 formatter：Lua `stylua`，Rust `rustfmt`，Frontend `biome` 或 `prettierd/prettier`，Markdown/YAML `prettierd/prettier`。
- Markdown 使用 `markdownlint-cli2`，Dockerfile 使用 `hadolint`。

## 11. Folding 与 Treesitter

- Treesitter 负责语法高亮与结构化缩进基础。
- ufo 提供通用 folding 能力。
- `lua/custom/folding/` 提供自定义 filetype 分发；当前重点是 Python docstring / import 等结构折叠增强。
- folding 应按文件类型扩展，避免把语言特定逻辑塞进通用入口。

## 12. 外部接口与运行环境

- Neovim >= 0.10.0。
- 推荐 Nerd Font，README 推荐 JetBrainsMono Nerd Font。
- 基础系统工具：`git`, `make`, `gcc`, `ripgrep`, `fd`, `unzip`。
- 语言环境：Python/pip，Node.js/npm 或 yarn。
- RPC pipe 默认 `/tmp/nvim`，可通过 `NVIM_SERVER_PIPE` / `custom.config.local` 覆盖。
- `scripts/setup_editor.sh` 是本机环境辅助脚本，会修改 shell / Kitty 配置；不属于运行时架构核心。

## 13. 版本治理

- `.gitignore` 当前忽略 `lazy-lock.json`，因此 lockfile 作为本地状态而非提交资产。
- Mason tool list 由 `custom.lsp.registry.ensure_installed()` 汇总。
- `auto_install_tools` / `auto_update_tools` 由 `custom.config.features` 控制，可通过环境变量覆盖。
- Treesitter 当前 `auto_install = true`。
- fast-moving plugins 的版本策略记录在 `custom.version.policy()`。

## 14. 代码风格与维护约定

- 完整插件配置文件按 Header / Options Components / Enhancement Methods / Core Logic / Plugin Spec 组织；新迁移后的 plugin spec 可缩短为 adapter。
- 仅当前文件使用的私有函数使用 `_` 前缀。
- 注释使用 LuaDoc 风格，复杂 public API / resolver / adapter 需写英文注释。
- Lua 格式遵循 `.stylua.toml`。
- 架构文档以实际代码为准；README 可保留对外简化结构说明。
