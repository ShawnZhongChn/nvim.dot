# nvim.dot

> **极简黑白美学 (Minimalist Monochrome) Neovim 配置**

基于 [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) 构建，专注于**高性能**与**视觉纯净**。本配置深度优化了 Python 与 Lua 开发体验，并集成了一套完全自定义的响应式状态栏。

## ✨ 核心特性 (Features)

### 🎨 视觉与交互 (Visual & UI)
- **主题**: [github-monochrome](https://github.com/idr4n/github-monochrome.nvim) (Dark)，极致的黑白高对比度体验。
- **状态栏**: `lua/custom/plugins/status-line.lua` —— **完全手写**的轻量级状态栏。
  - 零依赖 (仅需 `mini.icons`)。
  - 响应式设计：小窗口自动隐藏 Git/路径信息。
  - 独家滚动条组件 (Visual Scrollbar)。
- **通知系统**: 集成 `Noice.nvim`，提供优雅的消息提示与命令行弹窗。
- **文件树**: `Oil.nvim` 提供如编辑缓冲区般的文件管理体验。

### 🐍 Python 深度增强
- **LSP**: 使用 **Basedpyright** 替代 Pyright，提供更严格的类型检查。
- **Linting & Formatting**: 全面接管于 **Ruff** (极速)，搭配 `Conform.nvim` 实现保存自动格式化。
- **Docstrings**: 独家 Treesitter 增强，支持 Python 文档字符串的智能折叠。
- **环境管理**: 自动识别 `pyproject.toml`, `requirements.txt` 等项目根目录。

### 🛠️ 核心工具链
- **插件管理**: [Lazy.nvim](https://github.com/folke/lazy.nvim) —— 极速启动。
- **补全引擎**: [Blink.cmp](https://github.com/Saghen/blink.cmp) —— 下一代高性能补全源。
- **LSP 管理**: Mason + Mason-LSPConfig 全自动安装/升级工具。
- **模糊搜索**: Telescope —— 极速查找文件、文本与帮助文档。
- **Git 集成**: LazyGit (`<leader>lg`) 浮窗终端集成。

## 🚀 安装 (Installation)

### 1. 前置要求 (Prerequisites)
- **Neovim** >= 0.10.0
- **Nerd Font**: 推荐 [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) 以获得最佳图标支持。
- **系统工具**: `git`, `make`, `gcc`, `ripgrep`, `fd`, `unzip`。
- **语言环境**: Python (pip), Node.js (npm/yarn) —— 用于安装 LSP/Formatter。

### 2. 克隆配置 (Clone)

**Linux / macOS:**
```bash
# 备份旧配置
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# 克隆本仓库
git clone https://github.com/shawnzhong-su/nvim.dot.git ~/.config/nvim
```

### 3. 首次启动
打开 Neovim，Lazy 将自动安装所有插件。
```bash
nvim
```
安装完成后建议运行 `:checkhealth` 检查环境健康状况。

## 📂 项目结构 (Structure)

```text
~/.config/nvim
├── init.lua              # 入口文件 (Bootstrap)
├── lua
│   ├── globals.lua       # 全局变量与工具函数
│   ├── core              # 核心配置
│   │   ├── options.lua   # vim.opt 设置
│   │   ├── keymaps.lua   # 基础快捷键
│   │   └── autocmds.lua  # 自动命令
│   └── custom
│       ├── health.lua    # 自定义健康检查
│       └── plugins       # 插件模块 (按功能拆分)
│           ├── lsp.lua   # LSP (Basedpyright, Lua_ls)
│           ├── conform.lua # 格式化配置
│           ├── theme.lua   # GitHub Monochrome 主题
│           ├── status-line.lua # 自研状态栏
│           └── ...
└── ...
```

## ⌨️ 常用快捷键 (Keymaps)

> `Leader` 键设置为 **空格 (`<Space>`)**

| 按键 | 功能 | 描述 |
| :--- | :--- | :--- |
| `<leader>ff` | Find Files | 查找文件 |
| `<leader>fw` | Live Grep | 全局文本搜索 |
| `<leader>lg` | LazyGit | 打开 Git 浮窗 |
| `<leader>e` | Oil | 打开文件管理器 (当前目录) |
| `<leader>cf` | Format | 格式化当前代码 |
| `<leader>q` | Quit | 关闭当前窗口 |
| `gd` | Goto Definition | 跳转定义 (合并引用) |
| `grr` | References | 查看引用 |

*更多快捷键请按 `<leader>` 等待 `Which-Key` 提示面板弹出。*

## 📜 License
MIT
