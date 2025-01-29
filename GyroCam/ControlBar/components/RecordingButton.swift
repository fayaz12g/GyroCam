import SwiftUI

struct RecordingButton: View {
    @Binding var isRecording: Bool
    var action: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            // Haptic feedback before action
            let generator = UIImpactFeedbackGenerator(style: isRecording ? .heavy : .medium)
            generator.prepare()
            
            action() // Perform the recording action
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generator.impactOccurred()
            }
        }) {
            ZStack {
                // White outline circle
                Circle()
                    .stroke(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white, lineWidth: 5)
                    .frame(width: 70, height: 70)
                
                // Animated red shape
                RoundedRectangle(cornerRadius: isRecording ? 7 : 60)
                    .fill(Color.init(hex: "ff000d"))
                    .frame(width: isRecording ? 28 : 60, height: isRecording ? 28 : 60)
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

    
}

struct RecordingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
