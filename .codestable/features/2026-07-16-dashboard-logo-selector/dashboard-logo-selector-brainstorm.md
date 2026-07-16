---
doc_type: feature-brainstorm
feature: 2026-07-16-dashboard-logo-selector
status: confirmed
summary: 在现有 UI 分组中提供可预览、可持久化的 Dashboard 成品 Logo 选择器
tags: [dashboard, logo, ui, picker]
---

# Dashboard Logo 选择器 Brainstorm

> Stage 0 | 2026-07-16 | 下一步：design

## 想做什么、为什么

当前 Dashboard 顶部使用带有右侧 `zzz` 装饰的 LazyVim 风格 ASCII Header。目标是把它替换为围绕 “Shaw N vim” 定制的艺术字，同时保留右侧小装饰所带来的辨识度。

最初考虑通过配置项分别选择文案、字符集与视觉风格。结合现有 `<leader>u` UI 分组以及 `<leader>uC` Colorscheme 选择体验后，最终决定提供一个类似 Colorscheme picker 的 Logo 选择入口，让用户直接预览并选择完整成品，而不是编辑配置字段或逐层组合选项。

## 考虑过的方向

### 方向 A：三个独立 Lua 配置项

- 分别配置文案、字符集和视觉风格，可形成完整笛卡尔积。
- 价值是组合自由；代价是缺少直观预览，并容易产生视觉质量较低的机械组合。
- 结论：否决。交互不如现有 UI picker 直观。

### 方向 B：在 Dashboard 内新增切换按钮

- 直接在启动页按钮区域加入 Logo 切换入口。
- 价值是入口显眼；代价是会改动现有 Dashboard 按钮、快捷键或布局。
- 结论：否决。违反本功能的明确范围边界。

### 方向 C：在 `<leader>u` 下提供成品 Logo picker

- 一次选择一个经过设计的完整 Header，并在候选间预览最终效果。
- 价值是符合现有 UI 操作心智、控制候选质量，也不侵入 Dashboard 按钮区域。
- 结论：选定。

## 已敲定的设计点

- **已确认：** 入口属于现有 `<leader>u` UI 分组，交互类比 `<leader>uC` Colorscheme picker；具体未占用键位由 design 核定，不能覆盖现有 `<leader>uL` Relative Number。
- **已确认（2026-07-16 收敛更新）：** 用户查看首轮画面后否决极客终端和安静极简，不再保留 6 款/三风格范围；首版只提供 2 个霓虹成品。
- **已确认（2026-07-16 收敛更新）：** 两款分别为 `Shaw N vim` + Unicode `✦`，以及 `SHAW N VIM` + Nerd Font Neovim glyph ``（U+E6AE）；准确六行画面以 design 第 1.3 节为准。
- **已确认：** 右侧装饰属于完整 Logo 成品的一部分，不作为独立字段选择。
- **已确认：** picker 展示完整 Header 预览，确认后立即应用并跨 Neovim 启动持久化。
- **已确认：** 多种 Dashboard 实现应从共享 Logo registry/provider 获取当前成品，避免在各插件配置中复制选择逻辑和 Header 字符串。
- **已确认：** 当前 `zzz` 是 Header 字面量的一部分，并非插件自动效果；替换无需模拟插件行为。
- **已确认：** 不新增 Dashboard 内按钮，不改变现有 Dashboard 按钮、快捷键、顺序或布局。
- **倾向：** 使用现有 `shawnvim.json` 状态机制保存选择，而不是修改用户 Lua 源文件或借用会话持久化插件。
- **已确认（design 收敛）：** Logo selector 固定使用核心 Snacks picker 的 static items + preview pane，不适配 Telescope/Fzf；各 Dashboard 的即时刷新由 starter adapter 分别处理。

## 选定方向与遗留问题

实现一个共享的 Dashboard Logo registry/provider，内置 2 个已确认霓虹成品。用户从 `<leader>u` 下打开 Logo picker，预览并选择一个成品；确认后当前 Dashboard Header 更新，后续启动继续沿用该选择。

功能只改变 Dashboard 顶部 Header，并新增一个全局 UI 选择入口；不会修改 Dashboard 的按钮区、按键、顺序和整体布局。准确画面、`<leader>uo`、Snacks picker、各 starter 刷新契约、原子持久化与验证策略由后续 design 定稿。
