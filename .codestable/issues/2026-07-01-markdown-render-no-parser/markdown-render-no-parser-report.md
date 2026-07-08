---
doc_type: issue-report
issue: 2026-07-01-markdown-render-no-parser
status: confirmed
severity: P2
summary: Markdown 文件打开后 render-markdown 因缺少 markdown Treesitter parser 报错，展示美化不生效
tags:
  - markdown
  - treesitter
  - render-markdown
---

# Markdown Render No Parser Issue Report

## 1. 问题现象

打开 `.md` 文件后，标题、列表、checkbox、表格等 Markdown 元素仍显示为原始文本，没有被插件美化。所有 Markdown 文件都有该问题。

打开文件时出现 Lua 报错，核心错误为：

```text
No parser for language "markdown"
```

堆栈显示错误发生在 Markdown `FileType` autocmd / `render-markdown.nvim` attach 阶段，调用链包含 `vim.treesitter.query` 与 `render-markdown.nvim`。

## 2. 复现步骤

1. 启动 Neovim。
2. 打开任意 `.md` 文件。
3. 观察到 Markdown 标题、列表、checkbox、表格等仍显示为原始文本，没有被插件美化。
4. 同时可在消息里看到 `No parser for language "markdown"` 相关 Lua 报错。

复现频率：稳定，每次都有问题。

## 3. 期望 vs 实际

**期望行为**：打开 `.md` 文件后，标题、列表、checkbox、表格等 Markdown 元素应由插件自动美化渲染。

**实际行为**：打开 `.md` 文件后，这些元素一直保持原始 Markdown 文本显示，并且 `render-markdown.nvim` 在 attach 时因缺少 `markdown` Treesitter parser 报错。

## 4. 环境信息

- 涉及模块 / 功能：Neovim Markdown 编辑体验；`render-markdown.nvim`；Treesitter Markdown parser；Markdown filetype autocmd。
- 相关文件 / 函数：
  - `lua/custom/plugins/render-markdown.lua`
  - `lua/custom/plugins/treesitter.lua`
  - `lua/custom/lang/markdown.lua`
  - `after/ftplugin/markdown.lua`
- 运行环境：本地 Neovim 配置。
- 其他上下文：用户这次通过 Yazi 打开 Markdown 文件时触发报错，但问题范围是所有 `.md` 文件。

## 5. 严重程度

**P2** — Markdown 阅读/编辑展示体验稳定失效，但不阻塞 Neovim 主流程和代码编辑。

## 备注

用户最初怀疑是否少了 Markdown LSP；启动检查发现 `marksman` 已在 LSP registry 中配置，因此 LSP 缺失不是当前最直接的现象线索。当前可观测错误指向 Treesitter `markdown` parser 缺失或未正确安装/加载。
