# Contributing to DevUtility

DevUtility is a small SwiftUI app for iOS and macOS that groups together focused developer tools. This guide keeps contribution expectations short and aligned with the current repository layout.

## Before You Open a PR

- Use a recent Xcode version that can open `DevUtility.xcodeproj`.
- Build and run the `DevUtility` scheme on at least one platform you touched.
- Keep changes focused. Small feature or bug-fix PRs are easier to review and safer to merge.

## Current Repository Layout

- `DevUtility/DevUtilityApp.swift`: app entry point and top-level scene setup.
- `DevUtility/ContentView.swift`: app shell, tool metadata, navigation, and tool dispatch.
- `DevUtility/Core/`: shared services and app-wide state such as settings and clipboard access.
- `DevUtility/SharedUI/`: reusable SwiftUI components shared across tools.
- `DevUtility/Tools/<ToolName>/`: tool-specific views and logic.
- `docs/architecture.md`: high-level architecture notes.
- `README.md`, `CHANGELOG.md`, `TODO.md`: product overview, release notes, and planned work.

## Coding Expectations

- Prefer SwiftUI-native data flow: `@State`, `@Binding`, and environment-injected services.
- Keep tool logic small and testable. Pure parsing, formatting, and conversion code should live outside the view when practical.
- Reuse shared UI components before creating one-off panels or headers.
- Follow the existing naming and folder conventions already used in the project.
- Avoid adding new dependencies unless there is a clear need.

## Adding or Updating a Tool

1. Add the implementation under `DevUtility/Tools/<ToolName>/`.
2. Put reusable logic in `DevUtility/Core/` and reusable UI in `DevUtility/SharedUI/` when it is not specific to one tool.
3. Register the tool metadata in `ContentView.Tool` inside `DevUtility/ContentView.swift`.
4. Route implemented tools in `ContentView.ToolDetailView` inside `DevUtility/ContentView.swift`.
5. Reuse the current shared UI patterns where they fit, especially `ToolHeaderView`, `InputPanel`, and `OutputSection`.
6. Update `README.md`, `TODO.md`, and `CHANGELOG.md` when the change is user-visible or affects roadmap/docs.

## Testing

There is no dedicated test target in the repository today.

- Manually verify the affected workflow in the app before opening a PR.
- If you introduce reusable logic that would benefit from automated coverage, keep it isolated so a test target can be added cleanly.
- For UI changes, include screenshots when they make review easier.

## Pull Requests

- Describe what changed and why.
- Include brief verification steps.
- Mention any known limitations or follow-up work.
- Keep commit messages clear and specific.

When in doubt, prefer matching the existing structure in the repo over older docs or inferred patterns.
