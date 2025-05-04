import SwiftUI

struct ContentView: View {
    @StateObject var permissionsManager = PermissionsManager()
    @StateObject private var cameraManager = CameraManager()

    @State private var focusValue: Float = 0.5
    @State private var clipNumber = 1
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var forceOnboarding = (!PermissionsManager().allPermissionsGranted && (UserDefaults.standard.bool(forKey: "hasSeenOnboarding")))
    
    var body: some View {
        Group {
            if showOnboarding || forceOnboarding {
                OnboardingView(cameraManager: cameraManager, permissionsManager: permissionsManager, showOnboarding: $showOnboarding, forceOnboarding: $forceOnboarding, setPage: forceOnboarding ? 4 : 0)
            } else {
                NavigationView {
                    ZStack {
                        CameraPreview(session: cameraManager.session, cameraManager: cameraManager, showOnboarding: $showOnboarding)
                            .ignoresSafeArea()
                        VStack {
                            // Top Bar
                            HStack {
                                if cameraManager.showOrientationBadge {
                                    OrientationBadge(cameraManager: cameraManager, currentOrientation: $cameraManager.currentOrientation, showOrientationBadge: $cameraManager.showOrientationBadge)
                                }
                                
                                Spacer()
                                
                                if cameraManager.showDurationBadge && (cameraManager.isRecording || cameraManager.isRestarting) {
                                    DurationBadge(cameraManager: cameraManager, currentOrientation: $cameraManager.currentOrientation, showDurationBadge: $cameraManager.showDurationBadge)
                                }
                                
                                Spacer()
                                
                                
                                if cameraManager.showClipBadge {
                                    ClipNumberBadge(number: clipNumber, currentOrientation: $cameraManager.currentOrientation, realOrientation: $cameraManager.realOrientation, showClipBadge: $cameraManager.showClipBadge)
                                }
                            }
                            
                            if cameraManager.showISOBar {
                                ISOBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .bottom)
                                    .padding(.horizontal)
                                    .padding(.bottom, cameraManager.showZoomBar ||  cameraManager.showFocusBar || (cameraManager.isRecording || !cameraManager.showQuickSettings || cameraManager.isRestarting) ? 0 : 100)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }
                            
                            if cameraManager.showFocusBar {
                                FocusBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .bottom)
                                    .padding(.bottom, cameraManager.showZoomBar || (cameraManager.isRecording || !cameraManager.showQuickSettings || cameraManager.isRestarting) ? 0 : 100)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }

                            if cameraManager.showZoomBar {
                                ZoomBar(cameraManager: cameraManager)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .bottom)
                                    .padding(.bottom, !cameraManager.isRecording && cameraManager.showQuickSettings && !cameraManager.isRestarting  ? 100 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
                            }
                            
                            Spacer()
                            
                            ControlsView(cameraManager: cameraManager, permissionsManager: permissionsManager, currentOrientation: $cameraManager.realOrientation)
                                .padding(.bottom, 15)
                                .padding(.leading, -35)
                            
                            if !cameraManager.activeExports.isEmpty && cameraManager.allowRecordingWhileSaving {
                                Button(action: {
                                    cameraManager.showExportSheet = true
                                }) {
                                    HStack(spacing: 8) {
                                        // Export indicator with stacked papers look
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(cameraManager.accentColor.opacity(0.8))
                                                .frame(width: 16, height: 16)
                                                .offset(y: 0)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(cameraManager.accentColor)
                                                .frame(width: 16, height: 16)
                                                .offset(y: -3)
                                            
                                            // Export arrow on top
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.white)
                                                .offset(y: -3)
                                        }
                                        
                                        Text("Show Exports")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        // Badge showing number of exports or checkmark
                                        if cameraManager.activeExports.count > 0 {
                                            if cameraManager.activeExports.count == 1,
                                               let export = cameraManager.activeExports.first,
                                               export.isCompleted {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .background(Circle().fill(Color.green))
                                                    .frame(width: 20, height: 20)
                                            } else {
                                                Text("\(cameraManager.activeExports.count)")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .background(Circle().fill(Color.red))
                                                    .frame(width: 20, height: 20)
                                            }
                                        }

                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                            )
                                    )
                                    .padding(.trailing, 12)
                                }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.bouncy, value: cameraManager.activeExports.isEmpty)
                            }

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
                .sheet(isPresented: $cameraManager.showExportSheet) {
                    ExportProgressSheet(cameraManager: cameraManager)
                }
            }
        }
    }
}


