//
//  PhotoLibraryButton.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/31/25.
//


import SwiftUI
import Photos

struct PhotoLibraryButton: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPhotoLibrary = false
    @State private var latestThumbnail: UIImage?
    
    private var rotationAngle: Angle {
        switch cameraManager.currentOrientation {
        case "Landscape Left": return .degrees(90)
        case "Landscape Right": return .degrees(-90)
        case "Upside Down": return .degrees(180)
        default: return .degrees(0)
        }
    }
    
    private var horizontalPadding: CGFloat {
        rotationAngle == .degrees(0) ? -30 : -30
    }
    
    private var verticalOffset: CGFloat {
        switch cameraManager.currentOrientation {
        case "Landscape Left", "Landscape Right": return -6
        case "Upside Down": return 0
        default: return 0
        }
    }
    
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
    
    var body: some View {
        Button {
            if cameraManager.playHaptics {
                triggerHaptic(style: .light)
            }
            showingPhotoLibrary = true
        } label: {
            Group {
                if let thumbnail = latestThumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20))
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .background(colorScheme == .dark ? Color.black.opacity(0.0) : Color.white.opacity(0.0))
                }
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .rotationEffect(rotationAngle)
        }
//        .padding(.trailing, horizontalPadding)
//        .offset(y: verticalOffset)
        .animation(.easeInOut(duration: 0.2), value: cameraManager.currentOrientation)
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryView(cameraManager: cameraManager)
        }
        .onAppear(perform: loadLatestThumbnail)
        .onChange(of: cameraManager.loadLatestThumbnail) { _, _ in
            loadLatestThumbnail()
        }

        
    }
    
    public func loadLatestThumbnail() {
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
}
