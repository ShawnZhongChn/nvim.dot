## ADDED Requirements

### Requirement: Automatic Schema Recognition
The system SHALL automatically identify the YAML schema (e.g., Kubernetes, GitHub Actions, Docker Compose) based on the file content or filename.

#### Scenario: Kubernetes Manifest Recognition
- **WHEN** a YAML file with `apiVersion: apps/v1` is opened
- **THEN** the system applies the Kubernetes schema and provides relevant validation and autocompletion

### Requirement: Intelligent YAML Autocompletion
The system SHALL provide context-aware autocompletion for YAML keys and values based on the identified schema.

#### Scenario: Autocomplete Kubernetes Field
- **WHEN** typing in a `Deployment` manifest under `spec.template.spec`
- **THEN** the system suggests appropriate keys like `containers`, `volumes`, or `nodeSelector`

### Requirement: Rich Hover Documentation
The system SHALL display detailed documentation for YAML fields when the hover action is triggered.

#### Scenario: Hover Kubernetes Field
- **WHEN** the cursor is on `replicas` in a `Deployment` and `K` (Hover) is pressed
- **THEN** the system displays the official description of the `replicas` field from the schema
