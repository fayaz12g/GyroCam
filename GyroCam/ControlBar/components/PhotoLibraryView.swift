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
    @State private var assets = [PHAsset]()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        VideoThumbnailView(asset: asset)
                    }
                }
                .padding()
            }
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.inline)
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

struct VideoThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var showingVideo = false
    
    var body: some View {
        Button(action: { showingVideo = true }) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped() // This ensures the image stays within bounds
                } else {
                    ProgressView()
                        .frame(width: 120, height: 120)
                }
            }
            .background(Color.gray)
            .cornerRadius(8)
        }
        .onAppear(perform: loadThumbnail)
        .fullScreenCover(isPresented: $showingVideo) {
            VideoPlayerView(asset: asset)
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        // Request a larger image for better quality
        manager.requestImage(for: asset,
                           targetSize: CGSize(width: 240, height: 240), // Double the size for better quality
                           contentMode: .aspectFill,
                           options: options) { img, _ in
            image = img
        }
    }
}
