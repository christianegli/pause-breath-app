# Architecture Decision Records (ADR)

This document tracks the major technical and architectural decisions made during the development of the Pause app, following the ADR format for future reference and onboarding.

## ADR-001: iOS Platform Targeting
**Date**: 2025-01-29  
**Status**: Accepted

### Context
The Pause app needs to target a specific platform for consistent development and deployment. Given the nature of the app (personal meditation/breathing practice), mobile-first approach is most appropriate.

### Decision
Target iOS only, specifically iOS 15.0+ to ensure modern SwiftUI feature compatibility while maintaining reasonable device support.

### Rationale
- Mobile phones are the primary device for personal meditation practices
- iOS offers excellent SwiftUI support and development tools
- Single platform focus allows for faster MVP development
- User base research indicates iPhone users are primary target demographic

### Consequences
- No macOS or Android versions in MVP
- Can leverage iOS-specific features (haptics, background modes)
- Faster development cycle with single platform focus
- Future expansion to other platforms will require separate development effort

### Alternatives Considered
- Cross-platform (React Native, Flutter): Adds complexity to MVP
- macOS: Less relevant for mobile breathing exercises
- Universal iOS/macOS: Increases complexity and testing burden

---

## ADR-002: SwiftUI Framework Choice
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Need to choose UI framework for iOS development. Options include UIKit (traditional) or SwiftUI (modern declarative).

### Decision
Use SwiftUI as the primary UI framework.

### Rationale
- Declarative UI paradigm matches well with breathing app's simple, state-driven interface
- Modern Apple development standard with excellent animation support
- Faster development for MVP with less boilerplate code
- Built-in accessibility features
- Excellent support for iOS 15.0+ target

### Consequences
- Modern, maintainable codebase
- Excellent animation capabilities for breathing visualizations  
- Some advanced customizations may require UIKit integration
- Learning curve for developers not familiar with SwiftUI

### Alternatives Considered
- UIKit: More mature but requires significantly more boilerplate
- Hybrid approach: Unnecessary complexity for MVP scope

---

## ADR-003: Local-First Data Architecture
**Date**: 2025-01-29  
**Status**: Accepted

### Context
The app needs to store user breathing session data, preferences, and progress tracking. Cloud sync could be valuable but adds complexity.

### Decision
Implement local-first data storage using Core Data, with cloud sync as a future enhancement.

### Rationale
- MVP should work offline without internet dependency
- Personal meditation data is sensitive - local storage provides privacy
- Core Data integrates well with SwiftUI
- CloudKit integration can be added later without architectural changes
- Simpler implementation reduces MVP development time

### Consequences
- Faster MVP development
- No account management complexity
- Data privacy by default
- Future cloud sync will require migration strategy
- No cross-device synchronization in MVP

### Alternatives Considered
- CloudKit from start: Adds authentication and sync complexity
- Third-party solutions (Firebase): Introduces external dependencies
- UserDefaults: Too simple for structured session data

---

## ADR-004: Timer Implementation Strategy
**Date**: 2025-01-29  
**Status**: Accepted

### Context
Breathing exercises require precise timing for guidance phases and breath-holding measurement. Need reliable timer implementation that works in background.

### Decision
Use dual timer approach: 
- `Timer.scheduledTimer` for breathing guidance (inhale/exhale prompts)
- `CADisplayLink` for breath-hold precision timing and measurement

### Rationale
- Different timing needs require different precision levels
- Timer class sufficient for breathing guidance (1-second precision)
- CADisplayLink provides sub-second precision for breath-hold measurement
- Both can be configured to work with background app refresh
- Native iOS solutions without external dependencies

### Consequences
- Precise timing for both guidance and measurement
- Good battery life with appropriate timer usage
- Slightly more complex implementation than single timer
- Requires background modes configuration

### Alternatives Considered
- Single Timer approach: Insufficient precision for breath-hold measurement
- Third-party timing libraries: Unnecessary complexity
- Manual thread management: More error-prone

---

## ADR-005: MVVM Architecture Pattern
**Date**: 2025-01-29  
**Status**: Accepted

### Context
SwiftUI apps benefit from clear separation of concerns and reactive data flow. Need architecture that supports this while remaining simple for MVP.

### Decision
Implement MVVM (Model-View-ViewModel) pattern with ObservableObject ViewModels.

### Rationale
- Natural fit with SwiftUI's reactive programming model
- Clear separation between UI (View) and business logic (ViewModel)
- SwiftUI's `@StateObject` and `@ObservedObject` integrate perfectly
- Simple enough for MVP while allowing future expansion
- Testable architecture with mockable ViewModels

### Consequences
- Clean, maintainable code structure
- Easy to unit test business logic
- Natural reactive data flow
- Slightly more boilerplate than simple @State approach
- ViewModels must be carefully designed to avoid retain cycles

### Alternatives Considered
- Simple @State management: Too limited for session tracking
- Redux/TCA: Overengineered for MVP scope
- MVC: Doesn't leverage SwiftUI strengths

---

## ADR-006: macOS to iOS Migration Fix
**Date**: 2025-01-29  
**Status**: Accepted

### Context
The project was initially configured for macOS but needed to be migrated to iOS. The build was failing due to macOS-specific code that doesn't exist in iOS.

### Decision
Remove macOS-specific `.windowStyle(HiddenTitleBarWindowStyle())` modifier from PauseApp.swift.

### Rationale
- iOS apps don't have traditional windows with title bars like macOS
- The windowStyle modifier is macOS-only and causes compilation errors on iOS
- iOS WindowGroup doesn't need additional styling for the basic MVP UI
- Removing this code aligns with our iOS-first platform strategy (ADR-001)

### Consequences
- iOS build now succeeds without errors
- Cleaner, platform-appropriate code
- No visual impact on iOS as the modifier was non-functional anyway
- Future macOS support would need different window styling approach

### Implementation
Removed line: `.windowStyle(HiddenTitleBarWindowStyle())` from PauseApp.swift

### Alternatives Considered
- Conditional compilation (#if os(macOS)): Unnecessary complexity for iOS-only target
- Custom window styling: Not needed for MVP scope
- Keep as comment: Adds confusion without benefit

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