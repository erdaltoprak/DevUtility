# DevUtility

![DevUtility](images/header.png)

DevUtility is a native SwiftUI app for iOS and macOS that collects small, local developer utilities in one place. The current build focuses on a small proof-of-concept set of tools, with additional planned tools tracked in `TODO.md`.

## Availability

DevUtility is available on the App Store for iPhone, iPad, and Mac.

- **iOS & macOS App Store**: [DevUtility • Developer Tools](https://apps.apple.com/app/id6756852841)

## Current Features

Implemented today:

- **Unix Timestamp Converter**: Convert timestamps and date strings with automatic interpretation and detailed output.
- **Base64 Encoder/Decoder**: Encode plain text to Base64 or decode Base64 back to UTF-8 text.
- **Lorem Ipsum Generator**: Generate placeholder text with configurable paragraph count.
- **Text Diff Checker**: Compare two text inputs and inspect the diff output.
- **Settings / About**: Open project and author links from the app.

Planned tools remain listed in `ContentView.Tool.optionalTools` and `TODO.md`, but they are not implemented yet.

## Project Structure

- `DevUtility/DevUtilityApp.swift`: app entry point.
- `DevUtility/ContentView.swift`: app shell, tool metadata, navigation, and tool view dispatch.
- `DevUtility/Core/`: shared state and services such as `SettingsStore`, `AppTheme`, and `ClipboardService`.
- `DevUtility/SharedUI/`: reusable SwiftUI components used across tools.
- `DevUtility/Tools/`: tool-specific views and supporting logic.
- `docs/architecture.md`: architecture notes.
- `CONTRIBUTING.md`: contribution workflow and repo conventions.

## Architecture

The app uses a shared SwiftUI codebase for iOS and macOS.

- iOS uses `NavigationStack`.
- macOS uses `NavigationSplitView`.
- Shared state and services are provided through the SwiftUI environment.
- Tool-specific logic lives alongside each tool under `DevUtility/Tools/`.

For more detail, see `docs/architecture.md`.

## Requirements

- A recent Xcode version that can open `DevUtility.xcodeproj`.
- Swift 6.2 or newer.
- The project currently targets iOS 26.1 and macOS 26.1 in Xcode project settings.

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/erdaltoprak/DevUtility.git
cd DevUtility
```

2. Open `DevUtility.xcodeproj` in Xcode.
3. Select an iOS or macOS run destination.
4. Build and run the `DevUtility` scheme.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE.md](LICENSE.md).
