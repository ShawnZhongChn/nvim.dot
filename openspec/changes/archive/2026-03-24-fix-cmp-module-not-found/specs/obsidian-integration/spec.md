## MODIFIED Requirements

### Requirement: Update obsidian.nvim configuration
The system SHALL use the latest `obsidian.nvim` API and explicitly disable `nvim_cmp` to ensure compatibility with `blink.cmp`.

#### Scenario: Obsidian nvim_cmp configuration
- **WHEN** starting Neovim or opening a Markdown file
- **THEN** Obsidian SHALL NOT attempt to integrate with `nvim-cmp`.
