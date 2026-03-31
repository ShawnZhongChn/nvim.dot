## ADDED Requirements

### Requirement: Preserve fold state across mode transitions
The editor configuration MUST NOT change fold open/closed state solely because of a Vim mode transition, including Insert to Normal.

#### Scenario: Insert to Normal does not collapse folds
- **WHEN** the user leaves Insert mode and enters Normal mode
- **THEN** previously open folds remain open
- **AND** previously closed folds remain closed

### Requirement: Explicit fold commands remain authoritative
The editor configuration MUST continue to apply fold state changes only when the user executes explicit fold commands or other non-mode-transition fold actions.

#### Scenario: Manual fold close still works
- **WHEN** the user executes an explicit fold close action (for example `zc` or `zM`)
- **THEN** folds close according to normal Vim semantics
- **AND** subsequent mode transitions do not override that resulting fold state
