import Foundation
import QuartzCore
import UIKit

/**
 * TimerService: Manages precise timing for breathing exercises
 * 
 * Implements the dual timer strategy from ADR-004:
 * - Timer.scheduledTimer for breathing guidance (1-second precision)
 * - CADisplayLink for breath-hold timing (60fps precision)
 * 
 * Handles background execution and timer cleanup to ensure accurate
 * timing throughout the breathing exercise flow.
 */
class TimerService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var breathingSecondsRemaining: Double = 0
    @Published var holdDuration: TimeInterval = 0
    @Published var isActive: Bool = false
    
    // MARK: - Timer Management
    private var breathingTimer: Timer?
    private var holdDisplayLink: CADisplayLink?
    private var holdStartTime: CFTimeInterval = 0
    
    // MARK: - Breathing Phase Definition
    enum BreathingPhase: Equatable {
        case idle
        case inhale(cycle: Int, total: Int)
        case exhale(cycle: Int, total: Int)
        case hold(cycle: Int, total: Int) // For box breathing
        case transition
        case completed
        
        var instruction: String {
            switch self {
            case .idle:
                return "Ready to begin"
            case .inhale(let cycle, let total):
                return "Breathe in deeply... (\(cycle)/\(total))"
            case .exhale(let cycle, let total):
                return "Breathe out slowly... (\(cycle)/\(total))"
            case .hold(let cycle, let total):
                return "Hold your breath... (\(cycle)/\(total))"
            case .transition:
                return "Get ready..."
            case .completed:
                return "Preparation complete"
            }
        }
        
        var isActive: Bool {
            switch self {
            case .idle, .completed:
                return false
            default:
                return true
            }
        }
    }
    
    // MARK: - Breathing Timer (1-second precision)
    
    /**
     * Start guided breathing preparation with specified pattern
     * 
     * Uses Timer.scheduledTimer for 1-second precision, which is adequate
     * for breathing guidance and more battery efficient than CADisplayLink.
     */
    func startBreathingGuidance(
        inhaleSeconds: Double,
        exhaleSeconds: Double,
        holdSeconds: Double? = nil,
        cycles: Int,
        completion: @escaping () -> Void
    ) {
        guard !isActive else { return }
        
        isActive = true
        var currentCycle = 1
        var currentPhaseTime = inhaleSeconds
        breathingPhase = .inhale(cycle: currentCycle, total: cycles)
        breathingSecondsRemaining = currentPhaseTime
        
        // Prevent device sleep during breathing exercises
        UIApplication.shared.isIdleTimerDisabled = true
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.breathingSecondsRemaining -= 0.1
            
            // Check for phase transition
            if self.breathingSecondsRemaining <= 0 {
                self.advanceBreathingPhase(
                    currentCycle: &currentCycle,
                    totalCycles: cycles,
                    inhaleSeconds: inhaleSeconds,
                    exhaleSeconds: exhaleSeconds,
                    holdSeconds: holdSeconds,
                    currentPhaseTime: &currentPhaseTime,
                    timer: timer,
                    completion: completion
                )
            }
        }
    }
    
    private func advanceBreathingPhase(
        currentCycle: inout Int,
        totalCycles: Int,
        inhaleSeconds: Double,
        exhaleSeconds: Double,
        holdSeconds: Double?,
        currentPhaseTime: inout Double,
        timer: Timer,
        completion: @escaping () -> Void
    ) {
        switch breathingPhase {
        case .inhale:
            if let holdSeconds = holdSeconds {
                // Box breathing: inhale → hold → exhale
                breathingPhase = .hold(cycle: currentCycle, total: totalCycles)
                currentPhaseTime = holdSeconds
            } else {
                // Simple breathing: inhale → exhale
                breathingPhase = .exhale(cycle: currentCycle, total: totalCycles)
                currentPhaseTime = exhaleSeconds
            }
            
        case .hold:
            // Box breathing: hold → exhale
            breathingPhase = .exhale(cycle: currentCycle, total: totalCycles)
            currentPhaseTime = exhaleSeconds
            
        case .exhale:
            // Move to next cycle or complete
            if currentCycle < totalCycles {
                currentCycle += 1
                breathingPhase = .inhale(cycle: currentCycle, total: totalCycles)
                currentPhaseTime = inhaleSeconds
            } else {
                // All cycles completed
                self.completeBreathingGuidance(timer: timer, completion: completion)
                return
            }
            
        default:
            break
        }
        
        breathingSecondsRemaining = currentPhaseTime
    }
    
    private func completeBreathingGuidance(timer: Timer, completion: @escaping () -> Void) {
        timer.invalidate()
        breathingTimer = nil
        breathingPhase = .completed
        isActive = false
        
        // Brief transition pause before completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    // MARK: - Hold Timer (High precision with CADisplayLink)
    
    /**
     * Start precision breath-hold timer with visual feedback
     * 
     * Uses CADisplayLink for 60fps precision timing, essential for smooth
     * visual feedback and accurate hold duration measurement.
     */
    func startHoldTimer() {
        guard !isActive else { return }
        
        isActive = true
        holdDuration = 0
        holdStartTime = CACurrentMediaTime()
        
        // Keep device awake during hold
        UIApplication.shared.isIdleTimerDisabled = true
        
        holdDisplayLink = CADisplayLink(target: self, selector: #selector(updateHoldTimer))
        holdDisplayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateHoldTimer() {
        let currentTime = CACurrentMediaTime()
        holdDuration = currentTime - holdStartTime
    }
    
    /**
     * Stop hold timer and return final duration
     */
    func stopHoldTimer() -> TimeInterval {
        holdDisplayLink?.invalidate()
        holdDisplayLink = nil
        isActive = false
        
        // Re-enable device sleep
        UIApplication.shared.isIdleTimerDisabled = false
        
        return holdDuration
    }
    
    // MARK: - Cleanup and State Management
    
    /**
     * Stop all active timers and reset state
     */
    func stopAllTimers() {
        // Stop breathing timer
        breathingTimer?.invalidate()
        breathingTimer = nil
        
        // Stop hold timer
        holdDisplayLink?.invalidate()
        holdDisplayLink = nil
        
        // Reset state
        isActive = false
        breathingPhase = .idle
        breathingSecondsRemaining = 0
        holdDuration = 0
        
        // Re-enable device sleep
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /**
     * Handle app backgrounding - preserve timer state but pause visual updates
     */
    func handleAppBackground() {
        // CADisplayLink automatically pauses in background
        // Timer continues running for breathing guidance
        // Hold timer maintains accuracy through CACurrentMediaTime()
    }
    
    /**
     * Handle app foregrounding - resume visual updates
     */
    func handleAppForeground() {
        // CADisplayLink automatically resumes
        // Recalculate hold duration from stored start time
        if holdDisplayLink != nil {
            let currentTime = CACurrentMediaTime()
            holdDuration = currentTime - holdStartTime
        }
    }
    
    // MARK: - Formatted Display Values
    
    /// Format hold duration for display (e.g., "01:23")
    var formattedHoldDuration: String {
        let minutes = Int(holdDuration) / 60
        let seconds = Int(holdDuration) % 60
        let centiseconds = Int((holdDuration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
    
    /// Format breathing countdown for display
    var formattedBreathingTime: String {
        let seconds = max(0, Int(ceil(breathingSecondsRemaining)))
        return "\(seconds)"
    }
    
    // MARK: - Deinitialization
    
    deinit {
        stopAllTimers()
    }
}

// MARK: - Background Task Support

extension TimerService {
    
    /**
     * Request background execution time for session completion
     * 
     * Ensures user can complete their breath-hold even if app
     * is backgrounded during the exercise.
     */
    func requestBackgroundTime() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(withName: "BreathingSession") {
            // Cleanup if background time expires
            self.stopAllTimers()
        }
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(identifier)
    }
} 