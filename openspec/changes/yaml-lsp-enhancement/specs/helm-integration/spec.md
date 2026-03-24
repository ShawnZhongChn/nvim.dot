## ADDED Requirements

### Requirement: Helm Template Recognition
The system SHALL correctly identify Helm template files and prevent standard YAML LSP errors.

#### Scenario: Open Helm Template
- **WHEN** opening a `.yaml` file within a Helm `templates/` directory containing `{{ ... }}` syntax
- **THEN** the system applies Helm-specific syntax highlighting and LSP logic

### Requirement: Helm Template Highlighting
The system SHALL provide accurate syntax highlighting for Helm template tags and standard YAML content.

#### Scenario: Highlight Helm Template Tag
- **WHEN** viewing a Helm template with `{{- if .Values.image.repository -}}`
- **THEN** the Helm-specific tags (e.g., `{{ ... }}`) are highlighted distinctly from YAML keys
