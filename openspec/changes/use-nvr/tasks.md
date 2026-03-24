## 1. Environment Verification

- [x] 1.1 Verify `nvr` (neovim-remote) is installed and accessible in the system path.
- [x] 1.2 Confirm `lua/custom/plugins/lazygit.lua` contains `vim.g.lazygit_use_neovim_remote = 1`.

## 2. Lazygit Configuration

- [x] 2.1 Locate the active Lazygit `config.yml` (typically at `~/Library/Application Support/lazygit/config.yml`).
- [x] 2.2 Ensure the `os` section is present and set `editPreset` to `'nvim'`.
- [x] 2.3 Ensure the `keybinding.universal` section is present and map `openFile` to `'e'`.

## 3. Functional Verification

- [ ] 3.1 Open Neovim and launch Lazygit via the `<leader>lg` command.
- [ ] 3.2 Verify that pressing `e` on a file opens it in the current Neovim buffer (not a new terminal or PyCharm).
- [ ] 3.3 Verify that pressing `o` on a file also opens it in the current Neovim buffer (redirected to `e`).
