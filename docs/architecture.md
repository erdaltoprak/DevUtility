# DevUtility Architecture

This document provides a high‑level overview of how DevUtility is structured so that each tool can be implemented independently while sharing a consistent foundation.

The overall goals are:

- A single SwiftUI codebase for iOS and macOS.
- Simple, explicit data flow using SwiftUI's native patterns.
- Small, testable units of logic for each tool.
- Minimal external dependencies.

---

## High‑Level Design

DevUtility is a collection of independent tools (JSON Formatter, JWT Debugger, QR Generator, etc.) all hosted within a shared app shell.

At a high level:

- **App shell**  
  - A root SwiftUI scene for iOS and macOS presents the main "Tools" home screen.
  - Users select a tool from a list/grid, which navigates to that tool's dedicated view.

- **Per‑tool isolation**  
  - Each tool lives in its own folder under `Tools/<ToolName>/`.
  - Each tool exposes:
    - A primary SwiftUI view (e.g. `JsonFormatterView`).
    - Tool‑specific logic implemented as pure Swift types or small services.

- **Shared components and services**  
  - Common UI components (e.g. text editors, output panels, headers) are located in `SharedUI/`.
  - Shared services (e.g. clipboard, hashing, formatting) and models live in `Core/`.

The application intentionally avoids classic MVVM view models. Instead, it leans on SwiftUI data flow patterns and environment‑injected services.

---

## Data Flow & State Management

DevUtility follows the conventions defined in `.ai/swift.rules.md` and `.ai/swift-mvvm.rules.md`:

- **Views as state representations**
  - SwiftUI views are lightweight structs that declare UI based on their state.
  - Views own local interaction state using `@State` and `@Binding`.

- **Shared state with `@Observable`**
  - Shared or cross‑tool state (e.g. settings, favorites, recent tools) lives in `@Observable` classes marked `@MainActor`.
  - These observable models are injected into the view hierarchy using `environment(_:)`.

- **Environment‑injected services**
  - Services such as clipboard access, QR code generation, hashing, or formatting helpers are defined as types (usually structs or classes) and provided through the SwiftUI environment.
  - Views access them via `@Environment(ServiceType.self) var service`.

- **No traditional MVVM view models**
  - There are no `ObservableObject` view models for each view.
  - Instead, views coordinate directly with environment services and small, focused observable models where necessary.

This design keeps the mental model close to modern SwiftUI patterns and avoids boilerplate associated with classic MVVM.

---

## Project Structure

The project is organized into a few conceptual layers:

- `App/`
  - Entry point (`DevUtilityApp`), scenes, and root navigation structures (e.g. `NavigationStack`).
  - App‑wide environment configuration (injection of shared models and services).

- `Tools/`
  - Each subfolder represents one tool, for example:
    - `Tools/UnixTimestampConverter/`
    - `Tools/JsonFormatter/`
    - `Tools/JwtDebugger/`
    - ...
  - Each tool provides:
    - A main SwiftUI view for the tool screen.
    - Helpers for parsing, formatting, encoding/decoding, etc.

- `SharedUI/`
  - Reusable SwiftUI components shared between tools:
    - Input/output text panels.
    - Tool headers (title, description, action buttons).
    - Shared layout primitives for split views and panels.

- `Core/`
  - Shared models, services, and utilities:
    - Settings store (`SettingsStore`).
    - Clipboard service (`ClipboardService`).
    - Formatting/parsing utilities used across multiple tools.

- `Docs/`
  - Architecture and design documentation (this file and any future docs).

- `.ai/`
  - AI assistant rules and project planning documents.

The exact subfolders may evolve as the implementation progresses, but the principle of per‑tool isolation and shared core components should remain.

---

## Tool Registration & Navigation

All tools are discoverable by the app shell through a central registry:

- **Tool descriptor**
  - A `ToolDescriptor` struct contains:
    - `id` – unique identifier.
    - `name` – human‑readable name.
    - `iconName` – symbol name for display.
    - `category` – optional grouping (e.g. "Formatters", "Encoders/Decoders").
    - `shortDescription` – brief description for the home screen.

- **Tool registry**
  - A `ToolRegistry` type provides:
    - A list of all available tool descriptors.
    - A way to create the SwiftUI view for a given tool ID.

- **Home view**
  - The main screen shows tools in a list or grid, with search and filters.
  - Selecting a tool navigates to its view using `NavigationStack` and `navigationDestination(for:)`.

This design allows tools to be added or removed by updating the registry without changing core navigation logic.

---

## Shared UI Patterns

To keep the UX consistent across tools:

- **Input and output components**
  - `InputPanel`: Reusable component for text input with clear editable affordance:
    - White background with accent-colored border.
    - Pencil icon to indicate editable state.
    - Monospaced font.
    - Clear actions for paste, copy, and reset.
    - Optional validation/error messages.
  - `OutputSection`: Reusable component for output that expands naturally with content:
    - Gray background (`Color.gray.opacity(0.1)`) to indicate read-only state.
    - Document icon to indicate output state.
    - No fixed height - grows with content and scrolls at page level.
    - Copy button with visual feedback animation.
    - Monospaced font with text selection enabled.

- **Split views**
  - For tools like formatters, converters, and previews, a split layout is used:
    - Left: input.
    - Right: output/preview.
  - On compact width (iOS), this may collapse into a vertical stack.

- **Tool headers**
  - Each tool screen starts with a header that includes:
    - Title (full width, no wrapping).
    - Short description.
    - Tool icon.
  - Note: Action buttons (Copy, Paste, Clear) are placed in input/output panels, not in the header, to prevent layout issues and maintain consistency.

- **Page-level scrolling**
  - Tool views are wrapped in `ScrollView` to allow content to expand naturally.
  - Output sections grow vertically without fixed-height constraints.
  - Users scroll the entire page to see all content.

These components live in `SharedUI/` and should be reused rather than re‑creating one‑off, slightly different versions per tool.

---

## Platform Considerations

DevUtility targets both iOS and macOS:

- **Shared code first**
  - Most logic and views are shared without platform checks.
  - Conditional compilation (`#if os(iOS)`, `#if os(macOS)`) is used sparingly for:
    - Platform‑specific UI behavior.
    - Platform‑specific services (e.g., file export dialogs).

- **Keyboard and mouse**
  - On macOS (and iPad with hardware keyboards), keyboard shortcuts and pointer interactions should be considered where they add value.

---

## Testing Strategy

Testing focuses on the core logic that powers each tool:

- **Unit tests**
  - Verify parsers, formatters, converters, and validators.
  - Aim for deterministic behavior (especially for generators like Lorem Ipsum).

- **Integration tests (optional)**
  - Simple scenarios exercising multiple components together (e.g., JSON parsing + formatting).

UI tests are optional and should be added selectively when they significantly increase confidence without adding brittle maintenance overhead.

---

## Future Evolution

As DevUtility grows, this architecture can evolve to include:

- Additional shared services (e.g. export/import helpers, recent items, favorites).
- Multi‑window/multi‑scene setups on macOS and iPadOS.
- Localized strings and more comprehensive accessibility tooling.

Any such evolution should:

- Keep tools isolated and independently testable.
- Maintain a small, understandable core of shared services.
- Continue to follow the SwiftUI data flow and environment‑driven design described here.
