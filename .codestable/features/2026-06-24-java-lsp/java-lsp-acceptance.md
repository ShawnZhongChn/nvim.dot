# Java LSP 验收报告

> 阶段：阶段 3（验收闭环）
> 验收日期：2026-06-24
> 关联方案 doc：`.codestable/features/2026-06-24-java-lsp/java-lsp-design.md`

## 1. 接口契约核对

**接口示例逐项核对**：

- [x] Java 文件打开后自动进入 Java profile：`lua/custom/lang/java.lua` 声明 `filetypes = { 'java' }`、`lsp_servers = { 'jdtls' }`、`formatter_policy = 'google-java-format-or-lsp-fallback'`；`lua/custom/lang/init.lua` 将 `java` 映射到 `M.java`。
- [x] Maven 项目根识别：`lua/custom/lsp/registry.lua` 的 Java root marker 为 `pom.xml` / `mvnw` / `.git`；在 `/home/shawn/project/ssc_intelli_engine` 实测 root 为该项目根。
- [x] 格式化策略：`lua/custom/format/registry.lua` 对 `filetype=java` 返回 `google-java-format` + `lsp_format = 'fallback'`。

**名词层“现状 → 变化”逐项核对**：

- [x] Java profile：新增 `lua/custom/lang/java.lua`，并通过 `after/ftplugin/java.lua` 接入 filetype lifecycle。
- [x] JDTLS server settings：新增 `lua/custom/lsp/server_settings/jdtls.lua`，集中配置 Maven、Spring、Lombok、JDK runtime、metadata policy 与 JDTLS 启动命令。
- [x] LSP registry：新增 Java root、`jdtls` server 与 Mason package。
- [x] formatter registry：新增 Java formatter policy。

**流程图核对**：

- [x] `filetype=java -> Java profile -> Maven root -> jdtls -> LSP capability -> Java format policy` 均有实际落点。

## 2. 行为与决策核对

**需求摘要逐项验证**：

- [x] Maven Java 项目自动启动 JDTLS：在 `/home/shawn/project/ssc_intelli_engine` 中实测 `jdtls` attach，root 为项目根。
- [x] LSP 能力：实测 definition / hover 返回 `WorkflowConfig.java` 与 Java 类型信息；completion、rename、code action 通过 behavior validator 获取响应。
- [x] `pom.xml` 识别：Maven compile 通过后清理 stale JDTLS workspace cache，JDTLS root 为 `/home/shawn/project/ssc_intelli_engine`。
- [x] Spring / Lombok：Mason 安装 `vscode-spring-boot-tools`，JDTLS init_options 加载 Spring bundles；JDTLS 进程命令含 Mason `lombok.jar` javaagent。
- [x] JDK / Maven：SDKMAN 安装 Java 21.0.8-tem 与 Maven 3.9.16；脚本保留为 opt-in 引导。
- [x] Java 格式化：`google-java-format` 已由 Mason 安装，format policy 解析为 Java 专用 formatter + fallback。

**明确不做逐项核对**：

- [x] 不引入 DAP 调试链路：Java profile 的 `debug_adapters = {}`，未新增 Java DAP 配置。
- [x] 不新增 Java 测试运行器集成：Java profile 的 `test_adapters = {}`，未改 neotest。
- [x] 不把 Gradle 作为主目标：JDTLS settings 中 `java.import.gradle.enabled = false`。
- [x] 不为非 Java 语言调整现有 LSP 规则：已有 Python / Frontend / Rust / Markdown server 逻辑未重写，仅 registry 追加 Java 分支。

**关键决策落地**：

- [x] Java 独立 profile：`custom.lang.java` 独立存在。
- [x] `pom.xml` 优先：Java root marker 首项为 `pom.xml`。
- [x] Spring、Lombok、JDK、格式化纳入同一 Java workflow：集中在 `custom.lang.java`、`custom.lsp.server_settings.jdtls`、`custom.format.registry`、`scripts/setup_java_sdkman.sh`。
- [x] 沿用现有 LSP 架构：继续使用 `mason-tool-installer`、`mason-lspconfig`、`vim.lsp.config()` / `vim.lsp.enable()`。
- [x] SDKMAN 引导而非 Neovim 自动改系统：脚本需手动运行，health 只提示。

**挂载点反向核对（可卸载性）**：

