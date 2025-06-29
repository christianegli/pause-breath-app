import SwiftUI

// MARK: - Main Screen View

/**
 * MainScreenView: The initial home screen with pulsating circle and start button
 * 
 * Displays user progress, streak information, and the main call-to-action
 * to begin a breathing session.
 */
struct MainScreenView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            // Progress Section
            VStack(spacing: 16) {
                Text("Pause")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                HStack(spacing: 30) {
                    VStack {
                        Text(sessionViewModel.streakDisplay)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                        Text("Current Streak")
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    
                    VStack {
                        Text(sessionViewModel.personalBestDisplay)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                        Text("Personal Best")
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Pulsating circle - core visual element
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.blue.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.8 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Inner circle for visual depth
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 0.8 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            Spacer()
            
            // Main call-to-action button
            Button(action: {
                sessionViewModel.startSession()
            }) {
                Text("Begin Your Pause")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 240, height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color.blue.opacity(0.8))
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(sessionViewModel.isLoading)
            .padding(.bottom, 40)
            
            // Subtle hint text
            Text("Take a moment to breathe")
                .font(.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Breathing View

/**
 * BreathingView: Guided breathing preparation phase
 * 
 * Displays breathing instructions and countdown timer to guide the user
 * through the preparatory breathing cycles.
 */
struct BreathingView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack(spacing: 60) {
            // Header
            VStack(spacing: 16) {
                Text("Prepare")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                Text("Follow the breathing guidance")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 80)
            
            Spacer()
            
            // Breathing instruction and timer
            VStack(spacing: 40) {
                // Breathing instruction text
                Text(sessionViewModel.timerService.breathingPhase.instruction)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .animation(.easeInOut(duration: 0.3), value: sessionViewModel.timerService.breathingPhase)
                
                // Countdown timer
                Text(sessionViewModel.sessionProgress)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
                    .animation(.easeInOut(duration: 0.1), value: sessionViewModel.sessionProgress)
                
                // Animated breathing circle
                BreathingCircle(
                    phase: sessionViewModel.timerService.breathingPhase,
                    timeRemaining: sessionViewModel.timerService.breathingSecondsRemaining
                )
            }
            
            Spacer()
            
            // Cancel button
            Button(action: {
                sessionViewModel.cancelSession()
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary.opacity(0.1))
                    )
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Transition View

/**
 * TransitionView: Brief pause before breath-hold begins
 * 
 * Provides a calm transition moment with final instructions
 * before the breath-hold timer starts.
 */
struct TransitionView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Get Ready")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.primary.opacity(0.8))
                .padding(.top, 120)
            
            Spacer()
            
            VStack(spacing: 40) {
                Text("Take a deep breath in...")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Expanding circle animation
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.4),
                                Color.blue.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(1.2)
                    .opacity(0.8)
                    .animation(
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: true
                    )
            }
            
            Spacer()
            
            Text("Hold when ready")
                .font(.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.bottom, 80)
        }
    }
}

// MARK: - Hold View

/**
 * HoldView: Breath-hold timing phase with visual feedback
 * 
 * Displays the growing timer and expanding circle animation
 * while the user holds their breath.
 */
struct HoldView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var circleScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Hold")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.primary.opacity(0.8))
                .padding(.top, 120)
            
            Spacer()
            
            // Hold timer display
            VStack(spacing: 40) {
                Text(sessionViewModel.sessionProgress)
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .foregroundColor(.blue.opacity(0.9))
                    .animation(.none, value: sessionViewModel.sessionProgress)
                
                // Expanding circle that grows with hold duration
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.3),
                                    Color.blue.opacity(0.05)
                                ]),
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(circleScale)
                        .animation(.easeOut(duration: 0.1), value: circleScale)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .scaleEffect(circleScale * 0.8)
                        .animation(.easeOut(duration: 0.1), value: circleScale)
                }
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    if sessionViewModel.sessionState == .holding {
                        // Gradually expand circle based on hold duration
                        let duration = sessionViewModel.timerService.holdDuration
                        circleScale = 0.8 + min(duration / 60.0, 0.6) // Grow over 60 seconds
                    }
                }
            }
            
            Spacer()
            
            // Release button
            Button(action: {
                sessionViewModel.endHold()
            }) {
                Text("Release")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue.opacity(0.8))
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 80)
        }
        .onAppear {
            circleScale = 0.8
        }
    }
}

// MARK: - Results View

/**
 * ResultsView: Session completion and results display
 * 
 * Shows the final hold time, encouraging message, and options
 * to continue or return to the main screen.
 */
struct ResultsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack(spacing: 50) {
            // Header
            VStack(spacing: 16) {
                Text("Complete")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                if sessionViewModel.isNewPersonalBest {
                    Text("🎉 New Personal Best!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.top, 100)
            
            Spacer()
            
            // Results display
            VStack(spacing: 30) {
                // Hold time
                Text(sessionViewModel.sessionProgress)
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .foregroundColor(.blue.opacity(0.9))
                
                // Encouraging message
                Text(sessionViewModel.completionMessage)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Updated progress
                HStack(spacing: 40) {
                    VStack {
                        Text(sessionViewModel.streakDisplay)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                        Text("Streak")
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    
                    VStack {
                        Text(sessionViewModel.personalBestDisplay)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                        Text("Personal Best")
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 20) {
                Button(action: {
                    sessionViewModel.returnToMain()
                }) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue.opacity(0.8))
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    sessionViewModel.startSession()
                }) {
                    Text("Practice Again")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Animated Breathing Circle

/**
 * BreathingCircle: Animated circle that syncs with breathing phases
 * 
 * Provides visual feedback during guided breathing by expanding
 * and contracting in sync with inhale/exhale instructions.
 */
struct BreathingCircle: View {
    let phase: TimerService.BreathingPhase
    let timeRemaining: Double
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.4),
                        Color.blue.opacity(0.1)
                    ]),
                    center: .center,
                    startRadius: 30,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: phase) { newPhase in
                updateAnimation(for: newPhase)
            }
    }
    
    private func updateAnimation(for phase: TimerService.BreathingPhase) {
        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: 0.5)) {
                scale = 1.3
                opacity = 0.8
            }
        case .exhale:
            withAnimation(.easeInOut(duration: 0.5)) {
                scale = 0.7
                opacity = 0.4
            }
        case .hold:
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
                opacity = 0.9
            }
        default:
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
                opacity = 0.6
            }
        }
    }
} 