# Pause App - Development Setup Guide

This guide provides step-by-step instructions for setting up the Pause app development environment.

## Prerequisites

### Required Software
- **Xcode 15.0+**: Download from Mac App Store or Apple Developer portal
- **macOS 12.0+**: Required for Xcode 15.0+
- **Git**: Command line tools (comes with Xcode)

### Optional but Recommended
- **Xcode Command Line Tools**: `xcode-select --install`
- **iOS Simulator**: Additional device simulators for testing
- **SF Symbols**: For icon development (free from Apple)

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/[username]/pause-app.git
cd pause-app
```

### 2. Open the Project
```bash
open Pause.xcodeproj
```

### 3. Configure Code Signing
1. Select the `Pause` project in Xcode navigator
2. Go to "Signing & Capabilities" tab
3. Select your development team
4. Xcode will automatically generate provisioning profiles

### 4. Build and Run
1. Select your target device or simulator (iPhone 15 Pro recommended)
2. Press `⌘+R` to build and run
3. App should launch successfully on your selected device

## Project Structure

```
Pause/
├── Pause/                    # Main app source code
│   ├── Views/               # SwiftUI views
│   ├── ViewModels/          # MVVM view models
│   ├── Models/              # Data models
│   ├── Services/            # Business logic services
│   └── Resources/           # Assets, sounds, etc.
├── PauseTests/              # Unit tests
├── PauseUITests/            # UI tests
└── docs/                    # Documentation
```

## Development Workflow

### Building for Different Platforms
```bash
# Build for iPhone simulator
xcodebuild -project Pause.xcodeproj -scheme Pause -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build for device (requires code signing)
xcodebuild -project Pause.xcodeproj -scheme Pause -destination 'platform=iOS,name=Your iPhone' build
```

### Running Tests
```bash
# Run unit tests
xcodebuild -project Pause.xcodeproj -scheme Pause -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

# Run specific test
xcodebuild -project Pause.xcodeproj -scheme Pause -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PauseTests/TimerTests test
```

### Code Formatting
- Use Xcode's built-in formatting (⌘+A, ⌘+I)
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation comments for public APIs

## Common Issues and Solutions

### Build Errors

**"ContentView.swift not found"**
- This indicates missing source files
- Check that all files are properly added to the Xcode project
- Verify file paths in project navigator

**Code Signing Issues**
- Ensure you have a valid Apple Developer account
- Check that provisioning profiles are up to date
- Try cleaning build folder (⌘+Shift+K) and rebuilding

**Simulator Issues**
- Reset simulator: Device → Erase All Content and Settings
- Restart simulator application
- Check iOS version compatibility

### Performance Issues
- Use Instruments to profile app performance
- Check for memory leaks in timer implementations
- Verify smooth animations on older devices

## Testing Setup

### Unit Testing
- All ViewModels should have corresponding unit tests
- Timer logic requires special attention to timing precision
- Mock external dependencies for isolated testing

### UI Testing
- Test complete user flows (breathing → hold → results)
- Verify accessibility features
- Test interruption handling (incoming calls, backgrounding)

### Device Testing
- Test on various iOS versions (15.0+)
- Verify performance on older devices (iPhone 12, SE)
- Check haptic feedback on supported devices

## Environment Configuration

### Development Environment
```swift
// Use these settings for development builds
#if DEBUG
let isDebugMode = true
let logLevel = .verbose
#endif
```

### Production Environment
```swift
// Production settings
#if RELEASE
let isDebugMode = false
let logLevel = .error
#endif
```

## Contributing Workflow

1. Create feature branch: `git checkout -b feature/breathing-timer`
2. Make changes and commit: `git commit -m "feat: Add breathing timer implementation"`
3. Push to GitHub: `git push origin feature/breathing-timer`
4. Create pull request with description and testing notes
5. Address code review feedback
6. Merge after approval

## Troubleshooting

### App Won't Launch
1. Clean build folder (⌘+Shift+K)
2. Reset simulator
3. Check Console.app for error messages
4. Verify all required frameworks are linked

### Timer Accuracy Issues
- Test on physical device (simulators may have timing variations)
- Use Instruments to profile timer performance
- Check for background execution policies

### Memory Issues
- Use Instruments to check for memory leaks
- Verify proper timer cleanup in ViewModels
- Check for retain cycles in closures

## Additional Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS App Development Guide](https://developer.apple.com/ios/)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)
- [Swift Language Guide](https://docs.swift.org/swift-book/) 