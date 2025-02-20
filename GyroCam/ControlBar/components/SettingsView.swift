import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showOnboarding = false
    
    var body: some View {
        if showOnboarding {
            OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding)
        } else {
            NavigationView {
                Form {
                    Section(header: Text("User Interface")) {
                        Toggle("Zoom Bar", isOn: $cameraManager.showZoomBar)
                            .tint(cameraManager.accentColor)
                        
                        Toggle("Focus Bar", isOn: $cameraManager.showFocusBar)
                            .tint(cameraManager.accentColor)
                        
                        Toggle("Auto Focus", isOn: $cameraManager.autoFocus)
                            .tint(cameraManager.accentColor)
                            .disabled(cameraManager.showFocusBar)
                        
                        Toggle("Maximize Preview", isOn: $cameraManager.maximizePreview)
                            .tint(cameraManager.accentColor)
                        
                        Toggle("Show Orientation Badge", isOn: $cameraManager.showOrientationBadge)
                            .tint(cameraManager.accentColor)
                        
                        
                        Toggle("Minimal Orientation Badge", isOn: $cameraManager.minimalOrientationBadge)
                            .tint(cameraManager.accentColor)
                            .disabled(!cameraManager.showOrientationBadge)
                        
                        Toggle("Show Clip Badge", isOn: $cameraManager.showClipBadge)
                            .tint(cameraManager.accentColor)
                        
                        HStack {
                            Text("Show Recording Timer")
                            Spacer()
                            Text("Coming Soon")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple)
                                .cornerRadius(10)
                            Toggle("", isOn: $cameraManager.showRecordingTimer)
                                .tint(cameraManager.accentColor)
                                .disabled(true)
                        }
                        
                        
                        
                        HStack {
                            Text("App Theme")
                                .foregroundColor(.primary)
                            Spacer()
                            ColorPicker("Select Theme Color", selection: $cameraManager.accentColor, supportsOpacity: false)
                                .labelsHidden()
                                .frame(width: 44, height: 44)
                                .padding(.trailing, -8)
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                    }
                    
                    Section(header: Text("Photo Library")) {
                        HStack {
                            Toggle("Preserve Aspect Ratios", isOn: $cameraManager.preserveAspectRatios)
                                .tint(cameraManager.accentColor)
                        }
                        
                        Toggle("Show Pro Mode", isOn: $cameraManager.isProMode)
                            .tint(cameraManager.accentColor)
                        
                    }
                    
                    
                    Section(header: Text("Camera Options")) {
                        
                        Picker("Resolution", selection: $cameraManager.currentFormat) {
                            ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .onChange(of: cameraManager.currentFormat) { _, _ in
                            cameraManager.configureSession()
                        }
                        
                        Toggle("Enable HDR", isOn: $cameraManager.isHDREnabled)
                            .tint(cameraManager.accentColor)
                            .onChange(of: cameraManager.isHDREnabled) { _, _ in
                                cameraManager.configureSession()
                            }
                        
                        Picker("Camera Type", selection: $cameraManager.currentLens) {
                            ForEach(cameraManager.availableLenses, id: \.self) { lens in
                                Text(lens.rawValue).tag(lens)
                            }
                        }
                        .onChange(of: cameraManager.currentLens) { _, _ in
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
                        
                        Toggle("Lock Orientation to Landscape", isOn: $cameraManager.lockLandscape)
                            .tint(cameraManager.accentColor)
                        
                        HStack {
                            Text("Auto Stitch")
                            Spacer()
                            Text("Beta")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(10)
                            Toggle("", isOn: $cameraManager.shouldStitchClips)
                                .tint(cameraManager.accentColor)
                        }
                        
                        
                    }
                    
                    Section(header: Text("miscellaneous")) {
                        NavigationLink {
                            ChangelogView(cameraManager: cameraManager)
                        } label: {
                            HStack {
                                Text("Changelog")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "clock.badge.checkmark")
                                    .tint(cameraManager.accentColor)
                            }
                        }
                        
                        NavigationLink {
                            UpcomingFeaturesView(cameraManager: cameraManager)
                        } label: {
                            HStack {
                                Text("Upcoming Features")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "road.lanes.curved.right")
                                    .tint(cameraManager.accentColor)
                            }
                        }
                        
                        NavigationLink {
                            PrivacyPolicyView(cameraManager: cameraManager)
                        } label: {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .tint(cameraManager.accentColor)
                            }
                        }
                        Button(action: doShowOnboarding) {
                            Text("Show Onboarding")
                                .foregroundColor(cameraManager.accentColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                    }
                    
                    Section {
                        Button(action: resetDefaults) {
                            Text("Reset Defaults")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .foregroundColor(cameraManager.accentColor)
                        }
                    }
                    
                }
            }
        }
    }

                    private func doShowOnboarding() {
                        showOnboarding = true
                    }
                    
                    private func resetDefaults() {
                        cameraManager.resetToDefaults()
                        cameraManager.configureSession()
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
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
