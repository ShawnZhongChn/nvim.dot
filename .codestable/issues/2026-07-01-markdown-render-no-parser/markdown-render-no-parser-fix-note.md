---
doc_type: issue-fix
issue: 2026-07-01-markdown-render-no-parser
path: standard
fix_date: 2026-07-01
related:
  - markdown-render-no-parser-analysis.md
tags:
  - markdown
  - treesitter
  - render-markdown
---

# Markdown Render No Parser 修复记录

## 1. 实际采用方案

采用 analysis 中确认的方案 A：更新 Treesitter adapter 到当前 `nvim-treesitter` API。

实际落地时做了一个实现调整：parser 安装不放在每次启动的 `config` 阶段，而放到 Lazy.nvim 的 `build` 阶段。原因是当前 `nvim-treesitter` parser 安装会下载并编译 parser，放在启动路径会引入网络访问、编译耗时和本机状态写入；`build` 阶段更符合插件安装 / 更新语义。

核心修复点：

1. 将 `lua/custom/plugins/treesitter.lua` 从旧式 `ensure_installed` / `auto_install` / `highlight` / `indent` 配置模型改为当前 API adapter。
2. 使用 `require('nvim-treesitter').install(_languages, { max_jobs = 1 }):wait(300000)` 作为 Lazy build 函数，显式安装声明 parser。
3. 为声明的 filetype 建立 `FileType` autocmd，打开对应 buffer 时调用 `vim.treesitter.start()`。
4. 对已启动 Treesitter 的 buffer 设置当前 API 下的 `indentexpr`。
5. 从 parser 安装列表中移除不受当前 `nvim-treesitter` parser registry 支持的 `jsonc`，但保留 `jsonc` filetype，由 `json` parser 覆盖。
6. 安装缺失的外部 `tree-sitter` CLI 后，安装 `markdown` / `markdown_inline` parser。

## 2. 改动文件清单

- `lua/custom/plugins/treesitter.lua`
  - 提取 `_languages` parser 安装列表和 `_filetypes` 启动列表。
  - 将 Lazy build 从 `:TSUpdate` 改为 `_install_declared_parsers`。
  - 添加 `FileType` autocmd，在相关 filetype 中调用 `vim.treesitter.start()`。
  - 添加 Treesitter indentexpr 设置。
  - 移除旧版 API 字段：`ensure_installed`、`auto_install`、`highlight`、`indent`。
- `.codestable/issues/2026-07-01-markdown-render-no-parser/markdown-render-no-parser-analysis.md`
  - 用户确认方案后将 `status` 更新为 `confirmed`。
- `.codestable/issues/2026-07-01-markdown-render-no-parser/markdown-render-no-parser-fix-note.md`
  - 记录本次修复闭环。

## 3. 验证结果

### 复现步骤验证

已创建临时 Markdown 文件 `/tmp/claude-markdown-render-test.md` 并用当前 Neovim 配置 headless 打开。

验证命令使用 `NVIM_FEATURE_OBSIDIAN=false` 关闭本机 Obsidian workspace 依赖，避免无关 workspace 配置影响 Markdown parser 验证。

结果：

```text
ft=markdown
parser=true
render_loaded=true
```

说明：

- buffer filetype 正确识别为 `markdown`。
- `vim.treesitter.get_parser(0, "markdown")` 成功，`markdown` parser 已可用。
- `render-markdown.nvim` 已加载。
- 未再出现本 issue 的核心错误 `No parser for language "markdown"`。

### 期望行为验证

Markdown buffer 已能拿到 Treesitter Markdown parser，`render-markdown.nvim` 的 attach 前置条件恢复。原先导致展示美化中断的 parser 缺失错误已消失。

### 影响面回归

- `markdown` / `markdown_inline` parser 文件已存在于本机 Treesitter parser 目录。
- `jsonc` 不再作为独立 parser 安装，避免当前 registry 下的 unsupported language warning；`jsonc` filetype 仍保留在启动列表中。
- Treesitter 启动改为 `FileType` autocmd，覆盖原配置声明的主要语言 filetype。

### 验证中观察到的非本 issue 问题

验证时仍会出现以下无关错误：

```text
Invalid plugin spec {
  enabled = false
}
```

这来自其他 disabled plugin spec，不属于本次 Markdown parser 缺失问题的分析范围；本次未修改。

未设置 Obsidian workspace 时，直接打开 Markdown 还可能触发 `obsidian.nvim` workspace 报错；验证中已用 `NVIM_FEATURE_OBSIDIAN=false` 隔离该本机配置问题。本次未修改 Obsidian 配置。

## 4. 遗留事项

- 本机需要存在 `tree-sitter` CLI，否则新版 `nvim-treesitter` parser 编译会失败。本次已通过 `npm install -g tree-sitter-cli` 安装。
- 重新安装全量 parser 时，个别 parser 曾出现 GCC internal compiler error；`markdown` 与 `markdown_inline` 已安装成功，未影响本 issue 修复。若后续其他语言 Treesitter parser 缺失，可单独重试对应 parser 或另开 issue。
- 建议后续单独处理 `Invalid plugin spec { enabled = false }`，它会污染 Neovim 启动输出，但不属于本次 Markdown parser 根因。
