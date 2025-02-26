import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var focusValue: Float = 0.5
    @State private var clipNumber = 1
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @StateObject private var permissionsManager = PermissionsManager()
    @State private var forceOnboarding = (!PermissionsManager().allPermissionsGranted && (UserDefaults.standard.bool(forKey: "hasSeenOnboarding")))
    
    var body: some View {
        Group {
            if showOnboarding || forceOnboarding {
                OnboardingView(cameraManager: cameraManager, showOnboarding: $showOnboarding, forceOnboarding: $forceOnboarding, setPage: forceOnboarding ? 4 : 0)
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
                                    ClipNumberBadge(number: clipNumber, currentOrientation: $cameraManager.currentOrientation, realOrientation: $cameraManager.realOrientation, showClipBadge: $cameraManager.showClipBadge)
                                }
                            }
                            
                            if cameraManager.showISOBar {
                                ISOBar(cameraManager: cameraManager)
                                    .padding(.horizontal)
                                    .padding(.bottom, cameraManager.showZoomBar ||  cameraManager.showFocusBar || (cameraManager.isRecording || !cameraManager.showQuickSettings || cameraManager.isRestarting) ? 0 : 100)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }
                            
                            if cameraManager.showFocusBar {
                                FocusBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom)
                                    .padding(.bottom, cameraManager.showZoomBar || (cameraManager.isRecording || !cameraManager.showQuickSettings || cameraManager.isRestarting) ? 0 : 100)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }

                            if cameraManager.showZoomBar {
                                ZoomBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .bottom)
                                    .padding(.bottom, !cameraManager.isRecording && cameraManager.showQuickSettings && !cameraManager.isRestarting  ? 100 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }
                            
                            Spacer()
                            
                            ControlsView(cameraManager: cameraManager, currentOrientation: $cameraManager.realOrientation)
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
                .alert(cameraManager.messageType, isPresented: .constant(!cameraManager.presentMessage.isEmpty)) {
                    Button("OK") { cameraManager.presentMessage = "" }
                } message: {
                    Text(cameraManager.presentMessage)
                }
            }
        }
    }
}


