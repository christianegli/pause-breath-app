import Foundation
import SwiftUI
import UIKit

/**
 * SessionViewModel: Orchestrates the complete breathing exercise session flow
 * 
 * Manages the state transitions between preparation, breathing guidance, 
 * breath-hold, and completion phases. Handles session data persistence
 * and progress tracking according to MVVM architecture principles.
 */
class SessionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentSession: BreathingSession?
    @Published var userProgress = UserProgress()
    @Published var sessionState: SessionState = .ready
    @Published var isLoading = false
    
    // MARK: - Dependencies
    let timerService: TimerService // Public access for view bindings
    private let storageService: StorageService
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Session State Management
    enum SessionState {
        case ready           // Main screen - ready to start
        case breathing       // Guided breathing preparation
        case transitioning   // Brief pause before hold
        case holding         // Breath-hold phase
        case completed       // Session results display
        
        var title: String {
            switch self {
            case .ready:
                return "Pause"
            case .breathing:
                return "Prepare"
            case .transitioning:
                return "Get Ready"
            case .holding:
                return "Hold"
            case .completed:
                return "Complete"
            }
        }
        
        var instruction: String {
            switch self {
            case .ready:
                return "Take a moment to breathe"
            case .breathing:
                return "Follow the breathing guidance"
            case .transitioning:
                return "Take a deep breath in..."
            case .holding:
                return "Hold your breath and tap when ready"
            case .completed:
                return "Session complete"
            }
        }
    }
    
    // MARK: - Initialization
    init(timerService: TimerService = TimerService(), storageService: StorageService = StorageService()) {
        self.timerService = timerService
        self.storageService = storageService
        
        loadUserProgress()
    }
    
    // MARK: - Session Flow Management
    
    /**
     * Start a new breathing session with specified type
     */
    func startSession(type: BreathingSession.SessionType = .ascend) {
        guard sessionState == .ready else { return }
        
        // Create new session
        currentSession = BreathingSession(sessionType: type)
        sessionState = .breathing
        
        // Request background execution time
        backgroundTaskID = timerService.requestBackgroundTime()
        
        // Start guided breathing preparation
        startBreathingPreparation()
    }
    
    /**
     * Begin guided breathing preparation phase
     */
    private func startBreathingPreparation() {
        guard let session = currentSession else { return }
        
        let sessionType = session.sessionType
        
        timerService.startBreathingGuidance(
            inhaleSeconds: sessionType.inhaleSeconds,
            exhaleSeconds: sessionType.exhaleSeconds,
            holdSeconds: sessionType.holdSeconds,
            cycles: sessionType.preparationCycles
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.transitionToHold()
            }
        }
    }
    
    /**
     * Transition from breathing preparation to hold phase
     */
    private func transitionToHold() {
        sessionState = .transitioning
        
        // Brief pause with instruction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startHoldPhase()
        }
    }
    
    /**
     * Begin breath-hold timing phase
     */
    private func startHoldPhase() {
        sessionState = .holding
        timerService.startHoldTimer()
    }
    
    /**
     * User taps to end breath-hold
     */
    func endHold() {
        guard sessionState == .holding else { return }
        
        let holdDuration = timerService.stopHoldTimer()
        completeSession(holdDuration: holdDuration)
    }
    
    /**
     * Complete session and save results
     */
    private func completeSession(holdDuration: TimeInterval) {
        guard var session = currentSession else { return }
        
        // Update session with results
        session.complete(holdDuration: holdDuration)
        currentSession = session
        
        // Update user progress
        userProgress.addSession(session)
        
        // Save to storage
        saveSessionAndProgress(session)
        
        // Update UI state
        sessionState = .completed
        
        // End background task
        if backgroundTaskID != .invalid {
            timerService.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    /**
     * Return to main screen after session completion
     */
    func returnToMain() {
        guard sessionState == .completed else { return }
        
        // Reset session state
        currentSession = nil
        sessionState = .ready
        
        // Stop any remaining timers
        timerService.stopAllTimers()
    }
    
    /**
     * Cancel active session and return to main screen
     */
    func cancelSession() {
        // Stop all timers
        timerService.stopAllTimers()
        
        // End background task if active
        if backgroundTaskID != .invalid {
            timerService.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        // Reset state
        currentSession = nil
        sessionState = .ready
    }
    
    // MARK: - Progress and Data Management
    
    /**
     * Load user progress from storage
     */
    private func loadUserProgress() {
        isLoading = true
        
        storageService.loadUserProgress { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let progress):
                    self?.userProgress = progress
                case .failure(let error):
                    print("Failed to load user progress: \(error)")
                    // Continue with default progress
                }
            }
        }
    }
    
    /**
     * Save session and updated progress to storage
     */
    private func saveSessionAndProgress(_ session: BreathingSession) {
        storageService.saveSession(session) { result in
            if case .failure(let error) = result {
                print("Failed to save session: \(error)")
            }
        }
        
        storageService.saveUserProgress(userProgress) { result in
            if case .failure(let error) = result {
                print("Failed to save user progress: \(error)")
            }
        }
    }
    
    // MARK: - Session Type Availability
    
    /**
     * Get available session types based on user progress
     */
    var availableSessionTypes: [BreathingSession.SessionType] {
        var types: [BreathingSession.SessionType] = [.ascend]
        
        if userProgress.isUnlocked(.staminaPause) {
            types.append(.stamina)
        }
        
        if userProgress.isUnlocked(.summitChallenge) {
            types.append(.summit)
        }
        
        return types
    }
    
    /**
     * Check if user can access a specific session type
     */
    func canAccessSessionType(_ type: BreathingSession.SessionType) -> Bool {
        return availableSessionTypes.contains(type)
    }
    
    // MARK: - Formatted Display Values
    
    /// Current session progress for display
    var sessionProgress: String {
        guard let session = currentSession else { return "" }
        
        switch sessionState {
        case .breathing:
            return "\(timerService.formattedBreathingTime)s"
        case .holding:
            return timerService.formattedHoldDuration
        case .completed:
            return session.formattedHoldDuration
        default:
            return ""
        }
    }
    
    /// Completion message for current session
    var completionMessage: String {
        return currentSession?.completionMessage ?? "Well done!"
    }
    
    /// Current streak display
    var streakDisplay: String {
        if userProgress.currentStreak == 0 {
            return "Start your streak today"
        } else {
            return "🔥 \(userProgress.currentStreak) day\(userProgress.currentStreak == 1 ? "" : "s")"
        }
    }
    
    /// Personal best display
    var personalBestDisplay: String {
        if userProgress.personalBest == 0 {
            return "No personal best yet"
        } else {
            return "🏆 \(userProgress.formattedPersonalBest)"
        }
    }
    
    /// Check if current session is a new personal best
    var isNewPersonalBest: Bool {
        guard let session = currentSession, session.isCompleted else { return false }
        return session.holdDuration > userProgress.personalBest
    }
    
    // MARK: - App Lifecycle Management
    
    /**
     * Handle app entering background
     */
    func handleAppBackground() {
        timerService.handleAppBackground()
    }
    
    /**
     * Handle app returning to foreground
     */
    func handleAppForeground() {
        timerService.handleAppForeground()
    }
}

