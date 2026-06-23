# Attention

本文件是 CodeStable 技能启动必读的项目注意事项入口。所有 CodeStable 子技能开始工作前必须读取它。

## 项目碎片知识

<!-- cs-note managed: 用 cs-note 维护，新条目按下面分节追加 -->

### 编译与构建

- 本项目是 Neovim Lua 配置，要求 Neovim >= 0.10.0。
- 基础系统依赖：`git`, `make`, `gcc`, `ripgrep`/`rg`, `fd`, `unzip`。
- 语言运行时依赖：Python/pip 与 Node.js/npm 或 yarn，用于 LSP、formatter、lint 工具安装。
- Lua 格式遵循 `.stylua.toml`：2 空格缩进、Unix 换行、160 列、单引号优先。

### 运行与本地起服务

- 首次启动通过 `nvim` 触发 Lazy.nvim 自动安装插件；安装后建议运行 `:checkhealth`。
- 自动化运行 `nvim` 可能触发 Lazy.nvim clone、插件安装或 Mason 工具安装，会产生网络访问和本机状态写入。

### 测试

- 环境检查首选 Neovim 内运行 `:checkhealth`；LSP 检查可用 `:checkhealth vim.lsp` 或项目提供的 `:LspInfo` alias。

### 命令与脚本陷阱

- 不要未经用户明确确认运行 `scripts/setup_editor.sh`：它会修改用户 `~/.zshrc` 和 Kitty 配置。

### 路径与目录约定

- `init.lua` 是入口；核心配置放在 `lua/core/`；自定义能力放在 `lua/custom/`。
- 插件 specs 放在 `lua/custom/plugins/`，由 Lazy.nvim 自动 import。
- LSP 配置放在 `lua/custom/lsp/`；服务特定配置放在 `lua/custom/lsp/server_settings/`。
- 完整插件配置文件按 Header / Options Components / Enhancement Methods / Core Logic / Plugin Spec 组织。
- 仅当前文件使用的私有函数使用 `_` 前缀；注释使用 LuaDoc `---` 与 `@Note` / `@return` / `@param`。

### 环境变量与凭证

- 避免提交本地测试、调试、日志和临时数据文件；以 `.gitignore` 为准。

### 其他

- UI 改动保持 Minimalist Monochrome、高性能、轻量依赖原则。
- 自研状态栏位于 `lua/custom/plugins/status-line.lua`，目标是轻量、响应式，仅依赖 `mini.icons`；不要随意引入重型状态栏依赖替换。
