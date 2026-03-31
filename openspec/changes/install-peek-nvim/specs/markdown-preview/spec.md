## ADDED Requirements

### Requirement: Markdown preview with live update
The system SHALL provide a Markdown preview plugin that supports live update when markdown content changes.

#### Scenario: Auto load preview on markdown buffer
- **WHEN** user opens a markdown file and `auto_load = true`
- **THEN** the preview window SHALL automatically open

#### Scenario: Live update on change
- **WHEN** markdown content is modified
- **THEN** the preview SHALL update within the throttle_time interval

### Requirement: Synchronized scrolling
The system SHALL support synchronized scrolling between the markdown buffer and preview window.

#### Scenario: Scroll sync enabled
- **WHEN** preview is open
- **THEN** scrolling in the preview window reflects the corresponding position in the markdown buffer

### Requirement: GitHub-style rendering
The system SHALL render markdown with GitHub-style styling including code blocks with syntax highlighting.

### Requirement: KaTeX math support
The system SHALL render TeX math expressions using KaTeX.

### Requirement: Mermaid diagram support
The system SHALL render Mermaid diagrams in the preview.

### Requirement: Preview window navigation
The system SHALL provide keyboard navigation in the preview window.

#### Scenario: Navigate preview
- **WHEN** preview window is focused
- **THEN** keys `j`, `k`, `u`, `d`, `g`, `G` SHALL navigate the preview as described:
  - `j` scroll down
  - `k` scroll up
  - `u` scroll up half page
  - `d` scroll down half page
  - `g` scroll to top
  - `G` scroll to bottom

### Requirement: User commands
The system SHALL provide vim user commands to control the preview.

#### Scenario: Open preview command
- **WHEN** user executes `:PeekOpen`
- **THEN** the preview window SHALL open for the current markdown buffer

#### Scenario: Close preview command
- **WHEN** user executes `:PeekClose`
- **THEN** the preview window SHALL close

#### Scenario: Close on buffer delete
- **WHEN** `close_on_bdelete = true` and the markdown buffer is deleted
- **THEN** the preview window SHALL automatically close
