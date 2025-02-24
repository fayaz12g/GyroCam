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


