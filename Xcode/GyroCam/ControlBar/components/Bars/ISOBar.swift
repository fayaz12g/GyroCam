import SwiftUI

struct ISOBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var lastISOValue: Float = 0
    
    // Timer for ISO updates in auto mode
    @State private var isoUpdateTimer: Timer? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width - 40
            let normalized = (cameraManager.manualISO - cameraManager.minISO) / (cameraManager.maxISO - cameraManager.minISO)
            let position = CGFloat(normalized) * barWidth
                
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundColor(colorScheme == .dark ? .gray.opacity(0.5) : .white.opacity(0.7))
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
                            .stroke(cameraManager.autoExposure ? cameraManager.accentColor : Color.white.opacity(0.25),
                                   lineWidth: cameraManager.autoExposure ? 2 : 0.5)
                    )
                    .shadow(color: cameraManager.autoExposure ? cameraManager.accentColor.opacity(0.6) : Color.black.opacity(0.1),
                           radius: cameraManager.autoExposure ? 4 : 3,
                           x: 0, y: 0)
                    .overlay(
                        VStack(alignment: .center, spacing: 2) {
                            Text(cameraManager.autoExposure ? "AUTO" : "\(Int(cameraManager.manualISO))")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(cameraManager.autoExposure ? cameraManager.accentColor : .primary)
                            Text("ISO")
                                .font(.system(size: 6, weight: .bold))
                        }
                    )
                    .rotationEffect(cameraManager.rotationAngle)
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.manualISO)
                    .shadow(radius: 3)
                    .offset(x: position)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                // Toggle autoExposure in the camera manager
                                cameraManager.autoExposure.toggle()
                                
                                if cameraManager.autoExposure {
                                    // Save current ISO value before enabling auto
                                    lastISOValue = cameraManager.manualISO
                                    
                                    // Configure camera for auto exposure
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.exposureMode = .continuousAutoExposure
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error setting continuous auto exposure: \(error)")
                                        }
                                    }
                                } else {
                                    // Disable auto exposure and switch to manual
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            let currentDuration = device.exposureDuration
                                            device.setExposureModeCustom(duration: currentDuration, iso: cameraManager.manualISO)
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error setting manual exposure: \(error)")
                                        }
                                    }
                                }
                                
                                // Apply changes through camera manager
                                cameraManager.configureExposureMode()
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !cameraManager.autoExposure {
                                    // Calculate new ISO based on drag position
                                    let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                    let newISO = cameraManager.minISO + (Float(dragPosition / barWidth) * (cameraManager.maxISO - cameraManager.minISO))
                                    
                                    // Update camera manager's ISO level
                                    cameraManager.manualISO = newISO
                                    
                                    // Apply the ISO change
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            let currentDuration = device.exposureDuration
                                            device.setExposureModeCustom(duration: currentDuration, iso: newISO)
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error adjusting ISO: \(error)")
                                        }
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 40)
        .onAppear {
            // Start the ISO observation timer
            startISOUpdateTimer()
        }
        .onDisappear {
            // Clean up timer when view disappears
            isoUpdateTimer?.invalidate()
            isoUpdateTimer = nil
        }
        // Watch for changes to autoExposure setting
        .onChange(of: cameraManager.autoExposure) { _, newValue in
            // Restart timer when autoExposure changes
            startISOUpdateTimer()
        }
    }
    
    // Start the timer that updates ISO position when autoExposure is on
    private func startISOUpdateTimer() {
        // Invalidate existing timer if any
        isoUpdateTimer?.invalidate()
        
        // Create a new timer that updates more frequently during autoExposure
        isoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            DispatchQueue.main.async {
                if cameraManager.autoExposure {
                    if let device = cameraManager.captureDevice {
                        let currentISO = device.iso
                        cameraManager.manualISO = max(cameraManager.minISO, min(currentISO, cameraManager.maxISO))
                    }
                }
            }
        }
    }

}
