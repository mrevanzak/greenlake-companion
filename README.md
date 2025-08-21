# Greenlake Companion

A SwiftUI iOS app following Apple's best practices and modern iOS development patterns.

## Project Structure

The project follows a clean, modular architecture that separates concerns and promotes maintainability:

```
greenlake-companion/
├── Sources/
│   ├── App/
│   │   └── App.swift                    # Main app entry point
│   ├── Views/
│   │   ├── Home/
│   │   │   └── HomeView.swift           # Main home view
│   │   └── Maps/
│   │       ├── MapsView.swift           # Maps interface
│   │       └── MapViewRepresentable.swift # UIKit bridge for MapKit
│   ├── Components/
│   │   ├── AdaptiveSheet.swift          # Adaptive sheet component
│   │   └── SheetContentViews.swift      # Sheet content components
│   ├── Models/
│   │   └── QuickAction.swift            # Data models
│   ├── Services/
│   │   └── LocationManager.swift       # Location services
│   └── Utilities/
│       ├── Extensions/
│       │   ├── UIDevice+Extensions.swift      # Device detection
│       │   └── CLLocationCoordinate2D+Extensions.swift # Location utilities
│       └── Constants/                   # App constants
└── Assets.xcassets/                     # App assets

```

## Architecture

- **MVVM Pattern**: Uses SwiftUI's native data flow with `@StateObject`, `@ObservedObject`, and `@EnvironmentObject`
- **Protocol-Oriented Programming**: Leverages Swift's protocol system for flexible, testable code
- **Value Types**: Prefers structs over classes for data models
- **Separation of Concerns**: Clear separation between views, services, and models

## Features

- **Maps Integration**: Native MapKit integration with user location
- **Adaptive UI**: Responsive design that adapts to different device sizes (iPhone/iPad)
- **Location Services**: Comprehensive location management with proper permissions
- **Modern SwiftUI**: Uses latest SwiftUI features including adaptive sheets

## Development Guidelines

### Code Style

- Use PascalCase for types, camelCase for variables and functions
- Prefer `let` over `var` where possible
- Use clear, descriptive names following Apple's conventions
- Follow Swift API Design Guidelines

### Architecture Principles

- Single Responsibility Principle (SRP)
- Dependency Injection for testability
- Protocol-first design
- Immutable data structures where possible

### UI Development

- SwiftUI-first approach
- Support for Dark Mode and Dynamic Type
- Proper Safe Area handling
- Responsive layouts for all device sizes

## Building and Running

1. Open `greenlake-companion.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## License

[Add your license information here]
