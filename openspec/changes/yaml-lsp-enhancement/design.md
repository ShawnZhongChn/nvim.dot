## Context

The current Neovim configuration lacks specialized support for YAML and Helm. While `nvim-lspconfig` is present, it isn't configured for `yaml-language-server` (yamlls), leading to a suboptimal editing experience for Kubernetes manifests and other complex YAML structures.

## Goals / Non-Goals

**Goals:**
- Integrate `yaml-language-server` (yamlls) with optimized settings.
- Enable automatic schema detection using `SchemaStore.nvim`.
- Provide seamless Helm template support via `vim-helm`.
- Follow the existing modular structure for LSP and plugin configuration.

**Non-Goals:**
- Custom YAML formatting logic (will rely on `yamlls` or existing formatters).
- Deep integration with external cloud providers (e.g., direct AWS/GCP validation).

## Decisions

- **Decision: Use `yaml-language-server` over alternatives**
  - **Rationale**: Industry standard, actively maintained by Red Hat, and has excellent Kubernetes/Helm support.
  - **Alternative**: `diagnostic-languageserver` (too generic, requires more manual setup).

- **Decision: Integrate `SchemaStore.nvim`**
  - **Rationale**: Provides access to a vast, community-maintained collection of YAML schemas without manual configuration.
  - **Alternative**: Manual schema mapping in `yamlls` settings (unmaintainable).

- **Decision: Add `vim-helm` as a dependency**
  - **Rationale**: Specifically designed to handle Helm's hybrid YAML/Go-template syntax, which standard YAML LSPs cannot parse correctly.
  - **Alternative**: Tree-sitter for Helm (less mature than `vim-helm` for standard buffer-wide operations).

## Risks / Trade-offs

- **[Risk]** `yamlls` can be resource-intensive on very large files.
  - **Mitigation**: Ensure standard LSP timeouts and potentially limit the number of schemas loaded simultaneously if performance issues arise.
- **[Risk]** `vim-helm` might conflict with other YAML plugins.
  - **Mitigation**: Use proper `ft` (filetype) detection to ensure `vim-helm` only activates for Helm-specific files.
