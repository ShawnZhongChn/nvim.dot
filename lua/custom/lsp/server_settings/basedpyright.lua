-- @note: basedpyright server settings
-- @module custom.lsp.server_settings.basedpyright
return {
  settings = {
    basedpyright = {
      disableorganizeimports = true,
      analysis = {
        typecheckingmode = 'standard',
        autosearchpaths = true,
        autoimportcompletions = true,
        uselibrarycodefortypes = true,
        diagnosticmode = 'workspace',

        -- ── basedpyright 独有：按库名精确豁免，不污染自身代码 ──
        -- 补充了你代码中报错的几个关键无类型库
        alloweduntypedlibraries = {
          'boto3',
          'botocore',
          'requests',
          'celery',
          'redis',
          'elasticsearch',
          'motor',
          'opentelemetry',
          'passlib',
        },

        inlayhints = {
          callargumentnames = true,
          functionreturntypes = true,
          variabletypes = false,
          generictypes = false,
        },

        diagnosticseverityoverrides = {
          -- ── 外部无类型库噪音：静默 ──────────────────────────
          reportmissingtypestubs = 'none',
          reportmissingimports = 'none', -- 解决 reportMissingImports
          reportunknownmembertype = 'none',
          reportunknownvariabletype = 'none',
          reportunknownargumenttype = 'none',
          reportunknownparametertype = 'none',
          reportmissingmodulesource = 'none',
          reportany = 'none',
          reportignorecommentwithoutrule = 'none',
          reportunusedcallresult = 'none',

          -- ── 降级为警告（保留可见性，解决 SQLAlchemy 赋值等冲突）──
          reportgeneraltypeissues = 'warning',
          reportargumenttype = 'warning',
          reportassignmenttype = 'warning',
          reportattributeaccessissue = 'warning', -- 解决 token.access_token 赋值报错
          reportreturntype = 'warning', -- 解决 返回类型不匹配报错
          reportprivateimportusage = 'warning',

          -- 修正：basedpyright 中正确的 key 是 reportMissingTypeStubs，
          -- reportmissingstubpackages 可能会被标记为 unrecognized
        },
      },
    },
  },
}
