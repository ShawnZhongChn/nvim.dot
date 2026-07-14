local bufnr = vim.api.nvim_get_current_buf()

require('custom.lang').setup_filetype(vim.bo.filetype, bufnr)
require('jdtls').start_or_attach(require('custom.lsp.server_settings.jdtls').make_config(bufnr))
