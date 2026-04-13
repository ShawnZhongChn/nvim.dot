-- @note: basedpyright server settings
-- @module custom.lsp.server_settings.basedpyright
return {
  settings = {
    basedpyright = {
      disableorganizeimports = true,
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",

        -- ── basedpyright 独有：按库名精确豁免，不污染自身代码 ──
        allowedUntypedLibraries = {
          "boto3",
          "botocore",
          "requests",
          "celery",
          "redis",
          "elasticsearch",
          "motor",
          "opentelemetry",
          "passlib",
        },

        inlayHints = {
          callArgumentNames = true,
          functionReturnTypes = true,
          variableTypes = false,
          genericTypes = false,
        },

        diagnosticSeverityOverrides = {
          -- ── 核心：关闭所有"类型不完整"的噪音 ──────────────────────────────
          -- PyCharm 不要求你给每个函数/变量写类型注解
          ["reportMissingParameterType"] = "none",
          ["reportMissingTypeArgument"] = "none",
          ["reportUnknownVariableType"] = "none",
          ["reportUnknownMemberType"] = "none",
          ["reportUnknownParameterType"] = "none",
          ["reportUnknownArgumentType"] = "none",
          ["reportUnknownLambdaType"] = "none",

          -- ── basedpyright 独有的激进规则，全部静音 ─────────────────────────
          -- reportAny 是 basedpyright 加的，pyright 原版没有，极其吵闹
          ["reportAny"] = "none",
          ["reportExplicitAny"] = "none",
          ["reportImplicitOverride"] = "none",
          ["reportIgnoreCommentWithoutRule"] = "none",

          -- ── 装饰器 / 基类 / NamedTuple 宽容处理 ───────────────────────────
          ["reportUntypedFunctionDecorator"] = "none",
          ["reportUntypedClassDecorator"] = "none",
          ["reportUntypedBaseClass"] = "none",
          ["reportUntypedNamedTuple"] = "none",

          -- ── 第三方库无类型桩文件：PyCharm 从不为此报错 ────────────────────
          ["reportMissingTypeStubs"] = "none",
          ["reportMissingModuleSource"] = "none",

          -- ── 私有成员：PyCharm 只是弱提示，不阻断你 ────────────────────────
          ["reportPrivateUsage"] = "warning",
          ["reportPrivateImportUsage"] = "warning",

          -- ── 代码风格类：降级为提示，不影响编码流 ─────────────────────────
          ["reportUnusedImport"] = "warning",
          ["reportUnusedVariable"] = "warning",
          ["reportImplicitStringConcatenation"] = "none",

          -- ── 保留真正有价值的检查（PyCharm 也会抓的） ─────────────────────
          -- 未定义的变量/名称 → 必须保留
          ["reportUndefinedVariable"] = "error",
          -- 模块找不到 → 必须保留
          ["reportMissingImports"] = "error",
          -- 明显的属性不存在 → 保留但可改 warning
          ["reportAttributeAccessIssue"] = "warning",
          -- 函数调用参数数量/类型明显错误
          ["reportCallIssue"] = "warning",
          -- 返回类型 → PyCharm 只在明显矛盾时报错
          ["reportReturnType"] = "warning",
          -- 操作符类型错误（比如字符串 - 数字）
          ["reportOperatorIssue"] = "warning",
          -- 索引类型问题
          ["reportIndexIssue"] = "warning",
        },
      },
    },
  },
}
