import Foundation

/**
 * BreathingSession: Core data model representing a single breathing exercise session
 * 
 * Tracks the complete flow from breathing preparation through breath-hold to completion,
 * storing metrics that drive user progress and motivation.
 */
struct BreathingSession: Codable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var holdDuration: TimeInterval = 0 // Duration in seconds
    var sessionType: SessionType = .ascend
    var isCompleted: Bool = false
    
    enum SessionType: String, CaseIterable, Codable {
        case ascend = "Ascend Pause"
        case stamina = "Stamina Pause" // Unlocked at 3-day streak
        case summit = "Summit Challenge" // Unlocked at 7-day streak
        
        var description: String {
            switch self {
            case .ascend:
                return "Classic breathing preparation with breath-hold"
            case .stamina:
                return "Box breathing pattern with extended hold"
            case .summit:
                return "Three consecutive holds for maximum challenge"
            }
        }
        
        var preparationCycles: Int {
            switch self {
            case .ascend:
                return 3
            case .stamina:
                return 4
            case .summit:
                return 3
            }
        }
        
        var inhaleSeconds: Double {
            switch self {
            case .ascend:
                return 4.0
            case .stamina:
                return 4.0
            case .summit:
                return 4.0
            }
        }
        
        var exhaleSeconds: Double {
            switch self {
            case .ascend:
                return 6.0
            case .stamina:
                return 4.0
            case .summit:
                return 6.0
            }
        }
        
        var holdSeconds: Double? {
            switch self {
            case .ascend:
                return nil // No box breathing hold
            case .stamina:
                return 4.0 // Box breathing includes hold
            case .summit:
                return nil
            }
        }
    }
    
    init(sessionType: SessionType = .ascend) {
        self.startTime = Date()
        self.sessionType = sessionType
    }
    
    /// Complete the session with final hold duration
    mutating func complete(holdDuration: TimeInterval) {
        self.holdDuration = holdDuration
        self.endTime = Date()
        self.isCompleted = true
    }
    
    /// Total session duration from start to completion
    var totalDuration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Formatted hold duration for display (e.g., "01:23")
    var formattedHoldDuration: String {
        let minutes = Int(holdDuration) / 60
        let seconds = Int(holdDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Encouraging message based on hold duration
    var completionMessage: String {
        switch holdDuration {
        case 0..<30:
            return "Great start! Every breath counts."
        case 30..<60:
            return "Well done! You're building strength."
        case 60..<120:
            return "Excellent control! Keep it up."
        default:
            return "Outstanding! You're mastering the pause."
        }
    }
}

/**
 * UserProgress: Tracks overall user advancement and unlocks
 * 
 * Manages streak counting, personal bests, and feature unlocks
 * based on consistent daily practice.
 */
struct UserProgress: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalSessions: Int = 0
    var personalBest: TimeInterval = 0
    var lastSessionDate: Date?
    var unlockedFeatures: Set<UnlockedFeature> = []
    
    enum UnlockedFeature: String, CaseIterable, Codable {
        case staminaPause = "stamina_pause"
        case summitChallenge = "summit_challenge" 
        case customization = "customization"
        case advancedTracking = "advanced_tracking"
        case theVault = "the_vault"
        
        var requiredStreak: Int {
            switch self {
            case .staminaPause:
                return 3
            case .summitChallenge:
                return 7
            case .customization:
                return 14
            case .advancedTracking:
                return 30
            case .theVault:
                return 1 // Available after first session
            }
        }
        
        var title: String {
            switch self {
            case .staminaPause:
                return "Stamina Pause"
            case .summitChallenge:
                return "Summit Challenge"
            case .customization:
                return "Custom Breathing"
            case .advancedTracking:
                return "Progress Charts"
            case .theVault:
                return "The Vault"
            }
        }
        
        var description: String {
            switch self {
            case .staminaPause:
                return "Box breathing pattern for enhanced stamina"
            case .summitChallenge:
                return "Three consecutive holds to push your limits"
            case .customization:
                return "Adjust breathing timings to your preference"
            case .advancedTracking:
                return "Detailed progress graphs and analytics"
            case .theVault:
                return "Educational content and breathing techniques"
            }
        }
    }
    
    /// Add a completed session and update progress
    mutating func addSession(_ session: BreathingSession) {
        guard session.isCompleted else { return }
        
        totalSessions += 1
        
        // Update personal best
        if session.holdDuration > personalBest {
            personalBest = session.holdDuration
        }
        
        // Update streak
        updateStreak(for: session.startTime)
        
        // Check for new unlocks
        updateUnlockedFeatures()
    }
    
    /// Update streak based on session date
    private mutating func updateStreak(for sessionDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: sessionDate)
        
        if let lastDate = lastSessionDate {
            let lastSessionDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
            } else if daysBetween > 1 {
                // Gap in sessions - reset streak
                currentStreak = 1
            }
            // Same day sessions don't change streak
        } else {
            // First session ever
            currentStreak = 1
        }
        
        // Update longest streak if current exceeds it
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastSessionDate = sessionDate
    }
    
    /// Check and update feature unlocks based on current streak
    private mutating func updateUnlockedFeatures() {
        for feature in UnlockedFeature.allCases {
            if currentStreak >= feature.requiredStreak {
                unlockedFeatures.insert(feature)
            }
        }
    }
    
    /// Check if a specific feature is unlocked
    func isUnlocked(_ feature: UnlockedFeature) -> Bool {
        return unlockedFeatures.contains(feature)
    }
    
    /// Get features available to unlock with next milestone
    var nextUnlocks: [UnlockedFeature] {
        return UnlockedFeature.allCases.filter { feature in
            !isUnlocked(feature) && feature.requiredStreak <= currentStreak + 5
        }.sorted { $0.requiredStreak < $1.requiredStreak }
    }
    
    /// Formatted personal best for display
    var formattedPersonalBest: String {
        let minutes = Int(personalBest) / 60
        let seconds = Int(personalBest) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 