# Contributing to Pause

Thank you for your interest in contributing to the Pause breath-holding training app! This document provides guidelines for contributing to the project.

## Development Philosophy

### MVP First Approach
- **Priority**: Core functionality (breathing → hold → results) before any enhancements
- **Principle**: Every feature must serve the core 2-minute breathing exercise
- **Decision Making**: Ask "Does this make the breathing experience better?" before adding features

### Code Quality Standards
- **Simplicity**: Prefer simple, readable code over clever optimizations
- **Documentation**: All public APIs and complex logic must be documented
- **Testing**: New features require corresponding unit tests
- **Architecture**: Follow established MVVM patterns and SwiftUI best practices

## Getting Started

### 1. Environment Setup
Follow the complete setup guide in [`docs/SETUP.md`](SETUP.md).

### 2. Understanding the Codebase
- Read [`ARCHITECTURE.md`](../ARCHITECTURE.md) for system overview
- Review [`DECISIONS.md`](../DECISIONS.md) for technical rationale
- Examine existing ViewModels to understand patterns

### 3. Development Workflow
```bash
# 1. Fork and clone
git clone https://github.com/[your-username]/pause-app.git
cd pause-app

# 2. Create feature branch
git checkout -b feature/your-feature-name

# 3. Make changes following guidelines below

# 4. Test thoroughly
# Run unit tests, UI tests, and manual testing

# 5. Commit with meaningful messages
git commit -m "feat: Add breathing phase visual indicator"

# 6. Push and create pull request
git push origin feature/your-feature-name
```

## Code Standards

### Swift Style Guide
- **Naming**: Use descriptive names (`breathingCycleCount` not `count`)
- **Functions**: Keep functions small and focused on single responsibility
- **Comments**: Explain *why*, not *what* the code does
- **Constants**: Use meaningful constant names (`private let breathingCycleDuration = 4.0`)

### SwiftUI Best Practices
```swift
// Good: Clear state management
struct BreathingView: View {
    @StateObject private var viewModel = BreathingViewModel()
    
    var body: some View {
        // UI implementation
    }
}

// Good: Proper documentation
/**
 * Manages the breathing preparation phase of the exercise.
 * 
 * Handles the 3-cycle breathing pattern (4s inhale, 6s exhale)
 * and transitions to the breath-hold phase.
 */
class BreathingViewModel: ObservableObject {
    // Implementation
}
```

### MVVM Architecture
- **Views**: Only UI concerns, no business logic
- **ViewModels**: State management and business logic
- **Models**: Data structures and domain objects
- **Services**: Shared functionality (timers, storage, etc.)

## Testing Requirements

### Unit Tests
- All ViewModels must have unit tests
- Timer logic requires special attention to accuracy
- Mock external dependencies for isolated testing

```swift
class BreathingViewModelTests: XCTestCase {
    func testBreathingCycleCompletion() {
        // Test implementation
    }
    
    func testTimerAccuracy() {
        // Test timer precision
    }
}
```

### UI Tests
- Test complete user flows
- Verify accessibility features
- Test interruption handling

### Manual Testing Checklist
- [ ] App builds and runs on iOS simulator
- [ ] Breathing timer shows correct countdown
- [ ] Hold timer measures accurately
- [ ] Results display correctly
- [ ] App handles backgrounding gracefully
- [ ] Haptic feedback works on device
- [ ] Accessibility features function properly

## Pull Request Guidelines

### Before Submitting
1. **Test thoroughly**: Run all tests and manual testing
2. **Update documentation**: Reflect any API or behavior changes
3. **Follow conventions**: Use established patterns and naming
4. **Check performance**: Ensure no regression in timer accuracy or battery usage

### PR Description Template
```markdown
## Summary
Brief description of the changes and motivation.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## MVP Impact
- [ ] Core functionality (breathing/hold/results)
- [ ] Enhancement feature
- [ ] Infrastructure/tooling

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated
- [ ] Manual testing completed
- [ ] Tested on physical device

## Screenshots/Demo
[Include screenshots or screen recordings if UI changes]

## Additional Notes
Any additional context, known limitations, or follow-up work needed.
```

### Review Process
1. **Automated checks**: CI/CD pipeline runs tests and linting
2. **Code review**: Team member reviews for code quality and architecture
3. **Testing verification**: Reviewer tests the changes
4. **Approval**: Changes merged after approval

## Feature Development

### MVP Features (High Priority)
These features are essential to the core breathing experience:
- Breathing guidance timer
- Hold timer with visual feedback
- Session results display
- Basic navigation and state management

### Enhancement Features (Lower Priority)
These features enhance the experience but aren't essential:
- Progress tracking and streaks
- Multiple breathing exercise types
- Educational content
- Advanced customization

### Feature Proposal Process
1. **Create issue**: Describe the feature and its value
2. **Discuss approach**: Team discussion on implementation
3. **Architecture review**: Ensure alignment with existing design
4. **Implementation**: Follow standard development workflow

## Bug Reports

### Information to Include
- **iOS version**: Specific iOS version and device model
- **App version**: Version number and build
- **Steps to reproduce**: Detailed steps to recreate the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Screenshots/logs**: Visual evidence or error messages

### Bug Priority Levels
- **Critical**: App crashes, core functionality broken
- **High**: Feature doesn't work as intended
- **Medium**: Minor functionality issues
- **Low**: Cosmetic issues, minor improvements

## Documentation

### Required Documentation
- **API changes**: Update relevant documentation
- **New features**: Add to README and architecture docs
- **Decisions**: Record significant technical decisions in DECISIONS.md
- **Setup changes**: Update SETUP.md if development process changes

### Documentation Style
- Use clear, concise language
- Include code examples for APIs
- Explain rationale behind decisions
- Keep information current and accurate

## Performance Considerations

### Timer Accuracy
- Test timer precision on physical devices
- Use appropriate timer types for different use cases
- Handle background execution properly

### Battery Usage
- Profile app with Instruments
- Optimize timer usage for battery efficiency
- Test on older devices for performance

### Memory Management
- Check for memory leaks in timer implementations
- Verify proper cleanup of resources
- Test app stability during long sessions

## Accessibility

### Requirements
- VoiceOver support for all interactive elements
- Proper semantic labels and hints
- Support for Dynamic Type (text sizing)
- Keyboard navigation support
- Color contrast compliance

### Testing
- Test with VoiceOver enabled
- Verify with different text sizes
- Check color contrast ratios
- Test with Switch Control if applicable

## Questions and Support

### Getting Help
- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Use GitHub discussions for questions and ideas
- **Documentation**: Check existing documentation first

### Contact
- Create an issue for project-specific questions
- Tag maintainers for urgent issues
- Use clear, descriptive titles for better response

Thank you for contributing to Pause! Your efforts help create a better breathing and meditation experience for users worldwide. 