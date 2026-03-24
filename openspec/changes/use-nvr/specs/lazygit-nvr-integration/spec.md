## ADDED Requirements

### Requirement: Lazygit Editor Configuration
The Lazygit application MUST be configured to use `nvim` as its preferred editor preset to ensure compatibility with Neovim-specific remote features.

#### Scenario: Verify Editor Preset
- **WHEN** the user opens Lazygit configuration
- **THEN** the `os.editPreset` field is set to `'nvim'`

### Requirement: File Opening Redirection
Lazygit MUST redirect the `o` (Open) keybinding to the same internal action as the `e` (Edit) keybinding. This ensures that any "open" request is handled by the configured editor (Neovim) rather than a system-level default opener.

#### Scenario: Pressing Open Key
- **WHEN** the user selects a file in Lazygit and presses `o`
- **THEN** Lazygit triggers the editor (Neovim) instead of the system's `open` command

### Requirement: Remote Communication via NVR
The system SHALL utilize `neovim-remote` (nvr) to open files in the active host Neovim instance when triggered from the Lazygit floating window.

#### Scenario: Successful Remote Opening
- **WHEN** the user edits a file from Lazygit (via `e` or `o`)
- **THEN** the file is opened as a new buffer in the current Neovim session without starting a new Neovim process
