## Why

When switching from Insert mode to Normal mode, all function folds are currently collapsing, which interrupts editing flow and makes cursor context harder to track. This change is needed so mode transitions do not unexpectedly alter folding state.

## What Changes

- Stop automatic fold collapsing during Insert → Normal mode transitions.
- Preserve each window’s existing fold open/closed state when Vim modes change.
- Keep existing explicit fold actions (`zc`, `zo`, `zM`, `zR`, etc.) unchanged.

## Capabilities

### New Capabilities
- `fold-state-preservation`: Maintain current fold visibility across mode transitions, especially Insert to Normal.

### Modified Capabilities
- None.

## Impact

- Affected code in Neovim configuration where mode-change autocmds/keymaps manipulate folds.
- No external API or dependency changes.
- Improves editing UX consistency for folded code navigation.
