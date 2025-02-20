import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var focusValue: Float = 0.5
    @State private var clipNumber = 1
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding)
            } else {
                NavigationView {
                    ZStack {
                        CameraPreview(session: cameraManager.session, cameraManager: cameraManager, showOnboarding: $showOnboarding)
                            .ignoresSafeArea()
                        
                        VStack {
                            // Top Bar
                            HStack {
                                if cameraManager.showOrientationBadge {
                                    OrientationHeader(cameraManager: cameraManager, currentOrientation: $cameraManager.currentOrientation, showOrientationBadge: $cameraManager.showOrientationBadge)
                                }
                                
                                Spacer()
                                if cameraManager.showClipBadge {
                                    ClipNumberBadge(number: clipNumber, currentOrientation: $cameraManager.currentOrientation, showClipBadge: $cameraManager.showClipBadge)
                                }
                            }
                            
                            FocusBar(cameraManager: cameraManager)
                                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom) // 80% of the screen width
                                .padding(.bottom, cameraManager.showZoomBar ? 0 : 100)

                            if cameraManager.showZoomBar {
                                ZoomIndicator(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom) // 80% of the screen width
                                    .padding(.bottom, 100)
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
    }
}

