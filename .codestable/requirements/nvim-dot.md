# nvim.dot 能力概要

> 状态：从 README.md 回填初版
> 创建日期：2026-06-22

## 1. 能力定位

nvim.dot 是一套面向日常开发的 Neovim 配置，强调极简黑白视觉、高性能启动与模块化维护体验，并对 Python、Lua 与 Java 开发进行深度优化。

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

### 2.3 Java / Maven 开发环境

- 使用 JDTLS 为 Maven Java 项目提供诊断、补全、hover、跳转定义 / 引用、rename、code action 与 organize imports。
- 自动以 `pom.xml` / `mvnw` 识别 Java project root，避免单文件目录误判。
- 通过 Mason 管理 `jdtls`、`google-java-format` 和 Spring Boot tools；通过 SDKMAN 引导安装 JDK 21+ 与 Maven。
- 支持 Lombok javaagent 与 Spring Boot bundle，减少 Lombok / Spring 项目中的虚假诊断和导航失真。
- Java 保存格式化使用 `google-java-format`，保留 LSP fallback。

### 2.4 核心工具链

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
