import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var permissionsManager: PermissionsManager
    
    @Binding var isPresented: Bool
    @State private var selectedTab = 1
    @State private var showOnboarding = false
    @State private var forceOnboarding = false
    @Environment(\.colorScheme) var colorScheme
    
    private let tabs = [
        FloatingTabItem(id: 0, title: "Capture", icon: "camera.aperture", tag: 0),
        FloatingTabItem(id: 1, title: "Customize", icon: "slider.horizontal.3", tag: 1),
        FloatingTabItem(id: 2, title: "Info", icon: "info.circle", tag: 2)
    ]
    
    var body: some View {
        if showOnboarding {
            OnboardingView(cameraManager: cameraManager, permissionsManager: permissionsManager, showOnboarding: $showOnboarding, forceOnboarding: $forceOnboarding)
        } else {
            NavigationStack {
                ZStack {
                    if cameraManager.useBlurredBackground {
                        Color.clear
                            .background(.ultraThinMaterial)
                            .ignoresSafeArea()
                    }
                    
                    TabView(selection: $selectedTab) {
                        CaptureSettingsTab(cameraManager: cameraManager)
                            .tag(0)
                        
                        CustomizationSettingsTab(cameraManager: cameraManager)
                            .tag(1)
                        
                        InformationSettingsTab(cameraManager: cameraManager, permissionsManager: permissionsManager, showOnboarding: $showOnboarding)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    VStack {
                        Spacer()
                        FloatingTabBar(selectedTab: $selectedTab, cameraManager: cameraManager, tabs: tabs)
                            .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            isPresented = false
                        }
                        .foregroundColor(cameraManager.accentColor)
                    }
                }
            }
            .tint(cameraManager.accentColor)
        }
    }
}

