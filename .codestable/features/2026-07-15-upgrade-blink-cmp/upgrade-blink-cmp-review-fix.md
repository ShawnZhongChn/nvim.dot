# Round 1 review-fix 证据

## 修复范围

- REV-001：移除 `<C-y>` fixture 的 `iunmap`/retry 假阳性，只允许单次按键精确得到 `zbz`。
- REV-002：在 pynvim UI 客户端中通过公开 completion list 验证 buffer/path/snippets/LSP/lazydev 的 `source_id + label`，并接受一个 snippet 与一个 LSP 候选。
- REV-003：CMD-002/CMD-005 对 `tostring(n.msg):lower()` 做 blink/schema/import/config 匹配，并增加大小写混合 WARN 失败注入。
- REV-004：修正“无新增兼容配置”的证据文字。

## UI fixture 诊断

1. 首次复跑：buffer/path/snippet、单次 `<C-y>=zbz` 通过；LuaLS 在 attach 后只等待 2 秒，公开 LSP list 仍为空。
2. 第二次复跑：延长 workspace 初始化等待后公开 LSP list 取得 `source_id=lsp` 的 `nvim_buf_*` 候选；接受断言错误地用含参数签名的完整 label 匹配插入文本，因此失败。
3. 第三次复跑：LSP 候选接受为 `vim.api.nvim_buf_clear_namespace()`，证明真实接受链路通过；lazydev 的 attach 状态在异步 `LspAttach` 完成前被同步读取而失败。

上述失败均局限于一次性 `/tmp` UI fixture 的等待/断言，没有改变 production config、lock、source 顺序或目标版本。最终 fixture 对 lazydev attach 使用 8 秒有界等待；完整 stdout 与退出码保存在 `/tmp/shawnvim-blink-cmp-upgrade/interaction-ui.out`。

进一步只读检查确认 lazydev 的 `setup()` 会通过 `vim.schedule()` 延后创建 `LspAttach` autocmd。fixture 若在该 autocmd 注册前启动 LuaLS，会错过唯一 attach 事件；最终修复是在启动 LSP 前有界等待 `lazydev` group 的 `LspAttach` autocmd 已存在，而不是直接调用内部 `on_attach()` 绕过生产初始化。

最终根因不是事件丢失：`lazydev.buf.attached[buf]` 保存的是 buffer number，fixture 错误地用 `== true` 比较，导致真实附着也被判失败。最终检查改为非 `nil`，并移除了诊断期间尝试的 `LspAttach` 事件重放；最终通过证据完全走 production `LspAttach` autocmd。

## 最终验证

- UI：`interaction-ui-exit=0`；buffer/path/snippets/LSP/lazydev 均从公开 list 取得匹配的 `source_id + label`；snippet 与 LSP 候选真实接受；单次 `<C-y>` 精确为 `zbz`；`: / ?` 左右键保持原生移动。
- Notifications：CMD-002/CMD-005 正常运行均为 0；分别注入大小写混合 WARN 后均为非零退出码 1。
- Scope guard：production `blink.lua` 与 `lazy-lock.json` 未因 review-fix 再变化；只修改 design/checklist 验证文字、implementation/review-fix evidence 和 `/tmp` fixture。
