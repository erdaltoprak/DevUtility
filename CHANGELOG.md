# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),  
and this project aims to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0]

### Added
- New `InputPanel` component with clear visual distinction for editable text (white background with accent border, pencil icon).
- New `OutputSection` component that expands naturally with content instead of using fixed-height scrollable boxes.
- Visual feedback animation on copy action (shows "Copied!" with checkmark for 1.5 seconds).
- Page-level scrolling for all tool views, allowing content to grow vertically without hidden scroll areas.

### Changed
- **ToolHeaderView**: Removed actions parameter to prevent title wrapping; copy buttons now consistently placed in output panel headers only.
- **Output panels**: Changed from constrained scrollable boxes to expandable sections with gray background (`Color.gray.opacity(0.1)`).
- **UnixTimestampConverterView**: Updated to use new `InputPanel` and `OutputSection` components with page-level scrolling.
- **Base64EncoderDecoderView**: Updated to use new `InputPanel` and `OutputSection` components with page-level scrolling.
- **LoremIpsumGeneratorView**: Updated to use new `OutputSection` component with page-level scrolling.
- **TextDiffCheckerView**: Updated to use new `InputPanel` component and expandable diff output.
- **Button styling**: Changed from plain text buttons to bordered button style with icons for better visual hierarchy.
- **Mode pickers**: Added contextual icons (gear for timestamp modes, arrows for encode/decode) and constrained width for better visual grouping.
- **Error messages**: Added warning icon and improved alignment with input panels.

### Removed
- `EditorPanel.swift` - Replaced by `InputPanel.swift` with improved visual design.
- `OutputPanel.swift` - Replaced by `OutputSection.swift` with expandable content behavior.
- Copy buttons from main tool headers (now consistently placed in output sections only).

## [1.0.0]

### Added
- Initial project documentation: `README.md`, `CONTRIBUTING.md`, `Docs/ARCHITECTURE.md`.
- Project planning document in `.ai/PROJECT_PLAN.md` describing each planned tool.
- Initial cross‑platform app shell and navigation for iOS and macOS, including tool list, macOS sidebar layout, and placeholder detail views for all planned tools.
 - Shared theming and reusable tool UI components, including `AppTheme` and common header/editor/output panels. These panels act as baseline building blocks for text‑oriented tools, while individual tools are free to specialize their interfaces or introduce additional shared patterns where a different layout fits better.
 - Settings infrastructure, including `SettingsStore`, `ClipboardService`, and recent tool usage tracking wired into the app shell.
 - Unix Timestamp Converter tool, including automatic detection of seconds/milliseconds/ISO‑8601 input and rich human‑readable output (local time, relative description, calendar details).
 - Base64 Encoder/Decoder tool, supporting encoding plain text to Base64 and decoding Base64 strings back to UTF‑8 text, with clipboard integration.
 - Lorem Ipsum Generator tool, allowing generation of one to ten paragraphs of classic lorem ipsum text with an optional “Lorem ipsum dolor sit amet” opening and clipboard copy support.
 - Text Diff Checker tool, providing side‑by‑side comparison of two texts with line‑based highlighting for additions/removals and a unified diff output that can be copied to the clipboard.
 - Cross‑platform Settings view for iOS and macOS, exposing external links (GitHub, website, X profile) from a dedicated screen (toolbar button on iOS, standard Settings window on macOS).

### Changed
- Limited the visible tool list in the UI to the current POC scope (Unix Timestamp Converter, Base64 Encoder/Decoder, Lorem Ipsum Generator, Text Diff Checker), with all other planned tools kept as optional entries in the internal tool registry and TODO.md.
