# Gemini Context: Neovim Configuration (nvim.dot)

This directory contains a highly customized, modular Neovim configuration focused on a minimalist monochrome aesthetic and deep optimization for Python and Lua development.

**Use nvim mcp server to get or test you need**

## 🚀 Project Overview

- **Core Philosophy:** Minimalist Monochrome (Black & White), high performance, and modular design.
- **Base:** Built upon `kickstart.nvim` but heavily refactored for modularity.
- **Key Technologies:**
  - **Neovim (>= 0.10.0)**
  - **Lua:** Used for the entire configuration.
  - **Lazy.nvim:** Plugin management.
  - **Mason & Mason-LSPConfig:** Automated tool/LSP installation.
  - **Blink.cmp:** Next-generation completion engine.
  - **Telescope:** Fuzzy finding and UI.
  - **Conform.nvim & nvim-lint:** Formatting and linting orchestration.

## 📂 Architecture & Structure

- `init.lua`: Main entry point. Bootstraps `lazy.nvim` and loads core/custom modules.
- `lua/globals.lua`: Global utilities (`_G.tools`), UI icons, and Git helpers.
- `lua/core/`:
  - `options.lua`: Standard Neovim options (`vim.opt`).
  - `keymaps.lua`: Basic editor keybindings (navigation, diagnostics).
  - `autocmds.lua`: Event-based automation.
- `lua/custom/lsp/`: **(Modular LSP System)**
  - `init.lua`: LSP setup logic, `on_attach` handlers, and core LSP keymaps.
  - `server_names.lua`: List of tools to be installed via Mason.
  - `server_settings/`: Individual Lua files for server-specific overrides (e.g., `pyright.lua`, `lua_ls.lua`).
- `lua/custom/plugins/`: Modular plugin specifications.
  - `status-line.lua`: Custom, zero-dependency, responsive status line.
  - `theme.lua`: GitHub Monochrome theme configuration.
  - `lsp.lua`: Bridge between `mason-lspconfig` and the custom LSP setup.

## Code Style

我的 Lua Nvim 配置风格规范如下： ### 1. 结构化布局 (Structural Layout) 一个完整的插件配置文件应按以下顺序排列，并使用水平分隔线区分逻辑块： _ **Header**: 文件用途注释。 _ **Options Components**: 拆分的私有配置项函数。 _ **Enhancement Methods**: 侧重逻辑的功能增强函数（如 Autocmd, Keymaps）。 _ **Core Logic**: 整合与初始化。 _ **Plugin Spec**: 返回 Lazy.nvim 格式的插件定义。 ### 2. 命名与注释规范 (Naming & Docs) _ **私有前缀**: 所有仅在当前文件使用的函数必须以 `_` 开头（如 `_setup_ui`）。 _ **标准注释**: 使用三连短横线 `---` 开头，支持 LuaDoc 格式。 _ `@Note`: 标注模块核心用途。 _ `@return`: 标注返回的数据类型（通常是 `table`）。 _ `@param`: 标注参数类型及含义。
