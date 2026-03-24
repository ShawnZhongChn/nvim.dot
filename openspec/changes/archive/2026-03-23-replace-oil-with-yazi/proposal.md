## Why

`oil.nvim` is a text-based file manager that lacks native media preview capabilities (images, videos, etc.). The user requires a more performant and media-rich navigation experience. `yazi` (written in Rust) provides superior performance and native support for various terminal graphics protocols, making it an ideal replacement for media-heavy workflows while maintaining Vim-like efficiency.

## What Changes

- **Plugin Replacement**: Remove or disable `oil.nvim` and its associated configurations.
- **Integration**: Introduce `yazi.nvim` as the primary file management interface.
- **Keybinding Migration**: Remap existing `oil.nvim` triggers (e.g., `-` and `<space>-`) to invoke `yazi.nvim`.
- **System Dependencies**: Add `yazi` binary as a prerequisite.

## Capabilities

### New Capabilities
- `yazi-integration`: Comprehensive file navigation with native image/media preview support.

### Modified Capabilities
- None (No existing spec-level requirements are being modified, just replacing the tool).

## Impact

- **Configuration Files**: `lua/custom/plugins/oil.lua` (to be removed/disabled), new `lua/custom/plugins/yazi.lua`.
- **Keymaps**: Reassignment of global file navigation keys.
- **System**: Requires `yazi` and its dependencies (e.g., `ffmpeg`, `imagemagick`, `7zip`) to be installed via `brew`.
