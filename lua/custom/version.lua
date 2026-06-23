--- @module custom.version
--- Version and update governance policy.

local M = {}

function M.policy()
  return {
    neovim_target = '>=0.10.0; prefer 0.12.x stable when available',
    lockfile = 'lazy-lock.json is local state in this repo because .gitignore ignores it',
    mason_tools = 'Installed from custom.lsp.registry.ensure_installed()',
    auto_install_tools = require('custom.config').is_enabled('auto_install_tools'),
    auto_update_tools = require('custom.config').get_value({ 'features', 'auto_update_tools' }, true),
    treesitter_auto_install = true,
    fast_moving_plugins = {
      ['blink.cmp'] = 'currently v0.* in plugin spec; roadmap recommends revisiting stable 1.* when upgrading',
      ['rustaceanvim'] = '^7',
      ['obsidian.nvim'] = '* retained from prior config; should be pinned during dedicated version governance review',
    },
  }
end

return M
