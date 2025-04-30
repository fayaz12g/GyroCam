import SwiftUI

struct FocusBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var lastFocusPosition: Float = 0.5
    
    // Timer for focus updates
    @State private var focusUpdateTimer: Timer? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let maxFocus: CGFloat = 1.0
            let minFocus: CGFloat = 0.0
            let barWidth = geometry.size.width - 40
            let normalized = (CGFloat(cameraManager.focusValue) - minFocus) / (maxFocus - minFocus)
            let position = normalized * barWidth
            
            ZStack(alignment: .leading) {
                // Background Bar
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.7))
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            .padding(.horizontal, 20)
                        )
                
                // Outer glass effect with blur
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(cameraManager.autoFocus ? cameraManager.accentColor : Color.white.opacity(0.25),
                                   lineWidth: cameraManager.autoFocus ? 2 : 0.5)
                    )
                    .shadow(color: cameraManager.autoFocus ? cameraManager.accentColor.opacity(0.6) : Color.black.opacity(0.1),
                           radius: cameraManager.autoFocus ? 4 : 3,
                           x: 0, y: 0)
                    .overlay(
                        VStack(alignment: .center, spacing: 2) {
                            Text(cameraManager.autoFocus ? "AUTO" : "\(String(format: "%.1f", (cameraManager.focusValue * 10)))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(cameraManager.autoFocus ? cameraManager.accentColor : .primary)
                            Text("FOCUS")
                                .font(.system(size: 6, weight: .bold))
                        }
                    )
                    .rotationEffect(cameraManager.rotationAngle)
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.focusValue)
                    .shadow(radius: 3)
                    .offset(x: position)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                // Toggle autofocus in the camera manager
                                cameraManager.autoFocus.toggle()
                                
                                if cameraManager.autoFocus {
                                    // Save current focus position before enabling autofocus
                                    lastFocusPosition = cameraManager.focusValue
                                    
                                    // Enable continuous autofocus
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.focusMode = .continuousAutoFocus
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error setting continuous autofocus: \(error)")
                                        }
                                    }
                                } else {
                                    // Disable continuous autofocus and switch to manual
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.focusMode = .locked
                                            device.setFocusModeLocked(lensPosition: cameraManager.focusValue) { _ in }
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error locking focus: \(error)")
                                        }
                                    }
                                }
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !cameraManager.autoFocus {
                                    // Calculate new focus based on drag position
                                    let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                    let newFocus = minFocus + (dragPosition / barWidth) * (maxFocus - minFocus)
                                    
                                    // Update cameraManager's focus level
                                    cameraManager.focusValue = Float(newFocus)
                                    
                                    // Update the actual focus on the capture device
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.setFocusModeLocked(lensPosition: Float(newFocus)) { _ in }
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error adjusting focus: \(error)")
                                        }
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 40)
        .onAppear {
            // Start the focus observation timer
            startFocusUpdateTimer()
        }
        .onDisappear {
            // Clean up timer when view disappears
            focusUpdateTimer?.invalidate()
            focusUpdateTimer = nil
        }
        // Watch for changes to autofocus setting
        .onChange(of: cameraManager.autoFocus) { _, newValue in
            // Restart timer when autofocus changes
            startFocusUpdateTimer()
        }
    }
    
    // Start the timer that updates focus position when autofocus is on
    private func startFocusUpdateTimer() {
        // Invalidate existing timer if any
        focusUpdateTimer?.invalidate()
        
        // Create a new timer that updates more frequently during autofocus
        focusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            DispatchQueue.main.async {
                if cameraManager.autoFocus {
                    // Update UI with the current lens position from the camera
                    if let currentLensPosition = cameraManager.captureDevice?.lensPosition {
                        // This updates the focusValue which will move the indicator
                        cameraManager.focusValue = currentLensPosition
                    }
                }
            }
        }
    }
}
