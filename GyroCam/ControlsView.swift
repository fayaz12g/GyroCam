import SwiftUI

struct ControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var showingSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding()
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(cameraManager: cameraManager)
            }
            
            Spacer()
            
            RecordingButton(
                isRecording: $cameraManager.isRecording,
                action: {
                    if cameraManager.isRecording {
                        cameraManager.stopRecording()
                    } else {
                        cameraManager.startRecording()
                    }
                }
            )
            
            Spacer()
            
            Circle()
                .foregroundColor(.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 40)
    }
}
