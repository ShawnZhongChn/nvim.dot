# nvim.dot 架构总入口

> 状态：已从 README.md / GEMINI.md / 代码结构回填初版
> 创建日期：2026-06-22

## 1. 项目简介

nvim.dot 是一套高度定制的 Neovim Lua 配置，基于 kickstart.nvim 演进而来，核心目标是：

- Minimalist Monochrome：极简黑白、高对比度视觉体验。
- 高性能：以 Lazy.nvim、轻量自研状态栏和按需加载插件为基础。
- 模块化：core、custom plugins、LSP、folding 等能力分层组织。
- Python / Lua 深度优化：基于 Basedpyright、Ruff、Lua LS、Stylua 等工具链。

## 2. 启动流程

`init.lua` 是唯一入口，当前启动链路为：

1. 加载 `lua/globals.lua`，建立全局工具与 UI 图标表。
2. 禁用 netrw，避免与外部文件管理插件冲突。
3. 加载 `lua/core/options.lua`、`lua/core/keymaps.lua`、`lua/core/autocmds.lua`。
4. 尝试启动固定 Neovim RPC pipe `/tmp/nvim`。
5. Bootstrap Lazy.nvim。
6. 通过 `require('lazy').setup({ { import = 'custom.plugins' } })` 自动导入插件 specs。

## 3. 顶层目录结构

- `init.lua`：Neovim 配置入口与 Lazy.nvim bootstrap。
- `lua/globals.lua`：全局 `_G.tools`、图标、Git/path/diagnostic helper。
- `lua/core/`：基础选项、基础快捷键、基础 autocmd。
- `lua/custom/plugins/`：Lazy.nvim 插件规格与插件级配置。
- `lua/custom/lsp/`：LSP 初始化、attach 行为、server/root/settings 配置。
- `lua/custom/lsp/server_settings/`：单个语言服务器的覆盖配置。
- `lua/custom/folding/`：自定义 folding 分发与语言实现。
- `after/ftplugin/`：文件类型后置配置。
- `scripts/`：本机辅助脚本，不属于 Neovim 运行时核心链路。

## 4. Core 层

- `lua/core/options.lua`：leader、Nerd Font 检测、折叠基础配置、clipboard、搜索、split、listchars 等基础编辑行为。
- `lua/core/keymaps.lua`：基础编辑器快捷键、诊断列表、LSP 管理命令、窗口导航、终端退出等交互入口。
- `lua/core/autocmds.lua`：基础事件自动化，目前以 yank 高亮等轻量行为为主。

## 5. 全局工具层

`lua/globals.lua` 暴露 `_G.tools`，供多个插件和自研组件复用：

- `tools.ui.icons` / `tools.ui.kind_icons`：统一图标表。
- `tools.get_path_root(path)`：路径根目录识别。
- `tools.get_git_remote_name(root)` / `tools.get_git_branch(root)`：Git 信息获取与缓存。
- `tools.diagnostics_available()`：诊断能力探测。
- `tools.hl_str(hl, str)`：statusline 等 UI 的高亮字符串 helper。
- `tools.group_number(num, sep)`：数字分组显示。
- `tools.reveal_in_explorer(path)`：系统文件管理器揭示入口。

## 6. 插件系统

插件由 Lazy.nvim 管理，`lua/custom/plugins/` 下的 Lua 文件作为 specs 自动导入。

主要能力分组：

- UI / 视觉：GitHub Monochrome theme、Noice、tiny-inline-diagnostic、自研 statusline。
- 搜索 / 导航：Telescope、Trouble、Namu、Which-Key。
- LSP / 补全：Mason、Mason-LSPConfig、mason-tool-installer、Blink.cmp、自定义 LSP 桥接。
- 格式化 / lint：Conform.nvim、nvim-lint。
- Git / 文件管理：gitsigns、LazyGit、Yazi。
- 语法结构：Treesitter、ufo、自定义 folding。
- 语言专项：Python、Lua、Rust、Markdown/YAML、前端相关配置。

## 7. LSP 架构

LSP 子系统分层：

- `lua/custom/plugins/lsp.lua`：Lazy spec 桥接入口。
- `lua/custom/lsp/init.lua`：LSP setup、诊断 UI、Mason 工具安装、Blink capabilities 合并、server enable。
- `lua/custom/lsp/servers.lua`：server 列表、root marker、server settings 组合。
- `lua/custom/lsp/attach.lua`：`LspAttach` 后行为、LSP keymaps、document highlight、inlay hints、`gd` 聚合跳转。
- `lua/custom/lsp/server_settings/*.lua`：单 server 覆盖配置。

当前文档迁移时以实际代码 `servers.lua` 为准；旧 `GEMINI.md` 中的 `server_names.lua` 描述已过时。

## 8. 语言与工具链支持

- Python：Basedpyright + Ruff + Conform + Python folding。
- Lua：Lua LS + lazydev + Stylua。
- Frontend：vtsls + tailwindcss + biome。
- YAML / Markdown：yamlls、marksman、prettierd/prettier、markdownlint-cli2。
- Rust：rustaceanvim 管理 rust_analyzer，不走 Mason 的通用路径。

## 9. UI 与交互子系统

- Theme：GitHub Monochrome，保持黑白极简高对比。
- Statusline：`lua/custom/plugins/status-line.lua` 自研响应式状态栏，消费 `_G.tools` 的 Git、诊断、路径与高亮能力，仅依赖 `mini.icons`。
- Command / notification UI：Noice.nvim。
- Search / LSP locations UI：Telescope。
- File manager：Yazi.nvim。
- Git terminal UI：LazyGit。
- Diagnostics / symbols：tiny-inline-diagnostic、Trouble、Namu 等。

## 10. 格式化、Lint 与保存时行为

- Conform.nvim 负责格式化，保存时通过 `BufWritePre` 触发。
- 保存时格式化默认超时 500ms，使用 LSP fallback。
- C/C++ 保存时格式化禁用。
- 主要 formatter：Lua `stylua`，Rust `rustfmt`，JS/TS/React/CSS/JSON/JSONC `biome`，Markdown/YAML `prettierd` 优先并回退 `prettier`。
- nvim-lint 负责非 LSP lint；Markdown 使用 `markdownlint-cli2`，Dockerfile 使用 `hadolint`；触发点包括 `BufEnter`、`BufWritePost`、`InsertLeave`。

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
- `init.lua` 会尝试启动 `/tmp/nvim` RPC pipe，供外部工具连接。
- `scripts/setup_editor.sh` 是本机环境辅助脚本，会修改 shell / Kitty 配置；不属于运行时架构核心。

## 13. 代码风格与维护约定

- 完整插件配置文件按 Header / Options Components / Enhancement Methods / Core Logic / Plugin Spec 组织。
- 仅当前文件使用的私有函数使用 `_` 前缀。
- 注释使用 LuaDoc 风格 `---`，常用 `@Note`、`@return`、`@param`。
- Lua 格式遵循 `.stylua.toml`。
- 架构文档以实际代码为准；README 可保留对外简化结构说明。
