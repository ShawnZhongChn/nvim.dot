# Spec: lsp-core

## ADDED Requirements

### Requirement: Restore basedpyright LSP functionality
The system MUST correctly load the `basedpyright` language server without syntax errors in the configuration file.

#### Scenario: Successful LSP Initialization
- **WHEN** opening a Python file in Neovim
- **THEN** the `basedpyright` LSP should start successfully without configuration errors.
