import SwiftUI
import AVFoundation

// MARK: - Main Settings View
struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showOnboarding = false
    @State private var showReset = false
    
    var body: some View {
        if showOnboarding {
            OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding)
        } else {
            NavigationView {
                Form {
                    // Main Settings Sections
                    CaptureSettingsSection()
                    InterfaceSettingsSection()
                    PhotoLibrarySection()
                    AboutHelpSection()
                    MiscellaneousSection()
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { DoneButton() }
            }
        }
    }
    
    // MARK: - Subviews
    private func InterfaceSettingsSection() -> some View {
        Section(header: Text("Interface")) {
            NavigationLink(destination: InterfaceSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Customize Interface", icon: "uiwindow.split.2x1")
            }
        }
    }
    
    private func CaptureSettingsSection() -> some View {
        Section(header: Text("Capture")) {
            NavigationLink(destination: CaptureSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Video Settings", icon: "camera.aperture")
            }
            NavigationLink(destination: ExposureSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Exposure Controls", icon: "camera.badge.ellipsis")
            }
            NavigationLink(destination: OrientationStitchingView(cameraManager: cameraManager)) {
                SettingsRow(title: "Orientation & Stitching", icon: "rotate.right")
            }
        }
    }
    
    
    private func PhotoLibrarySection() -> some View {
        Section(header: Text("Photo Library")) {
            Toggle("Preserve Aspect Ratios", isOn: $cameraManager.preserveAspectRatios)
                .tint(cameraManager.accentColor)
            Toggle("Show Pro Mode", isOn: $cameraManager.isProMode)
                .tint(cameraManager.accentColor)
        }
    }
    
    private func AboutHelpSection() -> some View {
        Section(header: Text("GyroCam More Info")) {
            NavigationLink(destination: AboutView(cameraManager: cameraManager)) {
                SettingsRow(title: "About", icon: "info.circle")
            }
            NavigationLink(destination: PrivacyPolicyView(cameraManager: cameraManager)) {
                SettingsRow(title: "Privacy Policy", icon: "hand.raised.fill")
            }
            NavigationLink(destination: ChangelogView(cameraManager: cameraManager)) {
                SettingsRow(title: "Changelog", icon: "clock.badge.checkmark")
            }
            NavigationLink(destination: UpcomingFeaturesView(cameraManager: cameraManager)) {
                SettingsRow(title: "Roadmap", icon: "road.lanes.curved.right")
            }
            Button("Show Onboarding") { showOnboarding = true }
                .foregroundColor(cameraManager.accentColor)
        }
    }
    
    private func MiscellaneousSection() -> some View {
        Section {
            
            Button("Reset Defaults", action: resetDefaults)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
            
                .alert(isPresented: $showReset) {
                               Alert(
                                   title: Text("Settings Reset"),
                                   message: Text("Default settings restored."),
                                   dismissButton: .default(Text("OK"))
                               )
                       }
        }
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Components
    private func DoneButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") { presentationMode.wrappedValue.dismiss() }
                .foregroundColor(cameraManager.accentColor)
        }
    }
    
    private struct SettingsRow: View {
        let title: String
        let icon: String
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: icon)
            }
        }
    }
    
    private func resetDefaults() {
            // Reset default settings
            cameraManager.resetToDefaults()
            cameraManager.configureSession()
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")

            // Trigger the alert after resetting defaults
            showReset = true
        }


}

// MARK: - Submenu Views
struct InterfaceSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("UI Elements")) {
                Toggle("Quick Settings", isOn: $cameraManager.showQuickSettings)
                    .tint(cameraManager.accentColor)
                Toggle("Zoom Bar", isOn: $cameraManager.showZoomBar)
                    .tint(cameraManager.accentColor)
                Toggle("Focus Bar", isOn: $cameraManager.showFocusBar)
                    .tint(cameraManager.accentColor)
                Toggle("Auto Focus", isOn: $cameraManager.autoFocus)
                    .tint(cameraManager.accentColor)
                    .disabled(cameraManager.showFocusBar)
                Toggle("Maximize Preview", isOn: $cameraManager.maximizePreview)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.maximizePreview) { _, _ in
                        cameraManager.configureSession()
                    }
            }
            
            Section(header: Text("Badges")) {
                Toggle("Show Clip Badge", isOn: $cameraManager.showClipBadge)
                    .tint(cameraManager.accentColor)
                FeatureToggle(
                    title: "Recording Timer",
                    status: "Coming Soon",
                    isOn: $cameraManager.showRecordingTimer,
                    statusColor: .purple, cameraManager: cameraManager
                )
            }
            
            Section(header: Text("Orientation Badge")) {
                Toggle("Show", isOn: $cameraManager.showOrientationBadge)
                    .tint(cameraManager.accentColor)
                Toggle("Minimal Style", isOn: $cameraManager.minimalOrientationBadge)
                    .tint(cameraManager.accentColor)
                    .disabled(!cameraManager.showOrientationBadge)
            }
            
            Section(header: Text("Theme")) {
                HStack {
                    Text("Accent Color")
                    Spacer()
                    ColorPicker("", selection: $cameraManager.accentColor, supportsOpacity: false)
                        .labelsHidden()
                }
            }
        }
        .navigationTitle("Interface Settings")
    }
}

