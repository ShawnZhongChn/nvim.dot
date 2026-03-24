## Why

Editing YAML files in Neovim, especially for complex structures like Kubernetes manifests or Helm charts, currently lacks robust schema validation, intelligent autocompletion, and reliable navigation. This change introduces a high-performance YAML LSP setup integrated with a comprehensive schema store and specialized Helm support to transform the YAML editing experience into a first-class development environment.

## What Changes

- **Enhanced YAML LSP**: Integrate `yaml-language-server` (yamlls) via Mason and `nvim-lspconfig`.
- **Intelligent Schema Validation**: Add `SchemaStore.nvim` to automatically provide validation and autocompletion for 1000+ YAML formats (Kubernetes, GitHub Actions, Docker Compose, etc.).
- **Specialized Helm Support**: Integrate `vim-helm` to handle Helm's non-standard template syntax correctly, preventing false LSP errors.
- **Improved Navigation**: Enable document symbols and "Go to Definition" for YAML anchors and aliases.
- **Enhanced Documentation**: Provide rich hover documentation for Kubernetes and Helm fields using the integrated schema store.

## Capabilities

### New Capabilities
- `yaml-navigation`: Robust navigation (Go to Definition, Document Symbols) for YAML files.
- `yaml-validation`: Automatic schema-based validation and autocompletion for a wide range of YAML formats.
- `helm-integration`: Proper syntax highlighting and LSP support for Helm templates.

### Modified Capabilities
- `lsp-core`: Update the core LSP setup to include specialized handling for YAML and Helm.

## Impact

- **Affected Code**: `lua/custom/lsp/servers.lua`, `lua/custom/plugins/lsp.lua`.
- **New Dependencies**: `yaml-language-server`, `b0o/SchemaStore.nvim`, `towolf/vim-helm`.
- **System**: Mason will automatically manage the installation of the new LSP server.
