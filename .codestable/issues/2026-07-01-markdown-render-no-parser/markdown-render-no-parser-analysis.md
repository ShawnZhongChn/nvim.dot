---
doc_type: issue-analysis
issue: 2026-07-01-markdown-render-no-parser
status: confirmed
root_cause_type: config
related:
  - markdown-render-no-parser-report.md
tags:
  - markdown
  - treesitter
  - render-markdown
---

# Markdown Render No Parser 根因分析

## 1. 问题定位

| 关键位置 | 说明 |
|---|---|
| `lua/custom/plugins/render-markdown.lua:58` | Markdown 展示美化由 `MeanderingProgrammer/render-markdown.nvim` 提供，不是由 Markdown LSP 提供。 |
| `lua/custom/plugins/render-markdown.lua:64` | 插件按 `ft = { 'markdown', 'Avante' }` 懒加载；打开 Markdown 文件时会 attach。 |
| `lua/custom/plugins/treesitter.lua:7` | 当前配置把 `markdown` / `markdown_inline` 写在旧式 `ensure_installed` 列表中。 |
| `lua/custom/plugins/treesitter.lua:33` | 当前配置仍使用旧式 `auto_install = true` 期望自动安装 parser。 |
| `.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/config.lua:14` | 当前安装的 `nvim-treesitter` `setup()` 只处理 `install_dir`，不会消费旧式 `ensure_installed` / `auto_install` / `highlight` / `indent` 配置。 |
| `.local/share/nvim/lazy/nvim-treesitter/README.md:59` | 当前 `nvim-treesitter` API 要通过 `require('nvim-treesitter').install { ... }` 安装 parser。 |
| `.local/share/nvim/lazy/nvim-treesitter/README.md:83` | 当前 `nvim-treesitter` 不再通过旧模块自动启用高亮，需在 filetype 入口调用 `vim.treesitter.start()`。 |
| `lua/custom/lsp/registry.lua:25` | Markdown LSP `marksman` 已配置；它负责语言服务，不负责 render-markdown 的内联渲染。 |

本地检查还发现当前 Treesitter parser 目录中没有 `markdown.so` / `markdown_inline.so`。这与报错 `No parser for language "markdown"` 一致。

## 2. 失败路径还原

**正常路径**：用户打开 `.md` 文件 → Lazy.nvim 按 `ft=markdown` 加载 `render-markdown.nvim` → `render-markdown` attach 到 buffer → Treesitter 能找到 `markdown` 与 `markdown_inline` parser → 插件读取 Markdown 语法树并渲染标题、列表、checkbox、表格等元素。

**失败路径**：用户打开 `.md` 文件 → `render-markdown.nvim` 正常按 filetype 加载并 attach → 插件调用 Treesitter 查询 Markdown 语法 → 当前机器上没有可用的 `markdown` parser → Neovim 抛出 `No parser for language "markdown"` → 插件 attach 中断，Markdown 展示美化不生效。

**分叉点**：`lua/custom/plugins/treesitter.lua:7` — 配置仍使用旧版 `nvim-treesitter` 的 `ensure_installed` / `auto_install` 写法；但当前安装的 `nvim-treesitter` 主分支 `setup()` 不再消费这些字段，因此 `markdown` parser 没有被该配置安装。

## 3. 根因

**根因类型**：config

**根因描述**：项目的 Treesitter 配置还停留在旧版 `nvim-treesitter` 模块配置模型：通过 `setup({ ensure_installed = ..., auto_install = true, highlight = ..., indent = ... })` 声明 parser 安装与功能启用。当前 lockfile 中的 `nvim-treesitter` 已是新版主分支 API，`setup()` 只处理 `install_dir`，parser 需要显式调用 `require('nvim-treesitter').install({ ... })` 安装；高亮也需要通过 filetype autocmd / ftplugin 调用 `vim.treesitter.start()` 启用。结果是 `markdown` / `markdown_inline` parser 从未被当前配置安装，`render-markdown.nvim` 在 Markdown buffer attach 时找不到 parser 并报错。

