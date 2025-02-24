import SwiftUI
import AVFoundation

// MARK: - Main Settings View
struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var showOnboarding = false
    @State private var forceOnboarding = false
    
    var body: some View {
        if showOnboarding {
            OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding, forceOnboarding: $forceOnboarding)
        } else {
            NavigationStack {
                Form {
                    // Main Settings Sections
                    CaptureSettingsSection()
                    InterfaceSettingsSection()
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
        Section(header: Text("Customization")) {
            NavigationLink(destination: InterfaceSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Interface", icon: "uiwindow.split.2x1")
            }
            NavigationLink(destination: SoundsAndHapticsSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Sounds and Haptics", icon: "speaker.badge.exclamationmark")
            }
            NavigationLink(destination: PhotoLibrarySettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Photo Library", icon: "photo.stack")
            }
        }
    }
    
    private func CaptureSettingsSection() -> some View {
        Section(header: Text("Capture")) {
            NavigationLink(destination: CaptureSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Video Settings", icon: "camera.aperture")
            }
            NavigationLink(destination: ExposureSettingsView(cameraManager: cameraManager)) {
                SettingsRow(title: "Advanced Controls", icon: "camera.badge.ellipsis")
            }
            NavigationLink(destination: OrientationStitchingView(cameraManager: cameraManager)) {
                SettingsRow(title: "Output", icon: "list.and.film")
            }
        }
    }
    
    private func AboutHelpSection() -> some View {
        Section(header: Text("Information")) {
            NavigationLink(destination: AboutView(cameraManager: cameraManager)) {
                SettingsRow(title: "About", icon: "info.circle")
            }
            NavigationLink(destination: PrivacyPolicyView(cameraManager: cameraManager)) {
                SettingsRow(title: "Privacy Policy", icon: "hand.raised.fill")
            }
            NavigationLink(destination: ChangelogView(cameraManager: cameraManager)) {
                SettingsRow(title: "Version History", icon: "clock.badge.checkmark")
            }
            NavigationLink(destination: UpcomingFeaturesView(cameraManager: cameraManager)) {
                SettingsRow(title: "Upcoming Features", icon: "road.lanes.curved.right")
            }
            VStack {
                Spacer() // Push the button towards the center vertically
                Button("Show Onboarding") {
                    showOnboarding = true
                }
                .foregroundColor(cameraManager.accentColor)
                .frame(maxWidth: .infinity) // Take full width
                .multilineTextAlignment(.center) // Align text in case of multiline
                Spacer() // Push the button towards the center vertically
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func MiscellaneousSection() -> some View {
        Section {
            
            Button("Reset Defaults", action: resetDefaults)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }
    
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
        }


}

// MARK: - Submenu Views
struct InterfaceSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                HStack {
                    Text("Accent Color")
                    Spacer()
                    ColorPicker("", selection: $cameraManager.accentColor, supportsOpacity: false)
                        .labelsHidden()
                }
            }
            
            Section(header: Text("UI Elements")) {
                Toggle("Quick Settings", isOn: $cameraManager.showQuickSettings)
                    .tint(cameraManager.accentColor)
                Toggle("Zoom Bar", isOn: $cameraManager.showZoomBar)
                    .tint(cameraManager.accentColor)
                Toggle("Focus Bar", isOn: $cameraManager.showFocusBar)
                    .tint(cameraManager.accentColor)
                Toggle("Maximize Preview", isOn: $cameraManager.maximizePreview)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.maximizePreview) { _, _ in
                        cameraManager.configureSession()
                    }
            }
            
            Section(header: Text("Badges")) {
                Toggle("Clip Badge", isOn: $cameraManager.showClipBadge)
                    .tint(cameraManager.accentColor)
                Toggle("Orientation Badge", isOn: $cameraManager.showOrientationBadge)
                    .tint(cameraManager.accentColor)
                Toggle("Minimal Orientation Badge", isOn: $cameraManager.minimalOrientationBadge)
                    .tint(cameraManager.accentColor)
                    .disabled(!cameraManager.showOrientationBadge)
                FeatureToggle(
                    title: "Recording Timer",
                    status: "Coming Soon",
                    isOn: $cameraManager.showRecordingTimer,
                    statusColor: .purple, cameraManager: cameraManager
                )
                
            
            }
            
        }
        .navigationTitle("Interface")
    }
}

struct PhotoLibrarySettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    var body: some View {
        Form {
            Section(header: Text("Photo Library")) {
                Toggle("Preserve Aspect Ratios", isOn: $cameraManager.preserveAspectRatios)
                    .tint(cameraManager.accentColor)
                Toggle("Show Pro Mode", isOn: $cameraManager.isProMode)
                    .tint(cameraManager.accentColor)
            }
        }
        .navigationTitle("Photo Library")
    }
}

struct SoundsAndHapticsSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    var body: some View {
        Form {
            Section(header: Text("Sounds")) {
                Toggle("Play Sound Effects", isOn: $cameraManager.playSounds)
                    .tint(cameraManager.accentColor)
            }
            Section(header: Text("Haptics")) {
                Toggle("Play Haptics", isOn: $cameraManager.playHaptics)
                    .tint(cameraManager.accentColor)
            }
                
        }
        .navigationTitle("Sounds & Haptics")
    }
}

    
struct CaptureSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: Text("Video Quality")) {
                Picker("Resolution", selection: $cameraManager.currentFormat) {
                    ForEach(VideoFormat.allCases, id: \.self) { format in
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
        .navigationTitle("Video Settings")
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
            Section(header: Text("Focus")) {
                Toggle("Auto Focus", isOn: $cameraManager.autoFocus)
                    .tint(cameraManager.accentColor)
                    .disabled(cameraManager.showFocusBar)
            }
            
            Section(header: Text("Lighting")) {
                Toggle("Flash", isOn: $cameraManager.isFlashOn)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.isFlashOn) { _, _ in
                        cameraManager.toggleFlash()
                    }
                Toggle("Auto Exposure", isOn: $cameraManager.autoExposure)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.autoExposure) { _, _ in
                        cameraManager.configureSession()
                    }
            }
            
            
            Section(header: Text("Stabilization Mode")) {
                Picker("Stabilization Mode", selection: $cameraManager.stabilizeVideo) {
                    ForEach(StabilizationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Optional: Use segmented control for a nice UI
                .tint(cameraManager.accentColor)
                .onChange(of: cameraManager.stabilizeVideo) { _, _ in
                    cameraManager.configureSession()
                }
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
        .navigationTitle("Advanced Controls")
    }
}

struct OrientationStitchingView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            
            Section(header: Text("Stitching")) {
                Toggle("Stitch Clips", isOn: $cameraManager.shouldStitchClips)
                    .tint(cameraManager.accentColor)
                    .onChange(of: cameraManager.shouldStitchClips) { _, newValue in
                        if newValue {
                            cameraManager.lockLandscape = true
                        }
                    }
                
            }
            Section(header: Text("Orientation")) {
                Toggle("Lock Landscape", isOn: $cameraManager.lockLandscape)
                    .tint(cameraManager.accentColor)
                    .disabled(cameraManager.shouldStitchClips)
                    .onChange(of: cameraManager.lockLandscape) { _, newValue in
                        if newValue {
                            cameraManager.currentOrientation = "Landscape Left"
                        }
                    }
            }
        }
        .navigationTitle("Output")
    }
}

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
                .disabled(status == "Coming Soon")
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
