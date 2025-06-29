# Pause - Breath-Holding Training App

A minimalist iOS app designed for breath-holding training and meditation. Focus on a single, guided breathing exercise that helps users track and improve their breath-hold duration over time.

## Overview

Pause centers around a simple yet powerful concept: a 2-minute guided breathing exercise followed by a timed breath-hold. The app provides:

- **Guided Breathing Preparation**: 4-second inhale, 6-second exhale for 3 cycles
- **Visual Breath-Hold Timer**: Expanding circle with precise timing
- **Immediate Feedback**: Session results with encouraging messages
- **Progress Tracking**: Personal bests and streak monitoring

## Core Philosophy

The app prioritizes simplicity and immediate value over complex features. Users can open the app, complete a meaningful breathing exercise, and close it within minutes - building a sustainable daily practice.

## MVP Features (Current Focus)

- [x] Basic app structure
- [ ] Clean, minimal user interface
- [ ] Guided breathing timer (4s in, 6s out, 3 cycles)
- [ ] Breath-hold timer with visual feedback
- [ ] Session completion and results display
- [ ] Basic navigation and state management

## Future Enhancements

- Progressive unlocks based on daily streaks
- Multiple breathing exercise types
- Visual progress tracking ("constellation" display)
- Educational content ("The Vault")
- Advanced customization options

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ target device or simulator
- macOS development environment

### Building the App
1. Clone the repository
2. Open `Pause.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘+R)

## Project Status

**Current Phase**: MVP Development  
**Status**: Fixing compilation issues and implementing core functionality  
**Target Platform**: iOS  

## Architecture

The app follows a clean MVVM (Model-View-ViewModel) architecture using SwiftUI:

- **Views**: SwiftUI components for user interface
- **ViewModels**: State management and business logic
- **Models**: Data structures for session tracking
- **Services**: Timer management and local storage

## Contributing

This project is currently in active development. See `docs/CONTRIBUTING.md` for development guidelines and setup instructions.

## License

MIT License - see LICENSE file for details.

## Contact

For questions or feedback about this project, please open an issue on GitHub. 