**是否有多个根因**：否。`marksman` LSP 已配置，LSP 缺失不是本问题的主因；它即使未启动，也不会导致 `No parser for language "markdown"`。

## 4. 影响面

- **影响范围**：不只影响 Markdown。凡是依赖当前 `ensure_installed` / `auto_install` 旧配置自动安装 parser 的语言，在新 API 下都可能没有 parser；只是 Markdown 因 `render-markdown.nvim` attach 时强依赖 parser，最先以报错形式暴露。
- **潜在受害模块**：
  - `render-markdown.nvim`：Markdown 内联渲染直接失败。
  - Treesitter 高亮 / 缩进：`lua/custom/plugins/treesitter.lua` 中旧式 `highlight` / `indent` 配置在当前 API 下也不会按预期生效。
  - 其他依赖 Treesitter parser 的插件或 filetype 行为：例如 folding / 结构导航类能力。
- **数据完整性风险**：无。该问题影响编辑器展示和语法结构能力，不会修改 Markdown 文件内容。
- **严重程度复核**：维持 P2。Markdown 展示体验稳定失效，并可能暴露 Treesitter 配置整体漂移，但不导致数据损坏，也不阻塞基础编辑。

## 5. 修复方案

### 方案 A：更新 Treesitter adapter 到当前 API

- **做什么**：修改 `lua/custom/plugins/treesitter.lua`，把语言列表提成单独常量；在插件 `config` 中调用 `require('nvim-treesitter').setup()` 后，显式执行 `require('nvim-treesitter').install(languages)`，并为已声明语言建立 `FileType` autocmd 调用 `vim.treesitter.start()`；对缩进按当前 API 设置 `indentexpr`。
- **优点**：从根因上对齐当前 `nvim-treesitter` API；修复 Markdown parser 缺失，同时恢复其他语言 parser 安装路径和 Treesitter 高亮启用路径。
- **缺点 / 风险**：首次启动可能触发 parser 下载/编译；运行自动化 `nvim` 时也可能产生网络访问和本机 parser 安装状态写入。
- **影响面**：主要改 `lua/custom/plugins/treesitter.lua`，影响所有 Treesitter 语言，但方向是恢复既有意图。

### 方案 B：保守地只修 Markdown parser 安装

- **做什么**：只在 `render-markdown.nvim` 或 Markdown ftplugin 附近检测并安装 / 提示安装 `markdown` 与 `markdown_inline` parser，例如让用户执行 `:TSInstall markdown markdown_inline`，或在 Markdown 入口对缺 parser 做保护。
- **优点**：改动小，风险局限在 Markdown。
- **缺点 / 风险**：只补表面问题，旧式 Treesitter 配置漂移仍然存在；其他语言 parser / 高亮可能继续不符合预期。
- **影响面**：主要影响 Markdown；不能系统性修复 Treesitter 配置。

### 方案 C：回退或固定旧版 nvim-treesitter 配置模型

- **做什么**：把 `nvim-treesitter` 固定到支持旧式 `ensure_installed` / `highlight` 模块配置的旧版本，保留现有 `treesitter.lua` 写法。
- **优点**：当前项目代码改动少。
- **缺点 / 风险**：版本治理倒退；后续继续吃不到新 API 与修复；和 lockfile 当前主分支状态相冲突。
- **影响面**：影响插件版本策略；不适合长期维护。

### 推荐方案

**推荐方案 A**，理由：问题根因不是单个 Markdown LSP 或单个插件，而是 `nvim-treesitter` 配置写法已经和当前插件 API 不匹配。方案 A 改动范围仍集中在一个 adapter 文件，但能一次性恢复 parser 安装与 Treesitter 启用路径，副作用最可控，也符合项目“插件 spec 只保留短 adapter、复杂逻辑集中”的架构方向。
