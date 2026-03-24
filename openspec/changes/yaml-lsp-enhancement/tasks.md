## 1. Plugin and LSP Installation

- [x] 1.1 Add `b0o/SchemaStore.nvim` and `towolf/vim-helm` as dependencies in `lua/custom/plugins/lsp.lua`.
- [x] 1.2 Add `yamlls` to the `servers` list in `lua/custom/lsp/servers.lua`.
- [x] 1.3 Ensure `yaml-language-server` is included in the Mason installation list.

## 2. YAML LSP Configuration

- [x] 2.1 Create a new configuration file `lua/custom/lsp/server_settings/yamlls.lua`.
- [x] 2.2 Configure `yamlls` in `yamlls.lua` to integrate with `SchemaStore.nvim` for automatic schema detection.
- [x] 2.3 Set specific LSP settings for Kubernetes and other standard YAML formats.

## 3. Helm Support Integration

- [x] 3.1 Verify `vim-helm` correctly identifies Helm files and provides appropriate syntax highlighting.
- [x] 3.2 Ensure the core LSP setup handles Helm files gracefully without conflicting with standard YAML LSP settings.

## 4. Verification and Validation

- [x] 4.1 Verify `gd` (Go to Definition) works for YAML anchors and aliases.
- [x] 4.2 Confirm that Kubernetes manifests trigger correct validation and autocompletion.
- [x] 4.3 Test hover documentation (`K`) on standard Kubernetes/Helm fields.
- [x] 4.4 Ensure no regressions in existing LSP functionality for Lua or Python.
