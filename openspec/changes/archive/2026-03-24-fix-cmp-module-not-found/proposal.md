## Why

The Neovim configuration is experiencing a module loading error: `module 'cmp' not found`. This occurs because several components (lsp-core, obsidian-integration, noice) are still referencing or attempting to use `nvim-cmp` and its ecosystem (like `cmp-nvim-lsp`), even though the project has migrated to `blink.cmp` as the primary completion engine.

## What Changes

- **lsp-core**: Replace `cmp-nvim-lsp` dependency and `require('cmp_nvim_lsp')` with `blink.cmp` capabilities in the LSP initialization.
- **obsidian-integration**: Disable `nvim_cmp` integration in `obsidian.nvim` configuration.
- **noice.nvim**: Remove or update `cmp` related documentation routing.
- **Cleanup**: Remove `hrsh7th/cmp-nvim-lsp` from the plugin list and ensure `nvim-cmp` and its related sources are no longer being loaded by `lazy.nvim`.

## Capabilities

### New Capabilities
- `blink-cmp-integration`: Ensuring all LSP and plugin integrations use `blink.cmp` exclusively, resolving conflicts with legacy `cmp` modules.

### Modified Capabilities
- `lsp-core`: Update LSP capability injection to use `blink.cmp` instead of `cmp-nvim-lsp`.
- `obsidian-integration`: Update completion settings to reflect the move away from `nvim-cmp`.

## Impact

- **LSP**: LSP servers will now correctly report capabilities via `blink.cmp`.
- **UI**: Noice documentation and Obsidian completion will no longer attempt to load the missing `cmp` module.
- **Stability**: Resolves the `InsertEnter` autocommand error and ensures a clean, single-completion-engine environment.
