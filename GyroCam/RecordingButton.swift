import SwiftUI

struct RecordingButton: View {
    @Binding var isRecording: Bool
    var action: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            action()
            triggerHaptic()
        }) {
            ZStack {
                // White outline circle
                Circle()
                    .stroke(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white, lineWidth: 5)
                    .frame(width: 70, height: 70)
                
                // Animated red shape
                RoundedRectangle(cornerRadius: isRecording ? 4 : 25)
                    .fill(Color.red)
                    .frame(width: isRecording ? 34 : 56, height: isRecording ? 34 : 56)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
                
                // Scaling pulse effect
                Circle()
                    .stroke(Color.red.opacity(0.4), lineWidth: 2)
                    .frame(width: animate ? 70 : 60, height: animate ? 70 : 60)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: animate)
            }
            .contentShape(Circle())
        }
        .buttonStyle(RecordingButtonStyle())
        .onAppear { animate = true }
        .onDisappear { animate = false }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct RecordingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
