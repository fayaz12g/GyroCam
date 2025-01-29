import SwiftUI
import PhotosUI
import Photos


struct ControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var showingSettings = false
    @State private var showingQuickSettings = false
    @State private var showingPhotoLibrary = false
    @State private var latestThumbnail: UIImage?
    @Environment(\.colorScheme) var colorScheme
    @State private var isQuickSettingsVisible = false
    @Namespace private var animationNamespace

    
    var body: some View {
        ZStack {
            HStack {
                // Photo Library Button (Left)
                Button {
                    triggerHaptic(style: .light)
                    showingPhotoLibrary = true
                } label: {
                Group {
                    if let thumbnail = latestThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                    }
                }
                .frame(width: 44, height: 44)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
                .sheet(isPresented: $showingPhotoLibrary) {
                                    PhotoLibraryView()
                                }
                                
                                Spacer()
                                
                                // Recording Button (Center)
                                RecordingButton(
                                    isRecording: $cameraManager.isRecording,
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
                            }
                            .padding(.horizontal, 40)
                            
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
                        .onAppear(perform: loadLatestThumbnail)
                    }
//        .onReceive(NotificationCenter.default.publisher(for: PHPhotoLibrary.didChangeNotification)) { _ in
//            loadLatestThumbnail()
//        }
    
    private func loadLatestThumbnail() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue),
            ])
            
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            guard let asset = assets.firstObject else { return }
            
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            let size = CGSize(width: 88, height: 88)
            
            manager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                DispatchQueue.main.async {
                    self.latestThumbnail = image
                }
            }
        }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare() // Prepare the generator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
}
