## 1. Preparation

- [x] 1.1 Verify `yazi` binary is installed on the system (`yazi --version`).
- [x] 1.2 Rename `lua/custom/plugins/oil.lua` to `lua/custom/plugins/oil.lua.disabled`.

## 2. Implementation

- [x] 2.1 Create `lua/custom/plugins/yazi.lua` with the `mikavilpas/yazi.nvim` specification.
- [x] 2.2 Configure `yazi.nvim` to use floating window with rounded borders.
- [x] 2.3 Implement `H/L` navigation using `set_keymappings_function` (map `H` -> `h` and `L` -> `l`).
- [x] 2.4 Set up keybindings: `-` for `yazi.nvim` and `<space>-` for toggle.

## 3. Verification

- [ ] 3.1 Restart Neovim and verify the `yazi.nvim` plugin is loaded by Lazy.nvim.
- [ ] 3.2 Open Yazi with `-` and verify image previews are rendering correctly.
- [ ] 3.3 Verify selecting a file in Yazi opens it in the current Neovim buffer.
