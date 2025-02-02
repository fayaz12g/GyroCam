//
//  PhotoLibraryView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//


import SwiftUI
import Photos
import AVKit


struct PhotoLibraryView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var assets = [PHAsset]()
    @State private var isProMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                MasonryView(assets: assets, isProMode: $isProMode)
                    .padding()
            }
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle("Pro Mode", isOn: $isProMode)
                        .tint(cameraManager.accentColor)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
            }
            .onAppear(perform: loadAssets)
        }
    }
    
    private func loadAssets() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            
            let results = PHAsset.fetchAssets(with: fetchOptions)
            var loadedAssets = [PHAsset]()
            results.enumerateObjects { asset, _, _ in
                loadedAssets.append(asset)
            }
            DispatchQueue.main.async {
                assets = loadedAssets
            }
        }
    }
}

struct MasonryView: View {
    let assets: [PHAsset]
    @Binding var isProMode: Bool
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 8)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(assets, id: \.localIdentifier) { asset in
                VideoThumbnailView(asset: asset, isProMode: $isProMode)
                    .aspectRatio(CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .fit)
            }
        }
    }
}

struct VideoThumbnailView: View {
    let asset: PHAsset
    @Binding var isProMode: Bool
    @State private var image: UIImage?
    @State private var showingVideo = false
    @State private var videoInfo: VideoInfo?
    
    var body: some View {
        Button(action: { showingVideo = true }) {
            ZStack(alignment: .bottomTrailing) {
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
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
                
                // Info overlay
                VStack(alignment: .trailing, spacing: 2) {
                    if isProMode, let info = videoInfo {
                        Text(info.resolution)
                            .font(.system(size: 10, weight: .medium))
                        Text(info.fps)
                            .font(.system(size: 10, weight: .medium))
                    }
                    Text(asset.duration.formattedDuration)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(6)
            }
        }
        .onAppear(perform: loadThumbnail)
        .onChange(of: isProMode) { newValue in
            if newValue { loadVideoInfo() }
        }
        .fullScreenCover(isPresented: $showingVideo) {
            VideoPlayerView(asset: asset)
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
            guard let avAsset = avAsset else { return }
            
            let videoTracks = avAsset.tracks(withMediaType: .video)
            guard let track = videoTracks.first else { return }
            
            let resolution = "\(Int(track.naturalSize.width))x\(Int(track.naturalSize.height))"
            let fps = "\(Int(track.nominalFrameRate)) fps"
            
            DispatchQueue.main.async {
                self.videoInfo = VideoInfo(resolution: resolution, fps: fps)
            }
        }
    }
}

struct VideoInfo {
    let resolution: String
    let fps: String
}

extension TimeInterval {
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "0:00"
    }
}

// Keep the existing VideoPlayerView implementation

struct VideoPlayerView: View {
    let asset: PHAsset
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView()
            }
            
            // Close button in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func loadVideo() {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        manager.requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
            guard let urlAsset = asset as? AVURLAsset else { return }
            DispatchQueue.main.async {
                self.player = AVPlayer(url: urlAsset.url)
                self.player?.play()
            }
        }
    }
}