struct CustomizationSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var expandedSection: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
            
                
                ModernSettingRow(
                    title: "Interface",
                    description: "Customize appearance of the app",
                    icon: "uiwindow.split.2x1",
                    iconColor: .green,
                    isExpanded: .init(
                        get: { expandedSection == "interface" },
                        set: { if $0 { expandedSection = "interface" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        Group {
                            
                            AccentColorPicker(selectedColor: $cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.maximizePreview,
                                    label: "Maximize Preview",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.useBlurredBackground,
                                    label: "Settings Contrast",
                                    accentColor: cameraManager.accentColor)
                                
                        }
                        .padding(.horizontal)
                    }
                }
                
                ModernSettingRow(
                    title: "Control Bars",
                    description: "Customize UI elements that control functionality",
                    icon: "dock.rectangle",
                    iconColor: .yellow,
                    isExpanded: .init(
                        get: { expandedSection == "bars" },
                        set: { if $0 { expandedSection = "bars" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        Group {
                            
                            GyroToggle(isOn: $cameraManager.showQuickSettings,
                                    label: "Quick Settings Bar",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.showZoomBar,
                                    label: "Zoom Bar",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.showFocusBar,
                                    label: "Focus Bar",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.showISOBar,
                                    label: "ISO Bar",
                                    accentColor: cameraManager.accentColor)
                            
                        }
                        .padding(.horizontal)
                    }
                }
                
                ModernSettingRow(
                    title: "Sounds and Haptics",
                    description: "Configure audio feedback and vibrations",
                    icon: "speaker.badge.exclamationmark",
                    iconColor: .pink,
                    isExpanded: .init(
                        get: { expandedSection == "sounds" },
                        set: { if $0 { expandedSection = "sounds" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        Group {
                            
                            GyroToggle(isOn: $cameraManager.playSounds,
                                    label: "Play Sound Effects",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.playHaptics,
                                    label: "Play Haptics",
                                    accentColor: cameraManager.accentColor)
                           
                            if cameraManager.playHaptics {
                                GyroPicker(
                                    selection: $cameraManager.rotationHaptics,
                                    items: RotationHaptic.allCases,
                                    title: "Rotation Haptics",
                                    accentColor: cameraManager.accentColor,
                                    displayValue: { $0.rawValue }
                                )
                                
                                GyroPicker(
                                    selection: $cameraManager.rotationHapticsStrength,
                                    items: RotationHapticStrength.allCases,
                                    title: "Strength",
                                    accentColor: cameraManager.accentColor,
                                    displayValue: { $0.rawValue }
                                )
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                }
                
                ModernSettingRow(
                    title: "Photo Library",
                    description: "Adjust photo library integration settings",
                    icon: "photo.stack",
                    iconColor: .cyan,
                    isExpanded: .init(
                        get: { expandedSection == "library" },
                        set: { if $0 { expandedSection = "library" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        Group {
                            
                            GyroToggle(isOn: $cameraManager.preserveAspectRatios,
                                    label: "Preserve Aspect Ratios",
                                    accentColor: cameraManager.accentColor)
                            
                            GyroToggle(isOn: $cameraManager.isProMode,
                                    label: "Show Metadata",
                                    accentColor: cameraManager.accentColor)
                            
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let description: String
    let iconColor: Color
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
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
                .fill(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct InformationSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var permissionsManager: PermissionsManager
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NavigationLink(destination: AboutView(cameraManager: cameraManager)) {
                    SettingsRow(
                        title: "About",
                        icon: "info.circle",
                        description: "Learn about GyroCam and its features",
                        iconColor: .indigo
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PrivacyPolicyView(cameraManager: cameraManager)) {
                    SettingsRow(
                        title: "Privacy Policy",
                        icon: "hand.raised.fill",
                        description: "Review our privacy practices",
                        iconColor: .red
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ChangelogView(cameraManager: cameraManager)) {
                    SettingsRow(
                        title: "Version History",
                        icon: "clock.badge.checkmark",
                        description: "See what's changed in recent updates",
                        iconColor: .gray
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: UpcomingFeaturesView(cameraManager: cameraManager)) {
                    SettingsRow(
                        title: "Upcoming Features",
                        icon: "road.lanes.curved.right",
                        description: "Preview what's coming next",
                        iconColor: .mint
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PermissionsPage(
                   permissionsManager: permissionsManager,
                   cameraManager: cameraManager,
                   message: "You can disable these permissions from settings at any time, or enable them from here at any time.",
                   isFromSettings: true
               )) {
                   SettingsRow(
                       title: "App Permissions",
                       icon: "lock.shield.fill",
                       description: "Manage camera, microphone, and other permissions",
                       iconColor: .teal
                   )
               }
               .buttonStyle(PlainButtonStyle())
                
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
    @Binding var isExpanded: Bool
    let content: () -> AnyView
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    init(
        title: String,
        description: String,
        icon: String,
        iconColor: Color,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
        self._isExpanded = isExpanded
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
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
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.white)
                        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            
            if isExpanded {
                content()
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct CaptureSettingsTab: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var expandedSection: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    private func lensDisplayValue(_ lens: LensType) -> String {
        switch lens {
        case .ultraWide: return "0.5x"
        case .wide: return "1x"
        case .telephoto: return "\(Int(getTelephotoZoomFactor()))x"
        case .frontWide: return "Front"
        }
    }
    
    func getTelephotoZoomFactor() -> Double {
        let device = UIDevice.modelName
        
        switch device {
        case "iPhone 16 Pro Max", "iPhone 16 Pro", "iPhone 15 Pro Max":
            return 5.0
        case "iPhone 15 Pro", "iPhone 14 Pro Max", "iPhone 14 Pro",
             "iPhone 13 Pro Max", "iPhone 13 Pro":
            return 3.0
        case "iPhone 12 Pro Max":
            return 2.5
        case "iPhone 12 Pro", "iPhone 11 Pro Max", "iPhone 11 Pro",
             "iPhone XS Max", "iPhone XS", "iPhone X",
             "iPhone 8 Plus", "iPhone 7 Plus":
            return 2.0
        default:
            return 1.0
        }
    }
    let videoFormats: [VideoFormat] = VideoFormat.allCases  // Break this out for clarity
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernSettingRow(
                    title: "Video Settings",
                    description: "Configure resolution, frame rate, and quality",
                    icon: "camera.aperture",
                    iconColor: .blue,
                    isExpanded: .init(
                        get: { expandedSection == "video" },
                        set: { if $0 { expandedSection = "video" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        Group {
                            
                            GyroPicker(
                                selection: $cameraManager.currentFormat,
                                items: VideoFormat.allCases,
                                title: "Resolution",
                                accentColor: cameraManager.accentColor,
                                displayValue: { $0.rawValue }
                            )
                            
                            GyroPicker(
                                    selection: $cameraManager.currentFPS,
                                    items: cameraManager.availableFrameRates,
                                    title: "Frame Rate",
                                    accentColor: cameraManager.accentColor,
                                    displayValue: { String($0.description.dropLast(3)) }
                                )
                            
                            GyroPicker(
                                selection: $cameraManager.currentLens,
                                items: cameraManager.availableLenses,
                                title: "Camera Lens",
                                accentColor: cameraManager.accentColor,
                                displayValue: { lensDisplayValue($0) }
                            )
                            
                            GyroToggle(isOn: $cameraManager.isHDREnabled,
                                    label: "HDR",
                                    accentColor: cameraManager.accentColor)
                            
                        }
                        .onChange(of: cameraManager.currentFormat) { _, _ in
                            cameraManager.configureSession()
                        }
                        .onChange(of: cameraManager.currentFPS) { _, _ in
                            cameraManager.configureSession()
                        }
                        .onChange(of: cameraManager.currentLens) { _, _ in
                            cameraManager.configureSession()
                        }
                        .onChange(of: cameraManager.isHDREnabled) { _, _ in
                            cameraManager.configureSession()
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(colorScheme == .dark ? Color.black.opacity(0.0) : Color.gray.opacity(0.00))
                    .cornerRadius(12)
                }
                
                ModernSettingRow(
                    title: "Advanced Controls",
                    description: "Adjust exposure, focus, and white balance",
                    icon: "camera.badge.ellipsis",
                    iconColor: .purple,
                    isExpanded: .init(
                        get: { expandedSection == "advanced" },
                        set: { if $0 { expandedSection = "advanced" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
            
                        GyroPicker(
                            selection: $cameraManager.stabilizeVideo,
                            items: StabilizationMode.allCases,
                            title: "Stabilization",
                            accentColor: cameraManager.accentColor,
                            displayValue: { $0.rawValue }
                        )
                        .onChange(of: cameraManager.stabilizeVideo) { _, _ in
                            cameraManager.configureSession()
                        }
                        
                        
                        GyroToggle(isOn: $cameraManager.autoFocus,
                                label: "Auto Focus",
                                accentColor: cameraManager.accentColor)

                        GyroToggle(isOn: $cameraManager.isFlashOn,
                                label: "Flash",
                                accentColor: cameraManager.accentColor)
                            .onChange(of: cameraManager.isFlashOn) { _, _ in
                                cameraManager.toggleFlash()
                            }
                        
                        GyroToggle(isOn: $cameraManager.autoExposure,
                                label: "Auto Exposure",
                                accentColor: cameraManager.accentColor)
                            .onChange(of: cameraManager.autoExposure) { _, _ in
                                cameraManager.configureSession()
                            }
                        
                        if !cameraManager.autoExposure {
                            TextField("ISO", value: $cameraManager.manualISO, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: cameraManager.manualISO) { _, newValue in
                                    if newValue < cameraManager.minISO {
                                        cameraManager.manualISO = cameraManager.minISO
                                    } else if newValue > cameraManager.maxISO {
                                        cameraManager.manualISO = cameraManager.maxISO
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(colorScheme == .dark ? Color.black.opacity(0.0) : Color.gray.opacity(0.00))
                    .cornerRadius(12)
                }
                
                ModernSettingRow(
                    title: "Output",
                    description: "Manage orientation and export settings",
                    icon: "list.and.film",
                    iconColor: .orange,
                    isExpanded: .init(
                        get: { expandedSection == "output" },
                        set: { if $0 { expandedSection = "output" } else { expandedSection = nil } }
                    )
                ) {
                    VStack(spacing: 16) {
                        
                        GyroPicker(
                            selection: $cameraManager.exportQuality,
                            items: ExportQuality.allCases,
                            title: "Export Quality",
                            accentColor: cameraManager.accentColor,
                            displayValue: { $0.rawValue }
                        )
                        
                        GyroToggle(isOn: $cameraManager.shouldStitchClips,
                                label: "Stitch Clips",
                                accentColor: cameraManager.accentColor)
                            .onChange(of: cameraManager.shouldStitchClips) { _, newValue in
                                if newValue {
                                    cameraManager.lockLandscape = true
                                }
                            }
                        
                        GyroToggle(isOn: $cameraManager.lockLandscape,
                                label: "Lock to Landscape Orientations",
                                accentColor: cameraManager.accentColor)
                            .disabled(cameraManager.shouldStitchClips)
                            .onChange(of: cameraManager.lockLandscape) { _, newValue in
                                if newValue {
                                    cameraManager.currentOrientation = "Landscape Left"
                                }
                            }
                    
                        GyroToggle(isOn: $cameraManager.allowRecordingWhileSaving,
                                label: "Allow Recording While Saving",
                                accentColor: cameraManager.accentColor)
                        
                        GyroToggle(isOn: $cameraManager.showQuickExport,
                                label: "Show Export Sheet Immediately After Recording",
                                accentColor: cameraManager.accentColor)
                        
                        GyroScroll(value: $cameraManager.exportSheetDuration, rangeStart: 0, rangeEnd: 100,
                                label: "Hide Export Sheet After Queue Finish (seconds)",
                                accentColor: cameraManager.accentColor)
                        
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(colorScheme == .dark ? Color.black.opacity(0.0) : Color.gray.opacity(0.00))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    cameraManager.resetToDefaults()
                }) {
                    Text("Reset to Defaults")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .padding(.top, 20)
            }
            .padding()
            Spacer(minLength: 100)
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
