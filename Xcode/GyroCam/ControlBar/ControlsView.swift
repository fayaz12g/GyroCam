import SwiftUI
import AVFAudio

struct ControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var permissionsManager: PermissionsManager
    
    @Binding var currentOrientation: String
    @State private var showingSettings = false
    @State private var showingQuickSettings = false
    @State private var isQuickSettingsVisible = false
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            HStack {
                if !cameraManager.isRecording && !cameraManager.isRestarting {
                    
                    // Photo Library Button (Left)
                    PhotoLibraryButton(cameraManager: cameraManager)
                        .padding(.leading, 35)
                }
                
                Spacer()
                
                // Recording Button (Center)
                RecordingButton(
                    isRecording: $cameraManager.isRecording,
                    cameraManager: cameraManager,
                    action: {
                        if cameraManager.isRecording {
                            cameraManager.stopRecording()
                        } else {
                            cameraManager.startRecording()
                        }
                        if !cameraManager.hapticsConfigured {
                            cameraManager.configureHaptics()
                            cameraManager.hapticsConfigured = true
                        }
                        DispatchQueue.main.async {
                            if cameraManager.playHaptics {
                                triggerHaptic(style: .medium)
                            }
                        }
                    }
                )
                .padding(.leading, cameraManager.isRecording || cameraManager.isRestarting ? 35 : -15)
                .padding(.vertical, cameraManager.isRecording || cameraManager.isRestarting ? 10 : 0)
                
                
                Spacer()
                
                if !cameraManager.isRecording && !cameraManager.isRestarting {
                    
                    // Settings Button (Right)
                    Button {
                        if !cameraManager.hapticsConfigured {
                            cameraManager.configureHaptics()
                            cameraManager.hapticsConfigured = true
                        }
                        if cameraManager.playHaptics {
                            triggerHaptic(style: .light)
                        }
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                            showingSettings.toggle()
                        }
                    } label: {
                        ZStack {
                            // Outer glass effect with blur
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                            
                            // Gear icon
                            Image(systemName: "gear")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .rotationEffect(.degrees(showingSettings ? 90 : 0))
                                .matchedGeometryEffect(id: "gear", in: animationNamespace)
                        }
                    }
                    .padding(.trailing, 15)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            
            ZStack {
                QuickSettingsView(cameraManager: cameraManager, showSettings: $showingSettings)
                    .matchedGeometryEffect(id: "quickSettings", in: animationNamespace)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5, anchor: .topTrailing).combined(with: .opacity),
                        removal: .scale(scale: 0.5, anchor: .topTrailing).combined(with: .opacity)
                    ))
                    .offset(y: -100)
                    .offset(x: 20)
                    .zIndex(1)
                    .opacity(!cameraManager.isRecording && cameraManager.showQuickSettings && !cameraManager.isRestarting ? 1 : 0) // Control visibility
                    .scaleEffect(!cameraManager.isRecording && cameraManager.showQuickSettings && !cameraManager.isRestarting ? 1 : 0.5, anchor: .topTrailing)
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.isRecording)
            }

        }
        .sheet(isPresented: cameraManager.sheetSettings ? $showingSettings : .constant(false)) {
                        SettingsView(cameraManager: cameraManager, permissionsManager: permissionsManager, isPresented: $showingSettings)
                    }
        .fullScreenCover(isPresented: !cameraManager.sheetSettings ? $showingSettings : .constant(false)) {
            SettingsView(cameraManager: cameraManager, permissionsManager: permissionsManager, isPresented: $showingSettings)
        }
        .onChange(of: showingSettings) { _, newValue in
            if newValue {
                cameraManager.stopSession()
            } else {
                cameraManager.startSession()
            }
        }
    }
    
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
}
