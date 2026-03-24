## ADDED Requirements

### Requirement: Multi-media File Preview
The system MUST support high-performance previews of various file types, specifically including images (PNG, JPG, SVG) and potentially video/PDF, directly within the file manager interface.

#### Scenario: Image Preview
- **WHEN** the user navigates to an image file in the Yazi interface
- **THEN** the right-hand panel renders the image content natively

### Requirement: Neovim Buffer Integration
The system SHALL synchronize file selection in Yazi with the Neovim editor. Selecting a file in Yazi and pressing `Enter` MUST open that file in the current Neovim buffer or a new tab.

#### Scenario: Opening a File
- **WHEN** the user selects `main.lua` in Yazi and presses `Enter`
- **THEN** Yazi closes and `main.lua` is opened in a new Neovim buffer

### Requirement: Unified Floating UI
The file manager interface MUST be displayed as a centered floating window with rounded borders, consistent with the project's monochrome aesthetic.

#### Scenario: Invoking the File Manager
- **WHEN** the user presses `-`
- **THEN** a floating Yazi window appears with the current directory's content
