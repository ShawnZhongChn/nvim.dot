## Context

The current file management solution is `oil.nvim`, which is excellent for text-based batch operations but lacks native media support. `yazi` is a terminal file manager written in Rust that supports multiple graphics protocols (Kitty, iTerm2, Sixel, etc.) and offers asynchronous indexing. Integrating `yazi` into Neovim requires a bridge plugin to manage the floating window and file selection synchronization.

## Goals / Non-Goals

**Goals:**
- Replace `oil.nvim` with `yazi.nvim` as the primary file manager.
- Maintain existing keybindings (`-` and `<space>-`) for consistency.
- Ensure high-quality image and video previews within the Neovim UI.
- Preserve the minimalist monochrome aesthetic of the current configuration.

**Non-Goals:**
- Removing `oil.nvim` entirely (we will just rename the file to `.disabled` to keep it as a backup for batch renaming tasks).
- Automating the installation of the `yazi` binary (the user will handle the `brew` command).

## Decisions

### 1. Plugin Selection: `mikavilpas/yazi.nvim`
- **Rationale**: This is currently the most robust and feature-rich integration for `yazi` in Neovim. It supports multi-file selection, Git status integration, and handles the floating window lifecycle gracefully.
- **Alternatives**: `DreamMaoMao/yazi.nvim` (less maintained), using `floaterm` to manually call `yazi` (lacks deep integration).

### 2. Migration Strategy: Side-by-Side Coexistence
- **Decision**: Rename `lua/custom/plugins/oil.lua` to `lua/custom/plugins/oil.lua.disabled` instead of deleting it.
- **Rationale**: `oil.nvim`'s batch editing capability is unique; keeping it available (but disabled by default) allows for easy restoration if needed for specific refactoring tasks.

### 3. Visual Configuration
- **Decision**: Configure `yazi.nvim` to use a floating window with rounded borders to match the existing UI aesthetic.

### 4. Navigation Parity (H/L)
- **Rationale**: The user is accustomed to `oil.nvim`'s `H` (parent) and `L` (select/child) navigation.
- **Decision**: Use `set_keymappings_function` in the plugin configuration to map `H` to `h` and `L` to `l` in terminal mode within the Yazi buffer. This ensures the muscle memory from `oil.nvim` is preserved.

## Risks / Trade-offs

- **[Risk]** Terminal Protocol Mismatch.
  - **Mitigation**: The design assumes the user is using a modern terminal (iTerm2/Kitty/WezTerm). We will provide a standard configuration that works across these.
- **[Trade-off]** Performance of Floating Terminal.
  - **Mitigation**: Since `yazi` is Rust-based, the overhead is minimal, and the asynchronous nature ensures Neovim doesn't hang during indexing.
