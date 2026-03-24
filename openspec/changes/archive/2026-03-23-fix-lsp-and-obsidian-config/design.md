# Design: fix-lsp-and-obsidian-config

## Context

The Neovim configuration is currently broken in two ways:
1. A typo (`rturn` for `return`) in the `basedpyright` LSP configuration.
2. An outdated `obsidian.nvim` configuration causing deprecation warnings and errors due to a missing template.

## Goals / Non-Goals

**Goals:**
- Fix the LSP syntax error to restore Python language server support.
- Clean up the `obsidian.nvim` configuration to resolve all deprecation warnings.
- Fix the `ObsidianToday` command by ensuring it points to a valid template.

**Non-Goals:**
- This is a maintenance and bug-fix task; no new features or plugins will be added.

## Decisions

- **Decision 1**: Correct the typo in `basedpyright.lua`.
  - **Rationale**: Simple syntax fix.
- **Decision 2**: Refactor `obsidian.nvim` options.
  - **Rationale**: The plugin's API has evolved. I will migrate the options to the newer structure as follows:
    - `disable_frontmatter` -> `frontmatter = { enabled = false }`
    - `note_frontmatter_func` -> `frontmatter = { func = ... }`
    - `attachments.img_folder` -> `attachments.folder`
    - Remove the unused `mappings = {}`.
    - Move `ui.checkboxes` to the top-level `checkboxes` option.
- **Decision 3**: Fix the missing template for daily notes.
  - **Rationale**: The configuration currently points to `daily-template.md`, which does not exist. I will change this to point to `new-note.md` (which exists) or create a simple `daily-template.md`. I'll create `daily-template.md` as a basic Markdown file to avoid breaking current workflows.

## Risks / Trade-offs

- **Risk**: Changing the `obsidian.nvim` configuration might break existing custom keymaps if they rely on deprecated settings.
- **Mitigation**: Verify the configuration with `:checkhealth obsidian` after implementation.
