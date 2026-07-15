# S1 验证命令窄修复

## 失败的退出信号

S1 要求 PATH 中只有一个 canonical Neovim 0.12.4，且 apt `neovim` 已删除。

## 根因

第一次验证由默认 zsh 执行，`type -a -p` 的输出格式与 canonical command 指定的 bash 不同；第二次切到 bash 后，`set -u` 把 dpkg-query 格式模板 `${Status}` 误解析为未定义 shell 变量。宿主安装、版本和 apt 删除本身均已成功。

## 允许修改范围

- 只修 design/checklist 中 CMD-000 的 shell 转义。
- 不修改 Neovim 目标版本、安装路径、插件配置或其他 checklist step。

## 必须复验

- 在 `bash -lc` 中按 canonical realpath 去重 PATH 候选。
- 断言 `~/.local/bin/nvim` 指向 `~/.local/opt/nvim/bin/nvim`。
- 断言 Neovim 为 0.12.4 Release，apt `neovim` / `neovim-runtime` 均不存在。
