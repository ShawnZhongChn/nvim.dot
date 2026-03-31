## Why

Need a way to preview Markdown files with live update, synchronized scrolling, GitHub-style rendering, TeX math support via KaTeX, and Mermaid diagram support directly within Neovim.

## What Changes

- Add peek.nvim plugin for Markdown preview
- Add Deno runtime dependency
- Configure PeekOpen and PeekClose user commands
- Set up default keybindings for preview navigation

## Capabilities

### New Capabilities
- `markdown-preview`: Preview Markdown files with live update, synchronized scrolling, GitHub-style rendering, KaTeX math support, and Mermaid diagram support via peek.nvim

### Modified Capabilities
- (none)

## Impact

- Adds new plugin dependency: toppair/peek.nvim
- Requires Deno runtime to be installed
- Adds two user commands: PeekOpen, PeekClose
