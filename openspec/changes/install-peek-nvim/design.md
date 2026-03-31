## Context

Installing peek.nvim Markdown preview plugin for Neovim. This is a plugin that requires Deno runtime and provides live Markdown preview with GitHub-style rendering, KaTeX math, and Mermaid diagrams.

## Goals / Non-Goals

**Goals:**
- Add peek.nvim plugin with lazy.nvim
- Configure PeekOpen and PeekClose commands
- Set up default configuration for auto_load and dark theme

**Non-Goals:**
- Custom keybinding setup (using default vim keybindings)
- Browser-only preview mode configuration

## Decisions

1. **Use webview app (default)** - Provides best integration with Neovim
2. **auto_load = true** - Automatically load preview when entering markdown buffer
3. **Theme = dark** - Matches typical Neovim dark theme setup
4. **Build command in lazy.nvim spec** - `deno task --quiet build:fast` runs on plugin install/update

## Risks / Trade-offs

- **Risk**: Deno not installed
  - **Mitigation**: User must install Deno separately; plugin will show error if missing
- **Risk**: Webview not available on all systems
  - **Mitigation**: Can switch to browser mode via `app = 'browser'` configuration
