# Architecture Decision Records (ADR)

This document tracks the major technical and architectural decisions made during the development of the Pause app, following the ADR format for future reference and onboarding.

## ADR-001: iOS Platform Choice
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Initial project was configured for macOS, but the concept document and user experience suggest a mobile app for breath-holding training.

### Decision
Reconfigure project to target iOS exclusively for MVP.

### Rationale
- Breath-holding exercises are typically done in comfortable, private settings where mobile devices are more natural
- Haptic feedback capabilities on iPhone enhance breathing guidance
- Larger potential user base for health/wellness apps on mobile
- Touch interface more intuitive for "hold and release" interactions
- App concept fits mobile usage patterns (quick 2-minute sessions)

### Consequences
- Need to reconfigure Xcode project build settings
- UI design optimized for iPhone screen sizes and orientations
- Access to iOS-specific features (haptics, background modes, etc.)
- Simpler deployment story (App Store vs. multiple Mac distribution methods)

### Alternatives Considered
- **Universal iOS/macOS app**: Added complexity for MVP, unclear value proposition for Mac
- **macOS-first approach**: Poor fit for mobile-centric use case and breathing exercise context

---

## ADR-002: SwiftUI Framework Choice
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Need to choose UI framework for implementing the minimalist breathing app interface.

### Decision
Use SwiftUI for all user interface development.

### Rationale
- **Declarative Paradigm**: Natural fit for timer-based apps with clear state transitions
- **Built-in Animations**: Smooth breathing visualizations (pulsing circles, expanding animations) with minimal code
- **State Management**: `@State`, `@ObservedObject` patterns ideal for timer and session management
- **Development Speed**: Faster iteration for MVP development
- **Modern Platform**: Future-proof choice aligned with Apple's development direction
- **Accessibility**: Automatic VoiceOver and accessibility features

### Consequences
- All UI components built with SwiftUI patterns
- View models follow ObservableObject protocol
- Limited to iOS 13+ minimum deployment target
- Animation and timer logic integrated with SwiftUI lifecycle

### Alternatives Considered
- **UIKit**: More control over precise layouts, but unnecessarily complex for simple interface
- **Hybrid Approach**: Would add complexity without clear benefits for this use case

---

## ADR-003: Local-First Data Architecture
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Need to decide how to store user session data, progress tracking, and app preferences.

### Decision
Implement local-first architecture with all data stored on-device.

### Rationale
- **Privacy Focus**: No user data leaves device, aligning with health/wellness app expectations
- **Simplicity**: No server infrastructure, authentication, or network handling needed for MVP
- **Performance**: Instant app startup and data access
- **Offline-First**: App works without network connectivity
- **Development Speed**: Focus on core functionality rather than backend integration

### Consequences
- All session history stored in UserDefaults or Core Data locally
- No cross-device synchronization in MVP
- No user accounts or authentication needed
- Simpler app architecture and testing

### Alternatives Considered
- **Cloud-Sync Architecture**: Adds complexity, cost, and privacy concerns for MVP
- **Hybrid Local+Cloud**: Premature optimization for feature not validated by users yet

---

## ADR-004: Timer Implementation Strategy
**Date**: 2025-01-29  
**Status**: Accepted

### Context
The app requires two different timing needs: breathing guidance (1-second precision) and breath-hold measurement (smooth visual feedback with precise timing).

### Decision
Use dual timer approach:
- `Timer.scheduledTimer` for breathing guidance phases
- `CADisplayLink` for breath-hold timing with visual feedback

### Rationale
- **Breathing Guidance**: 1-second precision adequate for "4 seconds in, 6 seconds out" guidance
- **Breath-Hold Timer**: Smooth 60fps updates needed for expanding circle animation
- **Battery Efficiency**: Use less precise timer when high precision not needed
- **Visual Smoothness**: CADisplayLink ensures smooth animations during breath-hold

### Consequences
- Two different timer management patterns in codebase
- Background handling needed for both timer types
- ViewModels responsible for appropriate timer selection

### Alternatives Considered
- **Single CADisplayLink**: Overkill for breathing guidance, unnecessary battery drain
- **Single Timer**: Insufficient precision for smooth breath-hold animations
- **Third-party timer library**: Adds dependency for functionality available in system frameworks

---

## ADR-005: MVVM Architecture Pattern
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Need to organize app architecture for clean separation of concerns and testability.

### Decision
Implement MVVM (Model-View-ViewModel) pattern using SwiftUI and ObservableObject.

### Rationale
- **SwiftUI Integration**: Natural fit with `@StateObject` and `@ObservedObject`
- **Testability**: Business logic in ViewModels can be unit tested independently
- **State Management**: Clear separation between UI state and business logic
- **Timer Logic**: Complex timing logic belongs in ViewModels, not Views
- **Reusability**: ViewModels can be shared between different Views if needed

### Consequences
- Each major screen has corresponding ViewModel
- Views remain simple and focused on UI concerns
- Timer and session logic concentrated in ViewModels
- Unit testing strategy focuses on ViewModel behavior

### Alternatives Considered
- **MVC**: Poor separation of concerns for SwiftUI apps
- **VIPER**: Overly complex for simple app with straightforward user flows
- **Redux/TCA**: Unnecessary complexity for MVP with limited state management needs

---

## Template for Future ADRs

```markdown
## ADR-XXX: [Decision Title]
**Date**: [YYYY-MM-DD]  
**Status**: [Proposed|Accepted|Deprecated]

### Context
[Why this decision needed to be made]

### Decision
[What was decided]

### Rationale
[Why this approach was chosen over alternatives]

### Consequences
[What are the implications of this decision]

### Alternatives Considered
[Other options that were evaluated]
``` 