struct CaptureSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("Video Quality")) {
                Picker("Resolution", selection: $cameraManager.currentFormat) {
                    ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .onChange(of: cameraManager.currentFormat) { _, _ in
                    cameraManager.configureSession()
                }

                Picker("Frame Rate", selection: $cameraManager.currentFPS) {
                    ForEach(cameraManager.availableFrameRates) { fps in
                        Text(fps.description).tag(fps)
                    }
                }
                .onChange(of: cameraManager.currentFPS) { _, _ in
                    cameraManager.configureSession()
                    }
            }
            
            Section(header: Text("Advanced")) {
                Toggle("Enable HDR", isOn: $cameraManager.isHDREnabled)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.isHDREnabled) { _, _ in
                        cameraManager.configureSession()
                    }
                Picker("Camera Lens", selection: $cameraManager.currentLens) {
                    ForEach(cameraManager.availableLenses, id: \.self) { lens in
                        Text(lens.rawValue).tag(lens)
                    }
                }
                .onChange(of: cameraManager.currentLens) { _, _ in
                                            cameraManager.configureSession()
                }
            }
        }
        .navigationTitle("Capture Settings")
        .onChange(of: cameraManager.currentFormat) {
            cameraManager.configureSession()
        }
        .onChange(of: cameraManager.currentFPS) {
            cameraManager.configureSession()
        }
        .onChange(of: cameraManager.currentLens) {
            cameraManager.configureSession()
        }

    }
}

struct ExposureSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("Lighting")) {
                Toggle("Flash", isOn: $cameraManager.isFlashOn)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.isFlashOn) { _, _ in
                        cameraManager.toggleFlash()
                    }
                Toggle("Auto Exposure", isOn: $cameraManager.autoExposure)
            }
            
            Section(header: Text("Manual Controls")) {
                Picker("ISO", selection: $cameraManager.manualISO) {
                    ForEach(Array(stride(from: 50, through: 3200, by: 50)), id: \.self) { iso in
                        Text("\(iso)").tag(Float(iso))
                    }
                }
                .disabled(cameraManager.autoExposure)
                
//                Picker("Shutter Speed", selection: $cameraManager.manualShutterSpeed) {
//                    ForEach(CameraManager.ShutterSpeed.allCases, id: \.self) { speed in
//                        Text(speed.description).tag(speed.cmTime)
//                    }
//                }
//                .disabled(cameraManager.autoExposure)
            }
        }
        .navigationTitle("Exposure Settings")
    }
}

struct OrientationStitchingView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("Orientation")) {
                Toggle("Lock Landscape", isOn: $cameraManager.lockLandscape)
            }
            
            Section(header: Text("Video Processing")) {
                FeatureToggle(
                    title: "Auto Stitch",
                    status: "Beta",
                    isOn: $cameraManager.shouldStitchClips,
                    statusColor: .red, cameraManager: cameraManager
                )
            }
        }
        .navigationTitle("Orientation & Stitching")
    }
}

// MARK: - Reusable Components
struct FeatureToggle: View {
    let title: String
    let status: String
    @Binding var isOn: Bool
    let statusColor: Color
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(status)
                .badgeModifier(backgroundColor: statusColor)
            Toggle("", isOn: $isOn)
                .tint(cameraManager.accentColor)
        }
    }
}

struct BadgeModifier: ViewModifier {
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

extension View {
    func badgeModifier(backgroundColor: Color) -> some View {
        self.modifier(BadgeModifier(backgroundColor: backgroundColor))
    }
}


extension Color: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .blue
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .blue
            self = Color(color)
        } catch {
            self = .blue
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