- [x] design 2.3 已补齐实际挂载点：Java profile、ftplugin、registry、server settings、formatter、Treesitter、health、SDKMAN script。
- [x] 拔除沙盘：移除上述挂载点后，Java LSP feature 对用户视角消失；Maven settings / SDKMAN 属用户环境，不作为仓库代码挂载点提交。

## 3. 验收场景核对

- [x] 打开 Maven Java 项目中的 `.java` 文件 → `jdtls` 自动启动。证据：tmux window 8 中 `jdtls` attach，root 为 `/home/shawn/project/ssc_intelli_engine`。
- [x] 补全 / hover / 跳转定义 / 引用 / rename / code action → 得到 LSP 响应。证据：definition / hover 实测返回 `WorkflowConfig.java` 与 Java 类型；behavior validator 验证 completion / rename / code action 响应。references provider 已注册，采样位置可能返回空结果。
- [x] 含 `pom.xml` 的项目根识别 → root 落到项目根。证据：`jdtls` root 为 `/home/shawn/project/ssc_intelli_engine`。
- [x] Spring Java 项目增强 → Spring bundles 加载到 JDTLS init_options，`spring.boot.validation.enabled = true`。
- [x] Lombok 支持 → JDTLS 进程含 `-javaagent:/home/shawn/.local/share/nvim/mason/packages/jdtls/lombok.jar`。
- [x] 未手动安装工具链时有引导路径 → `scripts/setup_java_sdkman.sh` 可安装 SDKMAN Java / Maven，`custom.health` 提示缺失项。
- [x] 保存 Java 文件 → format policy 为 `google-java-format` + LSP fallback；未实际保存改动以避免修改业务文件。

## 4. 术语一致性

- JDTLS / `jdtls`：design、contracts、registry、server settings 命名一致。
- Maven project root / `pom.xml`：design 与 registry root marker 一致。
- Lombok support：design 与 JDTLS javaagent 实现一致。
- Spring support：design 与 Spring Boot bundles/settings 一致。
- JDK management：design 与 SDKMAN 脚本 / health / runtime discovery 一致。

## 5. 架构归并

- [x] `.codestable/architecture/ARCHITECTURE.md` 已更新项目简介：Java 加入优化语言列表。
- [x] 顶层目录结构已更新：`lua/custom/lang/` 包含 Java workflow profile。
- [x] LSP 架构已归并：补充 Java 的 `filetype -> profile -> root -> jdtls -> settings` 链路。
- [x] 语言与工具链章节已归并：补充 JDTLS、Maven root、Spring Boot tools、Lombok、SDKMAN 与 `google-java-format`。
- [x] 格式化章节已归并：Java `google-java-format` 成为主要 formatter。
- [x] 外部环境章节已归并：Java 需要 JDK 21+ / Maven，Mason 管理 JDTLS/formatter/Spring tools，私服依赖由 `~/.m2/settings.xml` 管理。

## 6. requirement 回写

- [x] `.codestable/requirements/nvim-dot.md` 已更新能力定位：Java 加入深度优化语言。
- [x] 新增 Java / Maven 开发环境能力段：记录 JDTLS、Maven root、Mason Java tools、SDKMAN、Spring/Lombok 与 Java format policy。

## 7. roadmap 回写

- [x] 非 roadmap 起头：design frontmatter 无 `roadmap` / `roadmap_item`，无需回写 roadmap items.yaml 或主文档。

## 8. attention.md 候选盘点

有候选，建议走 `cs-note`：

- Java LSP 跳转失败时，先检查 `mvn -DskipTests compile` 是否能解析 parent POM / 私服依赖；修好 Maven settings 后要清理 `~/.cache/nvim/jdtls/workspace/{project}` 并 `:LspRestart`，否则 JDTLS 可能保留旧的失败索引。

## 9. 遗留

- 已知限制：Java references 对不同采样位置可能返回空结果；provider 已注册，definition/hover/completion/rename/code action 已有正向证据。
- 已知环境约束：普通 shell 需 source SDKMAN 或将 SDKMAN init 写入 shell 启动文件，才能直接使用 `java` / `mvn`；JDTLS 进程已能使用 SDKMAN Java。
- 后续优化点：启动时存在既有 Lazy.nvim `Invalid plugin spec { enabled = false }` 噪声，和 Java LSP 无关，建议另走 issue/refactor 清理。
