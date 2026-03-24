## MODIFIED Requirements

### Requirement: Restore basedpyright LSP functionality
The system MUST correctly load the `basedpyright` language server without syntax errors in the configuration file, using `blink.cmp` for LSP capabilities.

#### Scenario: Successful LSP Initialization
- **WHEN** opening a Python file in Neovim
- **THEN** the `basedpyright` LSP should start successfully using `blink.cmp` capabilities.

## ADDED Requirements

### Requirement: Use blink.cmp for default capabilities
The system SHALL use `require('blink.cmp').get_lsp_capabilities()` to generate LSP capabilities instead of `require('cmp_nvim_lsp').default_capabilities()`.

#### Scenario: LSP Capabilties Injection
- **WHEN** initializing an LSP server
- **THEN** the system SHALL successfully inject `blink.cmp` capabilities without `module 'cmp_nvim_lsp' not found` errors.
