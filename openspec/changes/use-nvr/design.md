## Context

Currently, the Lazygit floating window in Neovim doesn't properly communicate back to the host process when opening or editing files. This results in external editors (like PyCharm) being launched. The project already uses the `lazygit.nvim` plugin, which has built-in support for `neovim-remote` (nvr).

## Goals / Non-Goals

**Goals:**
- Ensure Lazygit uses the existing Neovim instance for editing.
- Redirect the `o` (Open) key to perform the same action as `e` (Edit) within Lazygit.
- Maintain a consistent monochrome aesthetic and minimal configuration.

**Non-Goals:**
- Automating the installation of `nvr` (assumed as a pre-requisite).
- Changing Lazygit's default keybindings beyond file opening.

## Decisions

### 1. Leverage `lazygit.nvim` Plugin Integration
- **Rationale**: The plugin already handles `$NVIM` socket detection and `nvr` invocation if `vim.g.lazygit_use_neovim_remote` is set to `1`.
- **Decision**: Keep the existing Lua configuration in `lua/custom/plugins/lazygit.lua`.

### 2. Configure Lazygit's `os` and `keybinding`
- **Rationale**: Lazygit needs to know it should use `nvim` as its editor preset. Mapping `o` to `e` ensures that both "Open" and "Edit" actions behave identically (opening in the current Neovim).
- **Decision**:
  - Set `os.editPreset: 'nvim'` in `config.yml`.
  - Set `keybinding.universal.openFile: 'e'` in `config.yml`.

## Risks / Trade-offs

- **[Risk]** `neovim-remote` not installed in the system.
  - **Mitigation**: The user must ensure `pip install neovim-remote` is executed. The configuration will fail gracefully by opening a new nvim instance if `nvr` is missing but `editPreset` is 'nvim'.
- **[Trade-off]** Overriding the default `o` (Open) behavior.
  - **Mitigation**: In the context of a terminal-based Git client inside Neovim, "Opening" a file almost always means "Editing" it in the current session.
