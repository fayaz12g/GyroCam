import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var clipNumber = 1
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
                .onRotate { orientation in
                    print("📱 System rotation detected: \(orientation)")
                }
            
            VStack {
                HStack {
                    OrientationHeader(currentOrientation: $cameraManager.currentOrientation)
                    
                    Spacer()
                    
                    Text("Clip #\(clipNumber)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                ControlsView(cameraManager: cameraManager)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            cameraManager.startOrientationUpdates()
        }
        .onChange(of: cameraManager.currentClipNumber) { newValue in
            clipNumber = newValue
        }
        .alert("Error", isPresented: .constant(!cameraManager.errorMessage.isEmpty)) {
            Button("OK") { cameraManager.errorMessage = "" }
        } message: {
            Text(cameraManager.errorMessage)
        }
    }
}

struct RotationModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(RotationModifier(action: action))
    }
}
