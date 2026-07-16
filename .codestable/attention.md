# Attention

本文件是 CodeStable 技能启动必读的项目注意事项入口。所有 CodeStable 子技能开始工作前必须读取它。

## 报告语言

CodeStable 所有落盘产出的正文用**中文**：plan / design、plan review / design-review、code review、QA、验收、issue（report / analysis / fix-note）、refactor、roadmap、goal、沉淀（compound）等所有人读报告都用中文表达。机器状态（YAML / JSON / `state.yaml` / frontmatter 字段）保持机读格式不翻译。如需改默认语言，改这一节。

## 项目碎片知识

<!-- cs-note managed: 用 cs-note 维护，新条目按下面分节追加 -->

### 编译与构建

### 运行与本地起服务

### 测试

### 命令与脚本陷阱

### 路径与目录约定

### 环境变量与凭证

### 其他

- `docs/` 默认是 ShawnVim 继承功能的高权威说明与预期行为基线；CodeStable 只按当前主题读取相关页面，并在具体任务触及时按需修正本地命名或偏离，不做全量预读或预核验。冲突时以源码确认实际行为、以 `lazy-lock.json` 确认精确版本，并调查命名映射、已知偏离、移植遗漏或时效性。
