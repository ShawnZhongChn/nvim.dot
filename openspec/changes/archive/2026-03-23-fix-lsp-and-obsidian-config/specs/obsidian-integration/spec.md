# Spec: obsidian-integration

## ADDED Requirements

### Requirement: Update obsidian.nvim configuration
The system MUST use the latest `obsidian.nvim` API to avoid deprecation warnings.

#### Scenario: No deprecation warnings on startup
- **WHEN** starting Neovim or opening a Markdown file
- **THEN** no `notify.warn` messages about deprecated Obsidian options should be shown.

### Requirement: Ensure daily notes template is available
The system MUST provide a valid template for the `ObsidianToday` command.

#### Scenario: Successful Daily Note Creation
- **WHEN** executing the `:ObsidianToday` command
- **THEN** a new daily note should be created using the `daily-template.md` file without error.
