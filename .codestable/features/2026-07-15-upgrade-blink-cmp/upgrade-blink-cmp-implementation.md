# Neovim 与 blink.cmp 升级实现证据

## S1 宿主升级

- 官方 release API：`https://api.github.com/repos/neovim/neovim/releases/tags/v0.12.4`
- 官方 asset：`https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.tar.gz`
- API 事实：`tag_name=v0.12.4`、`prerelease=false`、asset digest 为 `sha256:012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628`。
- 下载验证：`sha256sum -c` 通过；archive 含 `nvim-linux-x86_64/bin/nvim`；宿主架构为 `x86_64`。
- 删除前门禁：临时 Release binary 报告 `NVIM v0.12.4`，`vim.version()` 为 `0.12.4` 且 `prerelease=nil`；隔离 state/cache 的完整 ShawnVim 冷启动通过，无 error/import/config 通知或消息。
- 安装布局：`~/.local/opt/nvim` 保存完整发行包；`~/.local/bin/nvim -> ../opt/nvim/bin/nvim`。
- 删除结果：apt `neovim`、`neovim-runtime` 及不再需要的两个 LuaJIT 自动依赖已删除；没有 `~/.local/opt/nvim-*` 历史目录。
- 最终验证：PATH 候选按 realpath 去重后只有 `/home/shawn/.local/opt/nvim/bin/nvim`；新入口为 Release 0.12.4；CMD-000 通过。
- 失败恢复：首次复验误用 zsh 的 `type` 输出，第二次发现 dpkg `${Status}` 模板在 `set -u` 下转义错误；按 `upgrade-blink-cmp-step-1-fix.md` 只修 CMD-000 后复验通过，未扩大实现范围。
- 清洁度：tarball 暂留 `/tmp/nvim-linux-x86_64.tar.gz` 供宿主恢复，preflight state/cache 暂留 `/tmp/shawnvim-blink-cmp-upgrade/`，按 acceptance 最后一项清理。

## S2 隔离基线

- Worktree：`/home/shawn/.config/nvim-worktrees/blink-cmp-upgrade/nvim`，branch 为 `feat/blink-cmp-upgrade`，start gate 通过。
- XDG roots：config=`/home/shawn/.config/nvim-worktrees/blink-cmp-upgrade`；data/state/cache=`/tmp/shawnvim-blink-cmp-upgrade/target/{data,state,cache}`。Neovim 实际 `stdpath()` 按规范追加 `/nvim`，已同步修正验证命令。
- 基线 checkout：`/tmp/shawnvim-blink-cmp-upgrade/target/data/nvim/lazy/blink.cmp` 为 `485c03400608cb6534bbf84da8c1c471fc4808c0`，exact tag `v0.14.2`。
- 冷启动：Neovim 0.12.4 Release、四个 `stdpath()`、ShawnVim/lazy/blink require 与相关 Notifications 主动断言均通过。
- 失败恢复：首次误用 `Lazy! sync` 导致 lockfile 和多个 checkout 更新；立即恢复原 lockfile 并使用 `Lazy! restore` 将所有插件还原到基线，确认 `lazy-lock.json` 零 diff 后复验通过。
- 清洁度：所有插件下载与运行状态均位于 target XDG；日常 `~/.local/share/nvim` 未参与本步骤。

## S3 精确版本解析

- 配置：`lua/shawnvim/plugins/extras/coding/blink.lua` 的 stable spec 从 `version = "*"` 改为 `version = "1.10.2"`；main/Rust 本地 build opt-in 未启用。
- 更新动作：仅执行 `Lazy! update blink.cmp`。
- Lock guard：相对 `master` merge-base 的 JSON 键级比较只有 `blink.cmp` 变化，新 commit 精确为 `78336bc89ee5365633bcf754d93df01678b5c08f`。
- Checkout：target XDG 中 blink.cmp HEAD 为目标 commit，exact tag 为 `v1.10.2`。
- 清洁度：无其他 lock key 或插件配置变化；`git diff --check` 通过。

## S4 配置兼容

- 强制通过 lazy 加载 blink.cmp v1.10.2，`require("blink.cmp")` 与 `require("blink.cmp.config")` 成功。
- Snacks Notifications 中没有 error、blink 或 schema 相关错误。
- setup/schema 层除稳定版本 pin 外无需兼容性调整；现有 `<Left>/<Right> = {}`、sources 与 snippet 配置保持不变。
- 交互回归复现了现有 `<C-y>` 映射在无候选时吞掉原生按键的问题，因此按 blink.cmp v1.10.2 官方 keymap command chain 的 fallback 语义，将其最小调整为 `{ "select_and_accept", "fallback" }`。有候选时仍接受候选，无候选时交还原生 `<C-y>`；修复前/后证据见 S7。

## S5 自动 smoke

