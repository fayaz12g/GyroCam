import SwiftUI
import AVFAudio

struct RecordingButton: View {
    @Binding var isRecording: Bool
    @ObservedObject var cameraManager: CameraManager
    var action: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            action()
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
                    .opacity(shouldShowSavingDots ? 0 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
                    .animation(.easeInOut(duration: 0.3), value: cameraManager.isSavingVideo)
                
                if isRecording {
                    // Scaling pulse effect - expanding from the center
                    Circle()
                        .stroke(cameraManager.accentColor.opacity(0.4), lineWidth: 2)
                        .frame(width: animate ? 35 : 20, height: animate ? 35 : 20)
                        .scaleEffect(animate ? 2.5 : 1)
                        .opacity(animate ? 0 : 1)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false), value: animate)
                }
                
                // Saving video animation (only show if not allowing recording while saving)
                if shouldShowSavingDots {
                    SavingDotsView(cameraManager: cameraManager, color: cameraManager.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear {
                // Ensure animation starts if already recording onAppear
                if isRecording {
                    animate = true
                }
            }
            .onChange(of: isRecording) { _, newValue in
                // Toggle animation based on isRecording state
                if newValue {
                    withAnimation {
                        animate = true
                    }
                } else {
                    animate = false
                }
            }
            .animation(.easeInOut(duration: 0.3), value: cameraManager.isSavingVideo) // Animate the entire ZStack
            .contentShape(Circle())
        }
        .buttonStyle(RecordingButtonStyle())
        .disabled(isButtonDisabled)
        .onAppear {
            // Initialize animate to true on first appearance
            animate = isRecording
        }
        .onDisappear {
            // Stop the animation when the view disappears
            animate = false
        }
    }
    
    private var shouldShowSavingDots: Bool {
        cameraManager.isSavingVideo && !cameraManager.allowRecordingWhileSaving
    }
    
    private var isButtonDisabled: Bool {
        cameraManager.isSavingVideo && !cameraManager.allowRecordingWhileSaving
    }
}

struct SavingDotsView: View {
    @ObservedObject var cameraManager: CameraManager
    let color: Color
    @State private var rotation = 0.0
    
    // Feedback and timers
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .soft)
    @State private var feedbackTimer: Timer?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let dotCount = 8
                let dotSize = size * 0.1
                let radius = size * 0.4
                
                ForEach(0..<dotCount, id: \.self) { index in
                    let angle = (2 * .pi * Double(index)) / Double(dotCount)
                    let xOffset = cos(angle) * radius
                    let yOffset = sin(angle) * radius
                    
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .offset(x: xOffset + (size/2 - dotSize/2),
                                y: yOffset + (size/2 - dotSize/2))
                        .opacity(1.0 - Double(index) * 0.1)
                }
            }
            .frame(width: 70, height: 70)
            .rotationEffect(.degrees(rotation))
            
            if cameraManager.isExporting {
                Text("\(Int(cameraManager.exportProgress * 100))%")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .monospacedDigit()
            }
        }
        .frame(width: 70, height: 70)
        .onAppear {
            // Rotation animation
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Haptic setup
            impactFeedback.prepare()
            feedbackTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                if cameraManager.playHaptics {
                    impactFeedback.impactOccurred(intensity: 1.0)
                }
                if cameraManager.playSounds {
                    AudioServicesPlaySystemSound(1117)
                }
            }
        }
        .onDisappear {
            feedbackTimer?.invalidate()
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
