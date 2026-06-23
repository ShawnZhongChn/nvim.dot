# nvim.dot 能力概要

> 状态：从 README.md 回填初版
> 创建日期：2026-06-22

## 1. 能力定位

nvim.dot 是一套面向日常开发的 Neovim 配置，强调极简黑白视觉、高性能启动与模块化维护体验，并对 Python 与 Lua 开发进行深度优化。

## 2. 核心能力

### 2.1 视觉与交互

- 使用 GitHub Monochrome dark theme，提供黑白高对比体验。
- 自研轻量响应式状态栏，主要依赖 `mini.icons`。
- Noice.nvim 提供消息提示和命令行 UI。
- Yazi.nvim 提供异步文件管理体验。

### 2.2 Python 深度增强

- 使用 Basedpyright 替代 Pyright，提供更严格的类型检查。
- 使用 Ruff 作为主要 lint / format 工具链的一部分。
- 通过 Conform.nvim 实现保存自动格式化。
- 提供 Python docstring 等结构的 Treesitter/folding 增强。
- 自动识别 `pyproject.toml`、`requirements.txt` 等 Python 项目根目录信号。

### 2.3 核心工具链

- Lazy.nvim：插件管理。
- Blink.cmp：补全引擎。
- Mason / Mason-LSPConfig：LSP 与外部工具安装管理。
- Telescope：文件、文本、帮助和 LSP location 搜索。
- LazyGit：Git 浮窗终端集成。

## 3. 用户入口

- 首次启动：运行 `nvim`，由 Lazy.nvim 自动安装插件。
- 环境健康检查：`:checkhealth`。
- 常用快捷键以 `<Space>` 作为 leader，例如 `<leader>ff` 查找文件、`<leader>fw` live grep、`<leader>lg` 打开 LazyGit、`<leader>cf` 格式化当前代码。

## 4. 边界与非目标

- 本文档只记录当前配置能力概要，不替代根目录 README 的安装说明。
- 详细架构现状以 `.codestable/architecture/ARCHITECTURE.md` 为准。
