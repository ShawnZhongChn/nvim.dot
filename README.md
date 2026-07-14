# ShawnVim

ShawnVim 是一个独立维护的 Neovim 配置发行版。首个版本以 LazyVim 16.0.0 的固定源码快照为基础，核心源码直接存放在本仓库的 `lua/shawnvim/`，运行时不会下载或加载 `LazyVim/LazyVim`。

## 安装

要求 Neovim >= 0.11.2，以及 `git`、`make`、C 编译器、`ripgrep`、`fd`、`unzip`。

```bash
git clone https://github.com/ShawnZhongChn/nvim.dot.git ~/.config/nvim
nvim
```

首次启动会自动安装 lazy.nvim 和默认插件。

## 目录

- `lua/shawnvim/`：ShawnVim 发行版核心。
- `lua/config/`：用户 options、keymaps 和 autocmds。
- `lua/plugins/`：用户插件扩展。
- `docs/`：固定版本的上游开发文档 Markdown，共 138 个文件。
- `doc/ShawnVim.txt`：Neovim help 文档。

## 来源

源码来源与许可证见 [UPSTREAM.md](UPSTREAM.md)，文档来源见 [UPSTREAM-DOCS.md](UPSTREAM-DOCS.md)。

根目录的 Apache-2.0 `LICENSE` 适用于导入的源码和 ShawnVim 自有代码；`docs/` 中转载文档的权利边界以 `UPSTREAM-DOCS.md` 为准。
