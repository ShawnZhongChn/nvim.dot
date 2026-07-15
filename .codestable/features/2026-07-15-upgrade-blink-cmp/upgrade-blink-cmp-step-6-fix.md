# S6 验证窄修复

## 失败的退出信号

S6 要求 checkhealth、Rust matcher 与 LSP/path/snippets/buffer/lazydev 候选证据全部可复验。

## 根因

1. `checkhealth blink.cmp` 在插件仍处于 lazy 状态时找不到 health module，需先显式加载插件。
2. provider fixture 首次用 `nvim -l` 启动，Neovim 不加载用户配置；改用正常启动后的 `:luafile`。
3. fixture 对 `nvim_exec_autocmds` 同时传入 `buffer` 和 `pattern`，违反 Neovim 0.12 API 契约。

## 允许修改范围

- 只修 CMD-004 的显式加载步骤和 `/tmp` provider fixture。
- 不修改 blink 配置、sources、按键或目标 lock。

## 必须复验

- CMD-004 输出非空且包含两条 Rust backend 成功文案。
- provider fixture 分别取得 buffer/path/snippets/lazydev/LSP 的可识别候选。
- target checkout 与 lock guard 保持不变。
