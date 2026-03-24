## Context

The current Neovim configuration is in a transitional state between `nvim-cmp` and `blink.cmp`. While `blink.cmp` is configured, several other plugins and the core LSP setup still contain legacy references to `cmp` or `cmp-nvim-lsp`. This causes runtime errors because the `cmp` module is either not loaded or incorrectly referenced during startup (specifically during `InsertEnter`).

## Goals / Non-Goals

**Goals:**
- Eliminate all `module 'cmp' not found` and `module 'cmp_nvim_lsp' not found` errors.
- Standardize on `blink.cmp` for all completion-related tasks.
- Clean up the plugin list by removing redundant completion sources.

**Non-Goals:**
- Re-configuring `blink.cmp` settings (appearance, keymaps, etc.) unless necessary for basic functionality.
- Adding new completion sources.

## Decisions

### 1. LSP Capabilities Source
- **Decision**: Replace `require('cmp_nvim_lsp').default_capabilities()` with `require('blink.cmp').get_lsp_capabilities()` in `lua/custom/lsp/init.lua`.
- **Rationale**: `blink.cmp` provides its own capability injection which is optimized for its Rust-based fuzzy matcher.
- **Alternative**: Keeping both. Rejected as it leads to module loading conflicts and redundancy.

### 2. Obsidian.nvim Completion
- **Decision**: Set `completion.nvim_cmp = false` in `lua/custom/plugins/obsidian.lua`.
- **Rationale**: Obsidian's `nvim_cmp` option specifically looks for the `cmp` module. `blink.cmp` provides compatibility via `appearance.use_nvim_cmp_as_default = true`, but the plugin-specific flag should be disabled to prevent direct `require('cmp')` calls by Obsidian.

### 3. Noice.nvim Documentation Routing
- **Decision**: Remove the `['cmp.entry.get_documentation'] = true` entry from `lua/custom/plugins/noice.lua`.
- **Rationale**: This routing is specific to `nvim-cmp`'s internal structure and is not applicable to `blink.cmp`.

### 4. Dependency Cleanup
- **Decision**: Remove `hrsh7th/cmp-nvim-lsp` from the dependencies list in `lua/custom/plugins/lsp.lua`.
- **Rationale**: It is no longer needed and its presence might trigger `lazy.nvim` to attempt loading it, leading to the reported error.

## Risks / Trade-offs

- **[Risk]**: `blink.cmp` might not perfectly mimic `nvim-cmp` behavior in some edge cases. → **Mitigation**: Rely on `blink.cmp`'s built-in compatibility layer and verify functionality manually.
- **[Risk]**: Other plugins might still have hidden dependencies on `cmp`. → **Mitigation**: Perform a global grep and monitor logs after implementation.
