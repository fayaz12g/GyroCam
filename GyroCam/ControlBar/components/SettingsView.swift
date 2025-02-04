import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Interface")) {
                    HStack {
                        Text("Show Zoom Bar")
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple)
                            .cornerRadius(10)
                        Toggle("", isOn: $cameraManager.showZoomBar)
                            .tint(cameraManager.accentColor)
                    }
                    
                    Toggle("Maximize Preview", isOn: $cameraManager.maximizePreview)
                        .tint(cameraManager.accentColor)
                    
                    Toggle("Show Orientation Badge", isOn: $cameraManager.showOrientationBadge)
                        .tint(cameraManager.accentColor)
                    
                    if cameraManager.showOrientationBadge {
                        Toggle("Minimal Orientation Badge", isOn: $cameraManager.minimalOrientationBadge)
                            .tint(cameraManager.accentColor)
                    }
                    
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
                        Text("Preserve Aspect Ratios")
              
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple)
                            .cornerRadius(10)
                        Toggle("", isOn: $cameraManager.preserveAspectRatios)
                            .tint(cameraManager.accentColor)
                    }
                        
                        Toggle("Show Pro Mode", isOn: $cameraManager.isProMode)
                            .tint(cameraManager.accentColor)
                        
                    }
                    
                    Section(header: Text("Video Quality")) {
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
                    }
                    
                    Section(header: Text("Camera Options")) {
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
                        
                        
                    }
                    
                    Section(header: Text("Updates")) {
                        NavigationLink {
                            ChangelogView(cameraManager: cameraManager)
                        } label: {
                            HStack {
                                Text("Changelog")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "clock.badge.checkmark")
                            }
                        }
                        
                        NavigationLink {
                            UpcomingFeaturesView()
                        } label: {
                            HStack {
                                Text("Upcoming Features")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "road.lanes.curved.right")
                            }
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

                    
                    private func resetDefaults() {
                        cameraManager.resetToDefaults()
                        cameraManager.configureSession()
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
