import SwiftUI

/**
 * ContentView: Main entry point for the Pause breathing app
 * 
 * RATIONALE: Implements the core concept of a serene, minimal interface
 * with a pulsating circle and single call-to-action button. This provides
 * the foundation for the complete breathing exercise flow.
 * 
 * DESIGN DECISIONS:
 * - Single button approach eliminates cognitive load
 * - Pulsating animation suggests breathing rhythm
 * - Muted color palette promotes calm focus
 * - Large touch target optimized for ease of use during relaxation
 */
struct ContentView: View {
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
            
            VStack(spacing: 60) {
                // App title
                Text("Pause")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
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
                .onAppear {
                    isAnimating = true
                }
                
                Spacer()
                
                // Main call-to-action button
                Button(action: {
                    // TODO: Navigate to breathing preparation view
                    // This will be implemented in Task 2
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
                .padding(.bottom, 80)
                
                // Subtle hint text
                Text("Take a moment to breathe")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
                    .padding(.bottom, 40)
            }
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