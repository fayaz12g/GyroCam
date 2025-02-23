import SwiftUI
import MediaPlayer

// Volume Button Observer class to handle volume button events
class VolumeButtonObserver: ObservableObject {
    private var volumeView: MPVolumeView?
    private var initialVolume: Float = 0.0
    var onVolumeButtonPress: (() -> Void)?
    
    init() {
        // Hide the system volume overlay
        volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
        
        // Store initial volume
        initialVolume = AVAudioSession.sharedInstance().outputVolume
        
        // Start observing volume changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVolumeChange),
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }
    
    @objc private func handleVolumeChange(_ notification: Notification) {
        // Reset volume to initial value to prevent actual volume changes
        try? AVAudioSession.sharedInstance().setActive(true)
        let volumeValue = AVAudioSession.sharedInstance().outputVolume
        
        if volumeValue != initialVolume {
            onVolumeButtonPress?()
            
            // Reset volume to initial value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                MPVolumeView.setVolume(self.initialVolume)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Extension to set volume programmatically
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            slider?.value = volume
        }
    }
}

struct RecordingButton: View {
    @Binding var isRecording: Bool
    @ObservedObject var cameraManager: CameraManager
    var action: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var volumeObserver = VolumeButtonObserver()
    
    var body: some View {
        Button(action: {
            triggerRecording()
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
                    .opacity(cameraManager.isSavingVideo ? 0 : 1)
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
                
                // Saving video animation
                if cameraManager.isSavingVideo {
                    SavingDotsView(color: cameraManager.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear {
                if isRecording {
                    animate = true
                }
                // Set up volume button handler
                volumeObserver.onVolumeButtonPress = {
                    triggerRecording()
                }
            }
            .onChange(of: isRecording) { _, newValue in
                if newValue {
                    withAnimation {
                        animate = true
                    }
                } else {
                    animate = false
                }
            }
            .animation(.easeInOut(duration: 0.3), value: cameraManager.isSavingVideo)
            .contentShape(Circle())
        }
        .buttonStyle(RecordingButtonStyle())
        .onAppear {
            animate = isRecording
        }
        .onDisappear {
            animate = false
        }
    }
    
    private func triggerRecording() {
        // Haptic feedback before action
        let generator = UIImpactFeedbackGenerator(style: isRecording ? .heavy : .medium)
        generator.prepare()
        
        action() // Perform the recording action
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
}


struct SavingDotsView: View {
    let color: Color
    @State private var rotation = 0.0
    
    var body: some View {
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
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
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
