import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var clipNumber = 1
    
    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
//                    .onRotate { orientation in
//                        print("Rotation detected: \(orientation)")
//                    }
                
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
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
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
