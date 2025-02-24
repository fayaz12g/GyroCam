//
//  VideoThumbnailView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/24/25.
//

import SwiftUI
import Photos

struct VideoThumbnailView: View {
    let asset: PHAsset
    @ObservedObject var cameraManager: CameraManager
    @State private var image: UIImage?
    @State private var showingVideo = false
    @State private var videoInfo: VideoInfo?
    @State private var videoBadges: [VideoBadgeType] = []
    
    var body: some View {
        Button(action: { showingVideo = true }) {
            ZStack(alignment: .bottom) {
                // Thumbnail Image
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray)
                .cornerRadius(8)
                .clipped()
                
                // Top-left Badges
                if cameraManager.isProMode {
                    VStack(alignment: .leading, spacing: 2) {
                            ForEach(videoBadges) { badge in
                                VideoBadgeView(
                                    type: badge,
                                    compactMode: !cameraManager.preserveAspectRatios
                                )
                                .padding(.leading, cameraManager.preserveAspectRatios ? 0 : 42)
                            }
                    }
                    .padding(cameraManager.preserveAspectRatios ? 6 : 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                // Bottom Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: cameraManager.preserveAspectRatios ? 48 : 30)
                
                // Info Overlay with adjusted sizing
                HStack(alignment: .bottom) {
                    if cameraManager.isProMode,
                       let info = videoInfo {
                        VStack(alignment: .leading, spacing: cameraManager.preserveAspectRatios ? 2 : 1) {
                            Text(info.creationTime)
                                .font(.system(size: cameraManager.preserveAspectRatios ? 10 : 8, weight: .medium))
                            Text(info.resolution)
                                .font(.system(size: cameraManager.preserveAspectRatios ? 8 : 6, weight: .medium))
                            Text(info.fps)
                                .font(.system(size: cameraManager.preserveAspectRatios ? 8 : 6, weight: .medium))
                        }
                        .padding(.leading, cameraManager.preserveAspectRatios ? 0 : 45)
                    }
                    
                    Spacer()
                    
                    Text(asset.duration.formattedDuration)
                        .font(.system(size: cameraManager.preserveAspectRatios ? 12 : 10, weight: .semibold))
                        .padding(.trailing, cameraManager.preserveAspectRatios ? 0 : 45)
                }
                .foregroundColor(.white)
                .padding(cameraManager.preserveAspectRatios ? 8 : 4)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            loadThumbnail()
            if cameraManager.isProMode {
                loadVideoBadges()
                loadVideoInfo()
            }
        }
        .onChange(of: cameraManager.isProMode) { _, newValue in
            if newValue {
                loadVideoBadges()
                loadVideoInfo()
            }
        }
        .sheet(isPresented: $showingVideo) {
            VideoPlayerView(asset: asset)
        }
    }
    
    private func loadVideoBadges() {
        DispatchQueue.global(qos: .userInitiated).async {
            let badges = self.asset.videoBadges
            DispatchQueue.main.async {
                self.videoBadges = badges
            }
        }
    }
    
    private func loadThumbnail() {
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: nil
        ) { image, _ in
            self.image = image
        }
    }
    
    private func loadVideoInfo() {
        guard videoInfo == nil else { return }
        
        PHImageManager.default().requestAVAsset(
            forVideo: asset,
            options: nil
        ) { avAsset, _, _ in
            guard let avAsset = avAsset,
                  let creationDate = asset.creationDate else { return }
            
            let videoTracks = avAsset.tracks(withMediaType: .video)
            guard let track = videoTracks.first else { return }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            DispatchQueue.main.async {
                self.videoInfo = VideoInfo(
                    resolution: "\(Int(track.naturalSize.width))x\(Int(track.naturalSize.height))",
                    fps: "\(Int(track.nominalFrameRate)) fps",
                    creationTime: formatter.string(from: creationDate)
                )
            }
        }
    }
}
