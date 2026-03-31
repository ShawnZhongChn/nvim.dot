## 1. Locate and remove mode-transition fold trigger

- [x] 1.1 Find InsertLeave/ModeChanged autocmds or keymaps that call fold-closing actions in the Neovim config
- [x] 1.2 Remove or guard the fold-closing behavior so mode transitions alone do not change fold state

## 2. Validate preserved folding behavior

- [ ] 2.1 Verify explicit fold commands (`zc`, `zo`, `zM`, `zR`) still work as expected
- [ ] 2.2 Verify Insert → Normal transitions preserve existing open/closed folds in typical folded code buffers