- CMD-002 最终退出码为 0：精确 Neovim 0.12.4 Release、四个实际 `stdpath()`、ShawnVim/lazy/blink 初始化、目标 checkout、Rust matcher、Notifications/messages 均通过主动断言。
- Rust matcher 首次检查失败是预编译库异步下载尚未完成；确认上游 `ensure_downloaded()` 生命周期后，验证命令改为最多等待 15 秒，随后 `implementation_type=rust`。
- 失败注入：主动 `assert(false, "injected failure")` 经 `cquit 7` 返回退出码 7，证明错误不会被 headless 零退出掩盖。
- Review-fix 后 Notifications predicate 统一先对 `tostring(n.msg):lower()` 匹配；CMD-002/CMD-005 正常路径均为 0，分别注入 `Blink Config Schema Import mixed-case fixture` WARN 后均以退出码 1 失败。
- 清洁度：预编译库仅写入 target blink checkout；无 Lua fallback；除 S4 已记录的 `<C-y>` fallback 外无其他兼容配置。

## S6 backend/source health

- CMD-004 通过：先显式加载 blink.cmp 后捕获特殊 checkhealth buffer；输出包含 `Your system is supported by pre-built binaries (x86_64-unknown-linux-gnu)` 与 `blink_cmp_fuzzy lib is downloaded/built`，无 backend error/Lua fallback/failed。
- Rust matcher：target checkout=`78336bc89ee5365633bcf754d93df01678b5c08f`，`implementation_type=rust`；预编译 `.so` 与 checksum 文件已写入 target data。
- Source fixture（`/tmp/shawnvim-blink-cmp-upgrade/source-smoke.lua`）：buffer=`BlinkUpgradeBufferFixture`、path=`shawnvim/`、snippets=`lf=`、LuaLS=`nvim_buf_*`、lazydev=`snacks` module 均取得候选；LuaLS 使用绝对路径 `/home/shawn/.local/share/nvim/mason/bin/lua-language-server`，client name=`lua_ls`。
- 诊断修正：LuaLS fixture 需有真实 `.lua` buffer 名称并等待 workspace 初始化；lazydev 需在 LuaLS attach 后验证 `require("sn")` module，而不是未附着 buffer 的 `vim.`。
- 清洁度：fixture 只位于 `/tmp`，未写入仓库；target XDG 承载所有插件运行数据。

## S7 交互回归

- 使用一次性 `/tmp/shawnvim-blink-cmp-upgrade/interaction-ui.py` + pynvim UI 客户端连接 `nvim --embed`，避免 headless 无法进入 Insert/cmdline。
- I1-I4/I7：真实 Insert UI 从公开 completion list 分别取得 buffer=`BlinkUpgradeBufferFixture`、path=`shawnvim/`、snippets=`lf=`、LSP=`nvim_buf_*`、lazydev=`snacks`，每项同时断言 `source_id + label`；`<C-y>` 接受 `lf=` snippet 并展开为 local/function 片段，LSP 候选接受为 `vim.api.nvim_buf_clear_namespace()`；`<Tab>` 将 snippet placeholder 从 `(1, 6)` 移到 `(1, 22)`。
- I5：无候选时只发送一次 `<C-y>`，精确得到原生 Ctrl-Y 结果 `zbz`；fixture 不再 unmap/retry。`<Tab>` 保留原生插入（实测 `zz  `）。为此对 `blink.lua` 做了最小修复：`<C-y>` 增加 `fallback`，不改变有候选时的接受语义。
- I6：`:` edit 候选左右键位置 `3→2→3`；`/` buffer 候选 `10→9→10`；`?` buffer 候选 `10→9→10`。三类命令行内容均未被左右键接受或改写。
- Evidence：完整 UI stdout 与 `interaction-ui-exit=0` 保存于 `/tmp/shawnvim-blink-cmp-upgrade/interaction-ui.out`；诊断与窄修复见 `upgrade-blink-cmp-review-fix.md`。
- 清洁度：UI client、虚拟 buffer 和 fixture 均为临时运行数据，未写入仓库或日常 XDG；曾设置的 buffer name 未执行写盘，仓库内没有 `blink_upgrade_fixture.lua`。

## S8 回退与交接

- Rollback config：`/tmp/shawnvim-blink-cmp-upgrade/rollback-config/nvim`；data/state/cache：`/tmp/shawnvim-blink-cmp-upgrade/rollback/{data,state,cache}`，与 target 完全隔离。
- 首次演练误用 `Lazy! sync` 更新了 disposable rollback lock；随后把 rollback lock 精确恢复到旧 commit，并使用 `Lazy! restore` 重建旧 checkout，未改写 target lock 或 checkout。
- Rollback manifest：rollback checkout=`485c03400608cb6534bbf84da8c1c471fc4808c0`、exact tag=`v0.14.2`，Neovim 0.12.4 下强制加载与 cold-start smoke 通过。
- Target invariant：target checkout 仍为 `78336bc89ee5365633bcf754d93df01678b5c08f`、exact tag=`v1.10.2`；apt `neovim` 仍为 removed。
- 交接状态：target 与 rollback XDG、tarball 及临时验证工具暂留供 code review/acceptance 复验；最终清理由 acceptance 执行并主动断言不存在。
- 清洁度：仓库中的一次性 UI fixture 已删除；`git status` 只保留 feature 文档、`lazy-lock.json` 与 `blink.lua` 的声明范围改动。