/**
 * StorageService: Handles local data persistence
 * 
 * Manages saving and loading of session data and user progress
 * using UserDefaults for MVP (can be upgraded to Core Data later).
 */
class StorageService {
    
    private let userProgressKey = "pause_user_progress"
    private let sessionsKey = "pause_sessions"
    
    // MARK: - User Progress Storage
    
    func saveUserProgress(_ progress: UserProgress, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(progress)
            UserDefaults.standard.set(data, forKey: userProgressKey)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func loadUserProgress(completion: @escaping (Result<UserProgress, Error>) -> Void) {
        guard let data = UserDefaults.standard.data(forKey: userProgressKey) else {
            // Return default progress for first-time users
            completion(.success(UserProgress()))
            return
        }
        
        do {
            let progress = try JSONDecoder().decode(UserProgress.self, from: data)
            completion(.success(progress))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Session Storage
    
    func saveSession(_ session: BreathingSession, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            var sessions = loadAllSessions()
            sessions.append(session)
            
            // Keep only last 100 sessions to manage storage
            if sessions.count > 100 {
                sessions = Array(sessions.suffix(100))
            }
            
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func loadAllSessions() -> [BreathingSession] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([BreathingSession].self, from: data)
        } catch {
            return []
        }
    }
}

// MARK: - Model Extensions for Codable Support

// MARK: - Data Persistence
// (Codable conformance moved to type declarations) 