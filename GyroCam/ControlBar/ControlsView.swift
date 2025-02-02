import SwiftUI

struct ControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var currentOrientation: String
    @State private var showingSettings = false
    @State private var showingQuickSettings = false
    @State private var isQuickSettingsVisible = false
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            HStack {
                // Photo Library Button (Left)
                PhotoLibraryButton(cameraManager: cameraManager, currentOrientation: $currentOrientation)
                .padding(.leading, 35)
                
                Spacer()
                
                // Recording Button (Center)
                RecordingButton(
                    isRecording: $cameraManager.isRecording,
                    cameraManager: cameraManager,
                    action: {
                        if cameraManager.isRecording {
                            triggerHaptic(style: .heavy)
                            cameraManager.stopRecording()
                        } else {
                            triggerHaptic(style: .medium)
                            cameraManager.startRecording()
                        }
                    }
                )
                
                Spacer()
                
                // Settings Button (Right)
                Button {
                    triggerHaptic(style: .light)
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        isQuickSettingsVisible.toggle()
                    }
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 24))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding()
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(isQuickSettingsVisible ? 90 : 0))
                        .matchedGeometryEffect(id: "gear", in: animationNamespace)
                }
                .padding(.leading, 35)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            
            if isQuickSettingsVisible {
                QuickSettingsView(cameraManager: cameraManager, showSettings: $showingSettings)
                    .matchedGeometryEffect(id: "quickSettings", in: animationNamespace)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5, anchor: .topTrailing).combined(with: .opacity),
                        removal: .scale(scale: 0.5, anchor: .topTrailing).combined(with: .opacity)
                    ))
                    .offset(y: -100)
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(cameraManager: cameraManager)
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
