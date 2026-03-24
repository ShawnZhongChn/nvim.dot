--- @Note: YAML Language Server (yamlls) 配置
--- 集成 SchemaStore 以获得最佳的 K8s/Helm 补全体验
--- @module custom.lsp.server_settings.yamlls

return {
  settings = {
    yaml = {
      schemaStore = {
        -- 禁用内置 schema store，转而使用 SchemaStore.nvim
        enable = false,
        -- 避免 schema 冲突
        url = '',
      },
      schemas = vim.tbl_deep_extend('force', require('schemastore').yaml.schemas(), {
        kubernetes = { '/*.yaml', '/*.yml' },
        -- 你可以在这里手动指定特定项目的 Schema
      }),
      -- 默认开启 validation
      validate = true,
      -- 允许在 yaml 中使用跳转到锚点
      completion = true,
      hover = true,
    },
  },
}
