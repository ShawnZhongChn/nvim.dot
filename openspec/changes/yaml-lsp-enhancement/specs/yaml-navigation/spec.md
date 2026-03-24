## ADDED Requirements

### Requirement: YAML Anchor and Alias Navigation
The system SHALL support jumping to the definition of a YAML anchor from its corresponding alias.

#### Scenario: Jump to Anchor
- **WHEN** the cursor is on a YAML alias (e.g., `*default_config`) and `gd` (Go to Definition) is triggered
- **THEN** the cursor moves to the corresponding anchor definition (e.g., `&default_config`)

### Requirement: YAML Document Symbols
The system SHALL provide a list of document symbols for the current YAML file, including all keys and nested structures.

#### Scenario: List YAML Symbols
- **WHEN** the user opens the document symbols list (e.g., via `Telescope lsp_document_symbols`)
- **THEN** the system displays a hierarchical list of all keys in the YAML file for quick navigation
