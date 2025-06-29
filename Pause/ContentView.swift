import SwiftUI

/**
 * ContentView: Main entry point for the Pause breathing app
 * 
 * Now integrated with SessionViewModel to orchestrate the complete
 * breathing exercise flow from main screen through completion.
 * 
 * DESIGN DECISIONS:
 * - Single button approach eliminates cognitive load
 * - Pulsating animation suggests breathing rhythm
 * - Muted color palette promotes calm focus
 * - State-driven UI that adapts to session progress
 */
struct ContentView: View {
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Serene background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.85, green: 0.90, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // State-driven view content
            Group {
                switch sessionViewModel.sessionState {
                case .ready:
                    MainScreenView(sessionViewModel: sessionViewModel, isAnimating: $isAnimating)
                case .breathing:
                    BreathingView(sessionViewModel: sessionViewModel)
                case .transitioning:
                    TransitionView(sessionViewModel: sessionViewModel)
                case .holding:
                    HoldView(sessionViewModel: sessionViewModel)
                case .completed:
                    ResultsView(sessionViewModel: sessionViewModel)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            sessionViewModel.handleAppBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            sessionViewModel.handleAppForeground()
        }
    }
}

/**
 * Preview provider for Xcode canvas development
 * Shows the main interface in both light and dark modes
 */
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 