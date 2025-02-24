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
    @State private var allAssets = [PHAsset]()
    @State private var assetGroups = [Date: [PHAsset]]()
    @State private var sortedDates = [Date]()
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.presentationMode) var presentationMode
    
    private func DoneButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") { presentationMode.wrappedValue.dismiss() }
                .foregroundColor(cameraManager.accentColor)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if cameraManager.preserveAspectRatios {
                    // Masonry Layout with Date Grouping
                    LazyVStack(spacing: 20) {
                        ForEach(sortedDates, id: \.self) { date in
                            Section {
                                MasonryView(
                                    assets: assetGroups[date] ?? [],
                                    cameraManager: cameraManager
                                )
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
                } else {
                    // Grid Layout with Fixed-Size Thumbnails and Date Grouping
                    LazyVStack(spacing: 20) {
                        ForEach(sortedDates, id: \.self) { date in
                            Section {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                                    ForEach(assetGroups[date] ?? [], id: \.localIdentifier) { asset in
                                        VideoThumbnailView(asset: asset, cameraManager: cameraManager)
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
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
            }
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadAssets)
            .toolbar { DoneButton() }
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
            var groups = [Date: [PHAsset]]()
            
            results.enumerateObjects { asset, _, _ in
                loadedAssets.append(asset)
                
                // Grouping logic for masonry view
                if let date = asset.creationDate {
                    let normalizedDate = Calendar.current.startOfDay(for: date)
                    if groups[normalizedDate] == nil {
                        groups[normalizedDate] = []
                    }
                    groups[normalizedDate]?.append(asset)
                }
            }
            
            DispatchQueue.main.async {
                self.allAssets = loadedAssets
                self.assetGroups = groups
                self.sortedDates = groups.keys.sorted(by: >)
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

struct VideoBadgeView: View {
    let type: VideoBadgeType
    let compactMode: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: compactMode ? 1 : 2) {
            Image(systemName: type.icon)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: compactMode ? 8 : 10))
            Text(type.label)
                .font(.system(size: compactMode ? 8 : 10, weight: .medium))
                .lineLimit(1)
        }
        .padding(.horizontal, compactMode ? 4 : 6)
        .padding(.vertical, compactMode ? 2 : 4)
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: compactMode ? 4 : 6))
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


