import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var focusValue: Float = 0.5
    @State private var clipNumber = 1
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @StateObject private var permissionsManager = PermissionsManager()
    
    var body: some View {
        Group {
            if showOnboarding || !permissionsManager.allPermissionsGranted {
                OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding, setPage: !permissionsManager.allPermissionsGranted ? 4 : 0)
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
                            
                            if cameraManager.showFocusBar {
                                FocusBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom)
                                    .padding(.bottom, cameraManager.showZoomBar || (cameraManager.isRecording || !cameraManager.showQuickSettings || cameraManager.isRestarting) ? 0 : 100)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }

                            if cameraManager.showZoomBar {
                                ZoomIndicator(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom)
                                    .padding(.bottom, !cameraManager.isRecording && cameraManager.showQuickSettings && !cameraManager.isRestarting  ? 100 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
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

