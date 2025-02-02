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
    @State private var assetGroups = [Date: [PHAsset]]()
    @State private var sortedDates = [Date]()
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(sortedDates, id: \.self) { date in
                        Section {
                            MasonryView(assets: assetGroups[date] ?? [],
                                      cameraManager: cameraManager)
                                .padding(.horizontal)
                        } header: {
                            Text(date.formattedDateHeader)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle("Pro Mode", isOn: $cameraManager.isProMode)
                        .toggleStyle(.switch)
                        .tint(cameraManager.accentColor)
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
            var groups = [Date: [PHAsset]]()
            
            results.enumerateObjects { asset, _, _ in
                guard let date = asset.creationDate else { return }
                let normalizedDate = Calendar.current.startOfDay(for: date)
                
                if groups[normalizedDate] == nil {
                    groups[normalizedDate] = [PHAsset]()
                }
                groups[normalizedDate]?.append(asset)
            }
            
            DispatchQueue.main.async {
                assetGroups = groups
                sortedDates = groups.keys.sorted(by: >)
            }
        }
    }
}

struct MasonryView: View {
    let assets: [PHAsset]
    @ObservedObject var cameraManager: CameraManager
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 8)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(assets, id: \.localIdentifier) { asset in
                VideoThumbnailView(asset: asset, cameraManager: cameraManager)
                    .aspectRatio(CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .fit)
            }
        }
    }
}

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
                // Thumbnail image
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
                
                // Top-left badges
                if cameraManager.isProMode {
                    VStack(alignment: .leading) {
                        ForEach(videoBadges) { badge in
                            VideoBadgeView(type: badge)
                        }
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                // Bottom gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 48)
                
                // Info overlay
                HStack(alignment: .bottom) {
                    if cameraManager.isProMode, let info = videoInfo {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(info.creationTime)
                                .font(.system(size: 10, weight: .medium))
                            Text(info.resolution)
                                .font(.system(size: 8, weight: .medium))
                            Text(info.fps)
                                .font(.system(size: 8, weight: .medium))
                        }
                    }
                    
                    Spacer()
                    
                    Text(asset.duration.formattedDuration)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(8)
            }
        }
        .onAppear {
            loadThumbnail()
            if cameraManager.isProMode {
                loadVideoBadges()
                loadVideoInfo()
            }
        }
        .onChange(of: cameraManager.isProMode) { newValue in
            if newValue { loadVideoInfo() }
        }
        .fullScreenCover(isPresented: $showingVideo) {
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

struct HDRBadge: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Image(systemName: "h.square.fill")
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(4)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct VideoInfo {
    let resolution: String
    let fps: String
    let creationTime: String
}

extension Date {
    var formattedDateHeader: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self).uppercased()
    }
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

// Add this enum to handle different badge types
enum VideoBadgeType: Identifiable, CaseIterable {
    case hdr
    case cinematic
    case highFrameRate
    case timelapse
    case hevc
    case hdrFallback
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .hdr, .hdrFallback: return "h.square.fill"
        case .cinematic: return "movieclapper.fill"
        case .highFrameRate: return "speedometer"
        case .timelapse: return "timelapse"
        case .hevc: return "h.square"
        }
    }
    
    var label: String {
        switch self {
        case .hdr: return "HDR"
        case .hdrFallback: return "HDR"
        case .cinematic: return "Cinematic"
        case .highFrameRate: return "High FPS"
        case .timelapse: return "Timelapse"
        case .hevc: return "HEVC"
        }
    }
}

extension PHAsset {
    var videoBadges: [VideoBadgeType] {
        var badges = [VideoBadgeType]()
        
        // Check media subtypes first
        if mediaSubtypes.contains(.videoCinematic) {
            badges.append(.cinematic)
        }
        if mediaSubtypes.contains(.videoHighFrameRate) {
            badges.append(.highFrameRate)
        }
        if mediaSubtypes.contains(.videoTimelapse) {
            badges.append(.timelapse)
        }
        
        // Check video format and codec
        let options = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHImageManager.default().requestAVAsset(forVideo: self, options: options) { asset, _, _ in
            guard let asset = asset else {
                semaphore.signal()
                return
            }
            
            let videoTracks = asset.tracks(withMediaType: .video)
            if let firstTrack = videoTracks.first,
               let formatDescription = firstTrack.formatDescriptions.first {
                
//                // Check codec type (added clutter)
//                let codec = CMFormatDescriptionGetMediaSubType(formatDescription as! CMFormatDescription)
//                if codec == kCMVideoCodecType_HEVC {
//                    badges.append(.hevc)
//                }
//                
                // Check HDR characteristics
                let colorPrimaries = CMFormatDescriptionGetExtension(formatDescription as! CMFormatDescription, extensionKey: kCVImageBufferColorPrimariesKey)
                let transferFunction = CMFormatDescriptionGetExtension(formatDescription as! CMFormatDescription, extensionKey: kCVImageBufferTransferFunctionKey)
                
                if let transferFunction = transferFunction as? String,
                   (transferFunction == (kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ as String) ||
                    transferFunction == (kCVImageBufferTransferFunction_ITU_R_2100_HLG as String)) {
                    badges.append(.hdr)
                }
                else if let colorPrimaries = colorPrimaries as? String,
                        (colorPrimaries == (kCVImageBufferColorPrimaries_ITU_R_2020 as String) ||
                         colorPrimaries == (kCVImageBufferColorPrimaries_P3_D65 as String)) {
                    badges.append(.hdrFallback)
                }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return badges.uniqued()
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// Updated HDRBadge view to handle multiple types
struct VideoBadgeView: View {
    let type: VideoBadgeType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .symbolRenderingMode(.hierarchical)
            Text(type.label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}


