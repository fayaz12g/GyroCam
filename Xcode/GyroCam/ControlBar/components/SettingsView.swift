import SwiftUI
import AVFoundation

// MARK: - Main Settings View
struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var isPresented: Bool
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    @State private var forceOnboarding = false
    
    var body: some View {
        if showOnboarding {
            OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding, forceOnboarding: $forceOnboarding)
        } else {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    CaptureSettingsTab(cameraManager: cameraManager)
                        .tag(0)
                        .tabItem {
                            Image(systemName: "camera.aperture")
                            Text("Capture")
                        }
                    
                    CustomizationSettingsTab(cameraManager: cameraManager)
                        .tag(1)
                        .tabItem {
                            Image(systemName: "slider.horizontal.3")
                            Text("Customize")
                        }
                    
                    InformationSettingsTab(cameraManager: cameraManager, showOnboarding: $showOnboarding)
                        .tag(2)
                        .tabItem {
                            Image(systemName: "info.circle")
                            Text("Info")
                        }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                        .foregroundColor(cameraManager.accentColor)
                    }
                }
            }
            .tint(cameraManager.accentColor)
            .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct CaptureSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernSettingRow(
                    title: "Video Settings",
                    description: "Configure resolution, frame rate, and quality",
                    icon: "camera.aperture",
                    iconColor: .blue,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Advanced Controls",
                    description: "Adjust exposure, focus, and white balance",
                    icon: "camera.badge.ellipsis",
                    iconColor: .purple,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Output",
                    description: "Manage orientation and export settings",
                    icon: "list.and.film",
                    iconColor: .orange,
                    action: { /* Navigation */ }
                )
            }
            .padding()
        }
    }
}

struct CustomizationSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernSettingRow(
                    title: "Interface",
                    description: "Customize appearance and UI elements",
                    icon: "uiwindow.split.2x1",
                    iconColor: .green,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Sounds and Haptics",
                    description: "Configure audio feedback and vibrations",
                    icon: "speaker.badge.exclamationmark",
                    iconColor: .pink,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Photo Library",
                    description: "Adjust photo library integration settings",
                    icon: "photo.stack",
                    iconColor: .cyan,
                    action: { /* Navigation */ }
                )
            }
            .padding()
        }
    }
}

struct InformationSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernSettingRow(
                    title: "About",
                    description: "Learn about GyroCam and its features",
                    icon: "info.circle",
                    iconColor: .indigo,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Privacy Policy",
                    description: "Review our privacy practices",
                    icon: "hand.raised.fill",
                    iconColor: .red,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Version History",
                    description: "See what's changed in recent updates",
                    icon: "clock.badge.checkmark",
                    iconColor: .gray,
                    action: { /* Navigation */ }
                )
                
                ModernSettingRow(
                    title: "Upcoming Features",
                    description: "Preview what's coming next",
                    icon: "road.lanes.curved.right",
                    iconColor: .mint,
                    action: { /* Navigation */ }
                )
                
                Button("Show Onboarding") {
                    showOnboarding = true
                }
                .foregroundColor(cameraManager.accentColor)
                .padding()
            }
            .padding()
        }
    }
}

struct ModernSettingRow: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                // Icon in colored circle
                Circle()
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    )
                
                // Title and description
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
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
                Toggle("Show Recording Duration Badge", isOn: $cameraManager.showDurationBadge)
                    .tint(cameraManager.accentColor)
                FeatureToggle(
                    title: "Secret Settings",
                    status: "Coming Soon",
                    isOn: $cameraManager.showDurationBadge,
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
            
            if !cameraManager.autoExposure {
                Section(header: Text("ISO")) {
                    TextField("ISO", value: $cameraManager.manualISO, format: .number)
                        .keyboardType(.numberPad)
                        .onChange(of: cameraManager.manualISO) {_, newValue in
                            if newValue < cameraManager.minISO {
                                cameraManager.manualISO = cameraManager.minISO
                            } else if newValue > cameraManager.maxISO {
                                cameraManager.manualISO = cameraManager.maxISO
                            }
                        }
                        .disabled(cameraManager.autoExposure)
                    
                    Toggle("ISO Bar", isOn: $cameraManager.showISOBar)
                        .tint(cameraManager.accentColor)
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
            Section(header: Text("Processing")) {
                Picker("Export Quality", selection: $cameraManager.exportQuality) {
                    ForEach(ExportQuality.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .tint(cameraManager.accentColor)
                
                Toggle("Allow Recording While Saving", isOn: $cameraManager.allowRecordingWhileSaving)
                    .tint(cameraManager.accentColor)
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
