--- @Note: TOML 文件 (Cargo.toml) 专属快捷键
--- @url: https://github.com/saecki/crates.nvim

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = 0, silent = true, desc = desc })
end

local crates = require('crates')
map('<leader>ct', crates.toggle,                      'Crates: Toggle')
map('<leader>cr', crates.reload,                      'Crates: Reload')
map('<leader>cv', crates.show_versions_popup,         'Crates: Show Versions')
map('<leader>cf', crates.show_features_popup,         'Crates: Show Features')
map('<leader>cu', crates.update_crate,               'Crates: Update')
map('<leader>cU', crates.upgrade_crate,               'Crates: Upgrade')
map('<leader>cd', crates.show_dependencies_popup,    'Crates: Dependencies')
