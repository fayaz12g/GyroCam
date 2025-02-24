//
//  VideoPlayerView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/24/25.
//

import SwiftUI
import Photos
import AVKit


struct VideoPlayerView: View {
    let asset: PHAsset
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView()
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
