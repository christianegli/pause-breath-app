# Pause App - System Architecture

## Overview
Pause is built as a native iOS app using SwiftUI and follows clean architecture principles. The app prioritizes simplicity and performance for timer-based breathing exercises.

## Design Principles

### 1. MVP First
Core functionality (guided breathing + breath-hold timer) implemented before any enhancements. Every feature decision evaluated against: "Does this serve the core 2-minute breathing exercise?"

### 2. Simplicity Over Features
- Single primary user flow: Open app → Breathe → Hold → Results → Close
- Minimal UI elements to reduce cognitive load during exercises
- No unnecessary animations or distractions during breathing focus

### 3. Precision & Reliability  
- Accurate timing is critical for breathing guidance and hold measurement
- App must handle interruptions gracefully (calls, notifications, backgrounding)
- State persistence to resume sessions if interrupted

### 4. Calm User Experience
- Muted color palette and gentle animations
- No jarring transitions or aggressive notifications
- Interface design supports meditative focus

## Component Architecture

### Core SwiftUI Architecture
```
PauseApp (App Entry Point)
├── ContentView (Main Navigation)
├── BreathingView (Guided Breathing Screen)
├── HoldView (Breath-Hold Timer Screen)
├── ResultsView (Session Completion Screen)
└── Shared Components
    ├── PulsingCircle (Visual Feedback Component)
    ├── TimerDisplay (Time Display Component)
    └── ProgressIndicator (Breathing Phase Indicator)
```

### View Models (MVVM Pattern)
```
ViewModels/
├── BreathingViewModel (Manages breathing cycles and guidance)
├── HoldViewModel (Handles breath-hold timing and visual feedback)
├── SessionViewModel (Tracks session data and results)
└── AppStateViewModel (Global app state and navigation)
```

### Data Layer
```
Models/
├── BreathingSession (Session data structure)
├── UserProgress (Progress tracking and streaks)
└── AppSettings (User preferences and configuration)

Services/
├── TimerService (High-precision timing management)
├── StorageService (Local data persistence)
└── AudioService (Breathing guidance audio cues)
```

## Data Flow

### Session Flow
1. User taps "Begin Your Pause" → `AppStateViewModel` transitions to breathing
2. `BreathingViewModel` manages 3-cycle breathing preparation
3. Transition to `HoldViewModel` for breath-hold timing
4. `SessionViewModel` captures results and updates progress
5. Return to main screen with session data preserved

### State Management
- **@StateObject**: ViewModels owned by parent views
- **@ObservedObject**: ViewModels passed between views  
- **@AppStorage**: Simple user preferences and settings
- **UserDefaults**: Session history and progress data

### Timer Implementation
- Uses `Timer.scheduledTimer` for breathing guidance (1-second precision adequate)
- Uses `CADisplayLink` for breath-hold timer (60fps precision for smooth visual feedback)
- Background task handling to maintain timing accuracy when app enters background

## Platform Considerations

### iOS-Specific Features
- **Haptic Feedback**: Gentle vibrations for breathing phase transitions
- **Background Modes**: Limited background execution for session completion
- **Accessibility**: VoiceOver support for visually impaired users
- **Dark Mode**: Automatic theme adaptation for system preferences

### Performance Optimization
- Minimal memory footprint during active sessions
- Efficient timer management to preserve battery life
- Lazy loading of enhancement features not needed for MVP

## Security & Privacy

### Data Privacy
- All session data stored locally on device
- No network requests or data transmission
- No user account creation or personal information collection

### Local Storage
- Core Data for session history (if scaling beyond UserDefaults)
- Keychain for any future sensitive preferences
- Automatic data cleanup for storage management

## Technology Choices

### SwiftUI over UIKit
**Rationale**: Faster development for simple interfaces, better state management for timer-based apps, automatic accessibility support

**Trade-offs**:
- Pro: Declarative UI matches meditative app philosophy
- Pro: Built-in animation system ideal for breathing visualizations  
- Con: Less control over precise layout (acceptable for minimal design)

### Local-First Architecture
**Rationale**: Privacy-focused, works offline, faster user experience, simpler implementation

**Trade-offs**:
- Pro: No server infrastructure or costs
- Pro: Complete user privacy and data control
- Con: No cross-device sync (acceptable for MVP)

### Timer Strategy
**Rationale**: Different timer precision needs for different phases

**Implementation**:
- Breathing guidance: 1-second `Timer` (adequate precision, battery efficient)
- Breath-hold timing: `CADisplayLink` (smooth visual animation, precise measurement)
- Background handling: `UIApplication.shared.isIdleTimerDisabled = true` during active sessions

## Future Architecture Considerations

### Scalability
- Modular feature architecture for progressive unlocks
- Plugin system for additional breathing exercise types
- Core framework separation for potential Apple Watch companion

### Data Sync (Post-MVP)
- CloudKit integration for cross-device progress sync
- Conflict resolution for concurrent session data
- Privacy-preserving analytics for feature usage

### Testing Strategy
- Unit tests for ViewModels and timer logic
- UI tests for critical user flows
- Performance tests for timer accuracy and battery usage 