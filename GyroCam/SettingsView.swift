import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Video Quality")) {
                    Picker("Resolution", selection: $cameraManager.currentFormat) {
                        ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .onChange(of: cameraManager.currentFormat) { _ in
                        cameraManager.configureSession()
                    }
                    
                    Toggle("Enable HDR", isOn: $cameraManager.isHDREnabled)
                        .onChange(of: cameraManager.isHDREnabled) { _ in
                            cameraManager.configureSession()
                        }
                }
                
                Section(header: Text("Frame Rate")) {
                    Picker("FPS", selection: $cameraManager.currentFPS) {
                        ForEach(FrameRate.allCases) { fps in
                            Text(fps.description).tag(fps)
                        }
                    }
                    .onChange(of: cameraManager.currentFPS) { _ in
                        cameraManager.configureSession()
                    }
                }
                
                Section(header: Text("Camera Options")) {
                    Picker("Lens", selection: $cameraManager.currentLens) {
                        ForEach(CameraManager.LensType.allCases, id: \.self) { lens in
                            Text(lens.rawValue).tag(lens)
                        }
                    }
                    .onChange(of: cameraManager.currentLens) { _ in
                        cameraManager.configureSession() // Add this line
                    }
                    
                    Picker("Position", selection: $cameraManager.cameraPosition) {
                        Text("Back").tag(AVCaptureDevice.Position.back)
                        Text("Front").tag(AVCaptureDevice.Position.front)
                    }
                    .onChange(of: cameraManager.cameraPosition) { _ in
                        cameraManager.configureSession() 
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
