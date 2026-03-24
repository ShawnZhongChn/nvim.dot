## Why

Currently, opening files from the Lazygit floating window (inside Neovim) defaults to system-level openers (like PyCharm) or starts a new Neovim instance. This disrupts the development workflow. Integrating `nvr` (neovim-remote) allows Lazygit to communicate with the active Neovim session, opening files directly in the current editor instance.

## What Changes

- **Lazygit Configuration**: Update Lazygit's `config.yml` to use `nvr` for `edit` and `openFile` commands.
- **Plugin Integration**: Verify and reinforce the `lazygit.nvim` plugin configuration to ensure it correctly handles the `nvr` bridge.
- **Workflow Optimization**: Ensure that pressing `e` or `o` in Lazygit opens the file as a new buffer/tab in the existing Neovim process.

## Capabilities

### New Capabilities
- `lazygit-nvr-integration`: Establishes the communication bridge between Lazygit and the host Neovim instance via `nvr`.

### Modified Capabilities
- `lsp-core`: Ensure that files opened via `nvr` correctly trigger LSP attachment and diagnostic loading (existing capability verification).

## Impact

- **Configuration Files**: `~/Library/Application Support/lazygit/config.yml` (or the detected active config path).
- **Plugins**: `lua/custom/plugins/lazygit.lua`.
- **System Dependencies**: Requires `neovim-remote` (nvr) to be installed in the user's PATH.
