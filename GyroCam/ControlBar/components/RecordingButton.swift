import SwiftUI

struct RecordingButton: View {
    @Binding var isRecording: Bool
    @ObservedObject var cameraManager: CameraManager
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
                
                // Animated red shape (square when recording, circle when not)
                RoundedRectangle(cornerRadius: isRecording ? 7 : 60)
                    .fill(cameraManager.accentColor)
                    .frame(width: isRecording ? 28 : 60, height: isRecording ? 28 : 60)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
                
                if isRecording {
                    // Scaling pulse effect - expanding from the center
                    Circle()
                        .stroke(cameraManager.accentColor.opacity(0.4), lineWidth: 2)
                        .frame(width: animate ? 35 : 20, height: animate ? 35 : 20) // Start from the square and expand outward
                        .scaleEffect(animate ? 2.5 : 1) // Adjust scale to create a pulse effect from the center
                        .opacity(animate ? 0 : 1)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false), value: animate)
                }
            }
            .onAppear {
                // Ensure animation starts if already recording onAppear
                if isRecording {
                    animate = true
                }
            }
            .onChange(of: isRecording) { newValue in
                // Toggle animation based on isRecording state
                if newValue {
                    withAnimation {
                        animate = true
                    }
                } else {
                    animate = false
                }
            }
            .contentShape(Circle())
        }
        .buttonStyle(RecordingButtonStyle())
        .onAppear {
            // Initialize animate to true on first appearance
            animate = isRecording
        }
        .onDisappear {
            // Stop the animation when the view disappears
            animate = false
        }
    }

    
}

struct RecordingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

