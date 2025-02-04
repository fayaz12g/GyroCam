import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var clipNumber = 1
    
    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(session: cameraManager.session, cameraManager: cameraManager)
                    .ignoresSafeArea()
//                    .onRotate { orientation in
//                        print("Rotation detected: \(orientation)")
//                    }
                
                VStack {
                    // Top Bar
                    
                    HStack {
                        if cameraManager.showOrientationBadge {
                            OrientationHeader(cameraManager: cameraManager, currentOrientation: $cameraManager.currentOrientation)
                        }
                        
                        Spacer()
                        if cameraManager.showClipBadge {
                            ClipNumberBadge(number: clipNumber, currentOrientation: $cameraManager.currentOrientation, showClipBadge: $cameraManager.showClipBadge)
                        }
                    }
                    if cameraManager.showZoomBar {
                                            ZoomBarView(cameraManager: cameraManager)
                                                .transition(.opacity)
                                                .padding(.bottom, 8)
                                        }
                    Spacer()
                    
                    ControlsView(cameraManager: cameraManager, currentOrientation: $cameraManager.currentOrientation)
                        .padding(.bottom, 15)
                        .padding(.leading, -35)
                        
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            cameraManager.startOrientationUpdates()
        }
        .onChange(of: cameraManager.currentClipNumber) { oldValue, newValue in
            clipNumber = newValue
        }
        .alert("Error", isPresented: .constant(!cameraManager.errorMessage.isEmpty)) {
            Button("OK") { cameraManager.errorMessage = "" }
        } message: {
            Text(cameraManager.errorMessage)
        }
    }
}
