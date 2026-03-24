# Tasks: fix-lsp-and-obsidian-config

## 1. LSP Bug Fix

- [x] 1.1 Correct `rturn` typo to `return` in `lua/custom/lsp/server_settings/basedpyright.lua`.

## 2. Obsidian Plugin Migration

- [x] 2.1 Update `disable_frontmatter` to `frontmatter = { enabled = false }` in `lua/custom/plugins/obsidian.lua`.
- [x] 2.2 Update `note_frontmatter_func` to `frontmatter = { func = ... }` in `lua/custom/plugins/obsidian.lua`.
- [x] 2.3 Update `attachments.img_folder` to `attachments.folder` in `lua/custom/plugins/obsidian.lua`.
- [x] 2.4 Remove the deprecated `mappings = {}` table in `lua/custom/plugins/obsidian.lua`.
- [x] 2.5 Move `ui.checkboxes` configuration to the top-level `checkboxes` key in the options table in `lua/custom/plugins/obsidian.lua`.

## 3. Daily Notes Fix

- [x] 3.1 Create a simple `daily-template.md` file at `/Users/shawn/Documents/Study/MyNotes/4 - Templates/daily-template.md`.

## 4. Verification

- [x] 4.1 Restart Neovim and verify no configuration errors or deprecation warnings on startup.
- [x] 4.2 Verify that the `basedpyright` LSP starts successfully in a Python file.
- [x] 4.3 Verify that the `:ObsidianToday` command works and creates a daily note using the template.
- [x] 4.4 Run `:checkhealth obsidian` to ensure no remaining configuration issues.
