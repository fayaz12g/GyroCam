import AVFoundation
import CoreMotion
import UIKit
import Photos
import SwiftUI
import CoreLocation
import UserNotifications

@MainActor
class CameraManager: NSObject, ObservableObject {
    
    @State var permissionsManager = PermissionsManager()
    
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let motionManager = CMMotionManager()
    private var currentDevice: AVCaptureDevice?
    private var currentCaptureDevice: AVCaptureDevice?
    private var activeInput: AVCaptureDeviceInput?
    private var stopCompletion: (() -> Void)?
    private var recordingStartTime: Date?
    
    private var orientationChanges: [OrientationChange] = []

    var exportDuration: Double = 0.0
    var videoDuration: Double = 0.0
    @Published var exportProgress: Float = 0.0
    @Published var isExporting: Bool = false
    @AppStorage("savedExports") private var savedExportsData: Data?
    @State private var durationTimer: Timer? = nil
    
    public var rotationAngle: Angle {
        switch self.realOrientation {
        case "Landscape Left": return .degrees(90)
        case "Landscape Right": return .degrees(-90)
        case "Upside Down": return .degrees(180)
        default: return .degrees(0)
        }
    }
    
    private var previousOrientation: UIDeviceOrientation = .portrait
    private let recordingQueue = DispatchQueue(label: "recording.queue")
    public var isRestarting = false
    
    public var hapticsConfigured = false
    
    public var loadLatestThumbnail: Bool = false
    
    @Published var clipDataList: [ClipData] = [] {
            didSet { saveClipDataState() }
        }
    
    private let clipDataKey = "savedClipData"
    
    private var stitchingGroup: DispatchGroup?
    @Published var currentClipNumber = 1

    
    // location
    private let locationManager = CLLocationManager()
    private var lastKnownLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // New rotation method
    @MainActor private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    @MainActor @Published var isRecording = false
    @MainActor @Published var currentOrientation = "Loading..."
    @MainActor @Published var realOrientation = "Loading..."
    @MainActor @Published var presentMessage = ""
    @MainActor @Published var messageType = ""
    
    @Published var currentZoom: CGFloat = 1.0
    @Published var exportQuality: ExportQuality = .highest
    
    @Published private var settings = AppSettings() {
        didSet {
            saveSettings()
        }
    }
    
    private var activeCameraDevice: AVCaptureDevice? {
        return activeInput?.device
    }
    
    @MainActor var focusValue: Float {
        get { settings.focusValue }
        set { settings.focusValue = newValue }
    }
    
    @MainActor var shouldStitchClips: Bool {
        get { settings.shouldStitchClips }
        set { settings.shouldStitchClips = newValue }
    }
    
    @MainActor var isProMode: Bool {
        get { settings.isProMode }
        set { settings.isProMode = newValue }
    }
    
    @MainActor var isSavingVideo: Bool {
        get { settings.isSavingVideo }
        set { settings.isSavingVideo = newValue }
    }
    
    @MainActor var lockLandscape: Bool {
        get { settings.lockLandscape }
        set { settings.lockLandscape = newValue }
    }
    
    @MainActor var useBlurredBackground: Bool {
        get { settings.useBlurredBackground }
        set { settings.useBlurredBackground = newValue }
    }
    
    @MainActor var sheetSettings: Bool {
        get { settings.sheetSettings }
        set { settings.sheetSettings = newValue }
    }
    
    @MainActor var recordingPulse: Bool {
        get { settings.recordingPulse }
        set { settings.recordingPulse = newValue }
    }
    
    @MainActor var developerMode: Bool {
        get { settings.developerMode }
        set { settings.developerMode = newValue }
    }
    
    @MainActor var stabilizeVideo: StabilizationMode {
        get { settings.stabilizeVideo }
        set { settings.stabilizeVideo = newValue }
    }
    
    @MainActor var rotationHaptics: RotationHaptic {
        get { settings.rotationHaptics }
        set { settings.rotationHaptics = newValue }
    }
    
    @MainActor var rotationHapticsStrength: RotationHapticStrength {
        get { settings.rotationHapticsStrength }
        set { settings.rotationHapticsStrength = newValue }
    }
    
    @MainActor var currentFormat: VideoFormat {
        get { settings.currentFormat }
        set { settings.currentFormat = newValue }
    }
    
    @MainActor var currentFPS: FrameRate {
        get { settings.currentFPS }
        set { settings.currentFPS = newValue }
    }
    
    @MainActor var cameraPosition: AVCaptureDevice.Position {
        get { settings.cameraPosition }
        set { settings.cameraPosition = newValue }
    }
    
    @MainActor var currentLens: LensType {
        get { settings.currentLens }
        set { settings.currentLens = newValue }
    }
    
    @MainActor var isHDREnabled: Bool {
        get { settings.isHDREnabled }
        set { settings.isHDREnabled = newValue }
    }
    
    @MainActor var preserveAspectRatios: Bool {
        get { settings.preserveAspectRatios }
        set { settings.preserveAspectRatios = newValue }
    }
    
    
    // Header
    @MainActor var showClipBadge: Bool {
        get { settings.showClipBadge }
        set { settings.showClipBadge = newValue }
    }
    
    @MainActor var showOrientationBadge: Bool {
        get { settings.showOrientationBadge }
        set { settings.showOrientationBadge = newValue }
    }
    
    @MainActor var minimalOrientationBadge: Bool {
        get { settings.minimalOrientationBadge }
        set { settings.minimalOrientationBadge = newValue }
    }
    
    @MainActor var showDurationBadge: Bool {
        get { settings.showDurationBadge }
        set { settings.showDurationBadge = newValue }
    }
    
    @MainActor var showQuickSettings: Bool {
        get { settings.showQuickSettings }
        set { settings.showQuickSettings = newValue }
    }
    
    @MainActor var showZoomBar: Bool {
        get { settings.showZoomBar }
        set { settings.showZoomBar = newValue }
    }
    
    
    @MainActor var maximizePreview: Bool {
        get { settings.maximizePreview }
        set { settings.maximizePreview = newValue }
    }
    
    
    @MainActor var playSounds: Bool {
        get { settings.playSounds }
        set { settings.playSounds = newValue }
    }
    
    @MainActor var playHaptics: Bool {
        get { settings.playHaptics }
        set { settings.playHaptics = newValue }
    }
    
    @MainActor var accentColor: Color {
        get { settings.accentColor }
        set { settings.accentColor = newValue }
    }
    
    @MainActor var primaryColor: Color {
        get { settings.primaryColor }
        set { settings.primaryColor = newValue }
    }
    
    @MainActor var isFlashOn: Bool {
        get { settings.isFlashOn }
        set { settings.isFlashOn = newValue }
    }
    
    @MainActor var autoExposure: Bool {
        get { settings.autoExposure }
        set {
            settings.autoExposure = newValue
        }
    }
    
    @MainActor var manualISO: Float {
        get { settings.manualISO }
        set {
            let clampedISO = min(max(newValue, minISO), maxISO)
            settings.manualISO = clampedISO
            if !autoExposure {
                setDeviceISO(clampedISO)
            }
        }
    }
    
    @MainActor var showISOBar: Bool {
        get { settings.showISOBar }
        set { settings.showISOBar = newValue }
    }
    
    @MainActor var showFocusBar: Bool {
        get { settings.showFocusBar }
        set {
            settings.showFocusBar = newValue
            if newValue {
                autoFocus = false
            }
        }
    }
    
    @MainActor var autoFocus: Bool {
        get { settings.autoFocus }
        set {
            settings.autoFocus = newValue
            
            guard let device = captureDevice else { return }
            
            do {
                try device.lockForConfiguration()
                
                if newValue {
                    // Reset any locked focus state and enable continuous auto focus
                    device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                    device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
                    
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                    }
                    if device.isExposureModeSupported(.continuousAutoExposure) {
                        device.exposureMode = .continuousAutoExposure
                    }
                } else {
                    // Switch to auto focus mode (requiring tap)
                    if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                    }
                    if device.isExposureModeSupported(.autoExpose) {
                        device.exposureMode = .autoExpose
                    }
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Error updating focus mode: \(error)")
            }
        }
    }
    
    public var minISO: Float {
        return captureDevice?.activeFormat.minISO ?? 0.0
    }

    public var maxISO: Float {
        return captureDevice?.activeFormat.maxISO ?? 0.0
    }

    public func configureExposureMode() {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            if autoExposure {
                device.exposureMode = .continuousAutoExposure
            } else {
                let currentDuration = device.exposureDuration
                device.setExposureModeCustom(duration: currentDuration, iso: manualISO)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error configuring exposure: \(error)")
        }
    }

    private func setDeviceISO(_ iso: Float) {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            let currentDuration = device.exposureDuration
            device.setExposureModeCustom(duration: currentDuration, iso: iso)
            device.unlockForConfiguration()
        } catch {
            print("Error setting ISO: \(error)")
        }
    }
    
    func toggleFlash() {
        // For video torch:
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .off {
                // Turn it on
                try device.setTorchModeOn(level: 1.0)
                isFlashOn = true
            } else {
                // Turn it off
                device.torchMode = .off
                isFlashOn = false
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }
    

    func updateFocusValueLive() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLocked(lensPosition: focusValue) { _ in }
                device.unlockForConfiguration()
            } catch {
                print("Error adjusting focus: \(error)")
            }
        }
    }
    
    func adjustFocus(to focusValue: Float) {
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.setFocusModeLocked(lensPosition: focusValue, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("Error adjusting focus: \(error)")
        }
    }
    
    private var zoomTimer: Timer?
    
    // Add to existing properties
    var captureDevice: AVCaptureDevice? {
        return currentCaptureDevice
    }
    
    func resetZoomTimer() {
        zoomTimer?.invalidate()
        //        zoomTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
        //            self?.showZoomBar = false
        //        }
    }
    
    @MainActor func switchCamera() {
        // Update to switch between front and back cameras using LensType
        if currentLens == .frontWide {
            // Switch to back camera (prefer wide if available)
            currentLens = .wide
        } else {
            // Switch to front camera
            currentLens = .frontWide
        }
        currentZoom = 1.0  // Reset zoom when switching cameras
        configureSession()
    }
    
    
    private func stitchClips() {
        print("⏳ [1] Starting stitch process")
        self.isSavingVideo = true
        
        guard let clipData = self.clipDataList.last else {
            print("❌ [1.1] No clips to stitch")
            self.showError("No video to stitch")
            return
        }
        
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            do {
                let url = clipData.url
                print("📸 Clip URL: \(url)")

                
                if !FileManager.default.fileExists(atPath: clipData.url.path) {
                    print("❌ File does not exist at \(clipData.url.path)")
                    self.showError("Clip file missing")
                    return
                }
                
                let asset = AVURLAsset(url: url)
                
                // Load tracks synchronously to ensure they exist
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                print("🎞️ Video tracks loaded: \(videoTracks.count)")
                
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)
                print("🔊 Audio tracks loaded: \(audioTracks.count)")

                guard let videoTrack = videoTracks.first,
                      let audioTrack = audioTracks.first else {
                    print("❌ Missing video/audio track")
                    await MainActor.run {
                        self.showError("Missing video/audio track")
                        self.isSavingVideo = false
                    }
                    return
                }
                
                // Get video properties
                let naturalSize = try await videoTrack.load(.naturalSize)
                let assetDuration = try await asset.load(.duration)
                let frameRate = try await videoTrack.load(.nominalFrameRate)
                
                // Create composition
                let composition = AVMutableComposition()
                
                // Create video and audio tracks
                guard let compVideoTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                ) else {
                    throw NSError(domain: "Stitching", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create video track"])
                }
                
                guard let compAudioTrack = composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                ) else {
                    throw NSError(domain: "Stitching", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create audio track"])
                }
                
                // Insert the entire video and audio tracks
                let timeRange = CMTimeRange(start: .zero, duration: assetDuration)
                try compVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
                try compAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
                
                // Create video composition
                let videoComposition = AVMutableVideoComposition()
                videoComposition.renderSize = naturalSize
                videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(frameRate))
                
                // Build segments from orientation changes
                var segments: [(range: CMTimeRange, orientation: String)] = []
                var prevTime = CMTime.zero
                
                for change in clipData.orientationChanges {
                    let time = CMTime(seconds: change.time, preferredTimescale: 600)
                    if time > prevTime {
                        segments.append((
                            range: CMTimeRange(start: prevTime, end: time),
                            orientation: change.orientation
                        ))
                        prevTime = time
                    }
                }
                
                // flip the last (its messy (crying emoji))
                var saveOrientation = "Landscape Right"
                
                if currentOrientation != "Landscape Right" {
                    saveOrientation = "Landscape Right"
                }
                else {
                    saveOrientation = "Landscape Left"
                }
                
                if let lastChange = clipData.orientationChanges.last {
                    let lastTime = CMTime(seconds: lastChange.time, preferredTimescale: 600)
                    segments.append((
                        range: CMTimeRange(start: lastTime, end: assetDuration),
                        orientation: saveOrientation
                    ))
                } else {
                    segments.append((
                        range: CMTimeRange(start: .zero, end: assetDuration),
                        orientation: self.currentOrientation
                    ))
                }
                
                // Create instructions for each segment
                var instructions: [AVMutableVideoCompositionInstruction] = []
                
                for segment in segments {
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = segment.range
                    
                    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideoTrack)
                    
                    // Apply transform based on orientation
                    if segment.orientation == "Landscape Left" {
                        let transform = CGAffineTransform(translationX: naturalSize.width/2, y: naturalSize.height/2)
                            .rotated(by: .pi)
                            .translatedBy(x: -naturalSize.width/2, y: -naturalSize.height/2)
                        layerInstruction.setTransform(transform, at: segment.range.start)
                    } else {
                        // Explicitly set identity transform for non-flipped segments
                        layerInstruction.setTransform(.identity, at: segment.range.start)
                    }
                    
                    instruction.layerInstructions = [layerInstruction]
                    instructions.append(instruction)
                }
                
                videoComposition.instructions = instructions
                
                // Export the final video
                await exportVideo(composition: composition, videoComposition: videoComposition)
                
            } catch {
                print("❌ Stitching error: \(error.localizedDescription)")
                await MainActor.run {
                    self.showError("Failed to stitch video: \(error.localizedDescription)")
                    self.isSavingVideo = false
                }
            }
        }
    }
    
    @Published private(set) var activeExports: [ExportProgress] = [] {
            didSet { saveActiveExports() }
        }
    
    @Published var showExportSheet: Bool = false
    
    // Profile info
    @MainActor var userName: String {
        get { settings.userName }
        set { settings.userName = newValue }
    }
   
    @MainActor var userEmail: String {
        get { settings.userEmail }
        set { settings.userEmail = newValue }
    }
   
    @MainActor var userDevice: String {
        get { settings.userDevice }
        set { settings.userDevice = newValue }
    }
    // Other Settings
    @MainActor var allowRecordingWhileSaving: Bool {
        get { settings.allowRecordingWhileSaving }
        set { settings.allowRecordingWhileSaving = newValue }
    }
    
    @MainActor var showQuickExport: Bool {
        get { settings.showQuickExport }
        set { settings.showQuickExport = newValue }
    }
    
    
    @MainActor var exportSheetDuration:  Double  {
        get { settings.exportSheetDuration }
        set { settings.exportSheetDuration = newValue }
    }
    
    
    func exportVideo(composition: AVMutableComposition, videoComposition: AVMutableVideoComposition) async {
            isExporting = true
            exportProgress = 0.0

            let exportId = UUID()
            let filename = getNextClipNumber()
            var entry = ExportProgress(id: exportId,
                                       filename: filename,
                                       progress: 0.0,
                                       isCompleted: false,
                                       startTime: Date())
            // Store presetName for possible restart
            entry.presetName = exportQuality.preset
            persistSession(entry)

            await MainActor.run {
                withAnimation {
                    if allowRecordingWhileSaving && showQuickExport {
                        showExportSheet = true
                    }
                }
            }

            // Begin background task
            var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        
            func startBackgroundTask() {
                backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "exportVideo") {
                    self.cleanupBackgroundTask(backgroundTaskID)
                    entry.errorMessage = "Export timed out"
                    self.persistSession(entry)
                    if self.permissionsManager.notificationsPermissionGranted {
                        self.postNotification(title: "Export Failed", body: "\(filename) export timed out.", timeSensitive: true)
                    }
                }
            }

            func endBackgroundTask() {
                if backgroundTaskID != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    backgroundTaskID = .invalid
                }
            }

            startBackgroundTask()
            
            guard let exporter = AVAssetExportSession(asset: composition, presetName: exportQuality.preset) else {
                entry.errorMessage = "Failed to create exporter"
                persistSession(entry)
                if permissionsManager.notificationsPermissionGranted {
                    postNotification(title: "Export Failed", body: "\(filename) failed to start.", timeSensitive: true)
                }
                cleanupBackgroundTask(backgroundTaskID)
                return
            }

            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("stitched-\(exportId.uuidString)")
                .appendingPathExtension("mov")

            // Metadata
            let deviceMetadata = AVMutableMetadataItem()
            deviceMetadata.keySpace = .common
            deviceMetadata.key = AVMetadataKey.commonKeyModel as (NSCopying & NSObjectProtocol)?
            deviceMetadata.value = UIDevice.modelName as (NSCopying & NSObjectProtocol)?
            let makeMetadata = AVMutableMetadataItem()
            makeMetadata.keySpace = .common
            makeMetadata.key = AVMetadataKey.commonKeyMake as (NSCopying & NSObjectProtocol)?
            makeMetadata.value = "Apple" as (NSCopying & NSObjectProtocol)?
            let softwareMetadata = AVMutableMetadataItem()
            softwareMetadata.keySpace = .common
            softwareMetadata.key = AVMetadataKey.commonKeySource as (NSCopying & NSObjectProtocol)?
            softwareMetadata.value = "GyroCam" as (NSCopying & NSObjectProtocol)?

            exporter.outputURL = outputURL
            exporter.outputFileType = .mov
            exporter.videoComposition = videoComposition
            exporter.shouldOptimizeForNetworkUse = false
            exporter.metadata = [deviceMetadata, makeMetadata, softwareMetadata]

            // Monitor progress
            let stateSeq = exporter.states(updateInterval: 0.1)
            Task.detached {
                for await state in stateSeq {
                    if case .exporting(let progress) = state {
                        entry.progress = Float(progress.fractionCompleted)
                        await MainActor.run {
                            self.exportProgress = entry.progress
                            self.persistSession(entry)
                        }
                    }
                }
            }

            do {
                try await exporter.export(to: outputURL, as: .mov)
                entry.isCompleted = true
                entry.progress = 1.0
                await MainActor.run {
                    self.persistSession(entry)
                    self.saveFinalVideo(outputURL)
                    
                }
                if permissionsManager.notificationsPermissionGranted {
                    postNotification(title: "Export Complete", body: "\(filename) exported successfully.")
                }
            } catch {
                entry.errorMessage = error.localizedDescription
                await MainActor.run {
                    self.persistSession(entry)
                    self.showError("Export failed: \(error.localizedDescription)")
                }
                if permissionsManager.notificationsPermissionGranted {
                    postNotification(title: "Export Failed", body: "\(filename) failed: \(error.localizedDescription)", timeSensitive: true)
                }
            }

            await MainActor.run {
                self.isExporting = false
                self.exportProgress = entry.progress
            }

            // Auto-remove completed entries after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + exportSheetDuration) { [weak self] in
                Task { @MainActor in
                    withAnimation {
                        self?.activeExports.removeAll(where: { $0.id == exportId && $0.isCompleted })
                    }
                    if self?.activeExports.isEmpty == true {
                        self?.showExportSheet = false
                    }
                }
            }

            cleanupBackgroundTask(backgroundTaskID)
            if activeExports.count == 0 {
                self.cleanupClips()
            }
        }

        
        func restartExport(_ entry: ExportProgress) {
            // Remove old failed entry
            DispatchQueue.main.async {
                withAnimation {
                    self.activeExports.removeAll(where: { $0.id == entry.id })
                }
            }
            // Re-run stitching pipeline
            stitchClips()
        }
    
        private let videoDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            return formatter
        }()
        
        
        @MainActor
        private func saveFinalVideo(_ url: URL) {
            
            let currentLocation = lastKnownLocation
            
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                if self.permissionsManager.locationPermissionGranted {
                    creationRequest.location = currentLocation
                }
                creationRequest.creationDate = Date()
                
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                options.originalFilename = self.getNextClipNumber()
                
                creationRequest.addResource(with: .video, fileURL: url, options: options)
                
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Successfully Saved Video")
                        try? FileManager.default.removeItem(at: url)
                        self.isSavingVideo = false
                        self.loadLatestThumbnail.toggle()
                        if let firstClip = self.clipDataList.first {
                            do {
                                try FileManager.default.removeItem(at: firstClip.url)
                                print("Deleted old clip.")
                            } catch {
                                print("Failed to delete clip file: \(error)")
                            }
                            self.clipDataList.removeFirst()
                            self.saveClipDataState()
                        }

                    } else {
                        print("Save error: \(error?.localizedDescription ?? "Unknown error")")
                        self.showError(error?.localizedDescription ?? "Failed to save video")
                    }
                }
            }
        }
    
    
    @MainActor
    private func cleanupClips() {
        print("🧹 All tasks done! Cleaninin Up Clips...")
        clearClipDataState()
        currentClipNumber = 1
        exportDuration = 0.0
    }
    
    @MainActor
    private func showError(_ message: String, type: String = "Error") {
        messageType = type
        presentMessage = message
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "appSettings") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(AppSettings.self, from: data) {
                settings = decoded
            }
        }
    }
    
    private func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "appSettings")
        }
    }
    
    @MainActor func resetToDefaults() {
        settings = AppSettings()
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        showError("Default Settings Restored", type: "Confirmation")
        configureSession()
    }
    
    override init() {
        super.init()
        
        if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            requestCameraAccess()
            requestLocationAccess()
        }
        
        loadSettings()
        loadActiveExports()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    
    }
    

    public func setupFreshStart() {
        requestCameraAccess()
        requestLocationAccess()
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor in
                if granted {
                    self?.configureSession()
                    self?.startSession()
                }
            }
        }
    }
    
    @MainActor func configureSession() {
        session.beginConfiguration()
        configureHaptics()
        defer {
            session.commitConfiguration()
            print("Session configuration committed")
        }
        
        do {
            try setupInputs()
            try setupOutputs()
            try configureDeviceFormat()
        } catch {
            showError("Session error: \(error.localizedDescription)")
        }
    }
    
    public func configureHaptics() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // get the haptics working
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
                try audioSession.setMode(.videoRecording)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                try audioSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
                print("Done configuring AVAudioSession")
            } catch {
                print("Error configuring AVAudioSession: \(error)")
            }
        }
        
        hapticsConfigured = true
    }
    
    @MainActor private func setupInputs() throws {
        session.inputs.forEach { session.removeInput($0) }
        
        guard let device = getCurrentDevice() else {
            throw NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device unavailable"])
        }
        
        currentDevice = device
        currentCaptureDevice = device
        let input = try AVCaptureDeviceInput(device: device)
        
        if session.canAddInput(input) {
            session.addInput(input)
            activeInput = input
        }
        
        
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        }
    }
    
    
    
    private func setupOutputs() throws {
        session.outputs.forEach { session.removeOutput($0) }
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
    }
    
    public func startSession() {
        guard !session.isRunning else { return }
        
        Task.detached { [weak self] in
            guard let session = await self?.session else { return }
            session.startRunning()
        }
    }
    
    public func stopSession() {
        guard session.isRunning
        else {
            print("Session not running")
            return
        }
        
        print("Killing session")
        Task.detached { [weak self] in
            guard let session = await self?.session else { return }
            session.stopRunning()
            print("Session killed")
        }
        hapticsConfigured = false
    }
    
    @MainActor private func getCurrentDevice() -> AVCaptureDevice? {
        let deviceType = currentLens.deviceType
        let position = currentLens.position
        
        // Attempt to get the selected lens
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
            // Fall back to wide angle if unavailable
            let fallbackLens: LensType = position == .front ? .frontWide : .wide
            let fallbackDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
            
            DispatchQueue.main.async {
                if self.currentLens != fallbackLens {
                    self.currentLens = fallbackLens
                }
            }
            return fallbackDevice
        }
        return device
    }
    
    @MainActor var availableLenses: [LensType] {
        var lenses: [LensType] = []
        
        // Check front camera
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil {
            lenses.append(.frontWide)
        }
        
        // Check back cameras
        if AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil {
            lenses.append(.ultraWide)
        }
        
        // Wide angle
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil {
            lenses.append(.wide)
        }
        
        if AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil {
            lenses.append(.telephoto)
        }

        return lenses
    }

    
    @MainActor var availableFrameRates: [FrameRate] {
        guard let device = currentDevice else { return [] }
        
        var supportedRates: Set<FrameRate> = []
        
        // Check each format for supported frame rates
        for format in device.formats {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let currentDimensions = currentFormat.resolution
            
            // Only consider formats matching our current resolution
            guard dimensions.width == currentDimensions.width &&
                    dimensions.height == currentDimensions.height else {
                continue
            }
            
            // Get the maximum frame rate for this format
            let maxRate = Int(format.maxFrameRate)
            
            // Add all supported frame rates up to the maximum
            FrameRate.allCases.forEach { frameRate in
                if frameRate.rawValue <= maxRate {
                    supportedRates.insert(frameRate)
                }
            }
        }
        
        // Return sorted array of supported rates
        return Array(supportedRates).sorted()
    }
    
    private func mapStabilizationMode(_ mode: StabilizationMode) -> AVCaptureVideoStabilizationMode {
        switch mode {
        case .off: return .off
        case .standard: return .standard
        case .cinematic: return .cinematic
        case .cinematicExtended: return .cinematicExtended
        case .auto: return .auto
        }
    }
    
    @MainActor private func configureDeviceFormat() throws {
        guard let device = currentDevice else { return }
        
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        
        let targetFormat = try findBestFormat(for: device)
        device.activeFormat = targetFormat
        
        // Get supported frame rate ranges for the active format
        let supportedRanges = targetFormat.videoSupportedFrameRateRanges
        let maxSupportedFPS = supportedRanges.map { $0.maxFrameRate }.max() ?? 30
        let minSupportedFPS = supportedRanges.map { $0.minFrameRate }.min() ?? 30
        
        // Determine the actual FPS to set
        let desiredFPS = currentFPS.rawValue
        var actualFPS = desiredFPS
        
        if Double(desiredFPS) > maxSupportedFPS {
            actualFPS = Int(maxSupportedFPS)
        } else if Double(desiredFPS) < minSupportedFPS {
            actualFPS = Int(minSupportedFPS)
        }
        
        // Update currentFPS if necessary to reflect actual value
        if actualFPS != desiredFPS {
            DispatchQueue.main.async {
                self.currentFPS = FrameRate(rawValue: actualFPS) ?? .thirty
            }
        }
        
        let frameDuration = CMTimeMake(value: 1, timescale: Int32(actualFPS))
        device.activeVideoMinFrameDuration = frameDuration
        device.activeVideoMaxFrameDuration = frameDuration
    }
    
    @MainActor private func findBestFormat(for device: AVCaptureDevice) throws -> AVCaptureDevice.Format {
        let targetResolution = currentFormat.resolution
        let targetFPS = currentFPS.rawValue
        
        return device.formats
            .filter { format in
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                let hasHDR = isHDREnabled ? format.supportedColorSpaces.contains(.HLG_BT2020) : true
                return dimensions.width == targetResolution.width &&
                dimensions.height == targetResolution.height &&
                format.maxFrameRate >= Double(targetFPS) &&
                hasHDR
            }
            .sorted { $0.maxFrameRate > $1.maxFrameRate }
            .first ?? device.activeFormat
    }
    
    @MainActor func switchLens(_ lens: LensType) {
        guard availableLenses.contains(lens) else {
            showError("Selected lens is not allowed on this device.")
            return }
        currentLens = lens
        configureSession()
    }
    
    @MainActor func startOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            showError("Motion data unavailable")
            return
        }
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            guard let motion = motion, error == nil else {
                self.showError(error?.localizedDescription ?? "Motion updates failed")
                return
            }
            let newOrientation = OrientationHelper.getOrientation(from: motion, currentOrientation: self.previousOrientation, cameraManager: self)
            if newOrientation != self.previousOrientation && newOrientation != .unknown {
                self.handleOrientationChange(newOrientation: newOrientation)
                self.previousOrientation = newOrientation
            }
            DispatchQueue.main.async {
                self.currentOrientation = newOrientation.description
                self.updateVideoOrientation(newOrientation)
            }
        }
    }
    
    @MainActor
    private func updateVideoOrientation(_ orientation: UIDeviceOrientation) {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        guard let connection = movieOutput.connection(with: .video),
              let device = currentCaptureDevice else { return }

        // Initialize the rotation coordinator with the current device
        let rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)

        // Retrieve the rotation angle for horizon-level capture
        let angle = rotationCoordinator.videoRotationAngleForHorizonLevelCapture

        // Check if the angle is supported and apply it
        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }

        // Set video mirroring if supported
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = (currentLens == .frontWide)
        }
    }

    
    public func triggerHaptic(strength: RotationHapticStrength) {
        if !hapticsConfigured {
            configureHaptics()
        }
        let generator = UIImpactFeedbackGenerator(style: strength.feedbackStyle)
        generator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
    
    private func saveActiveExports() {
           if let data = try? JSONEncoder().encode(activeExports) {
               savedExportsData = data
           }
       }

    private func loadActiveExports() {
            guard let data = savedExportsData,
                  let exports = try? JSONDecoder().decode([ExportProgress].self, from: data)
            else { return }
            // Mark any previously in-progress exports as failed due to app termination
            let updatedExports = exports.map { exp -> ExportProgress in
                var e = exp
                if !e.isCompleted {
                    e.errorMessage = e.errorMessage ?? "Export interrupted"
                }
                return e
            }
            activeExports = updatedExports
            saveActiveExports()
            loadClipDataState()
        }

        private func saveClipDataState() {
            if let data = try? JSONEncoder().encode(clipDataList) {
                UserDefaults.standard.set(data, forKey: clipDataKey)
            }
        }

        private func loadClipDataState() {
            guard let data = UserDefaults.standard.data(forKey: clipDataKey),
                  let list = try? JSONDecoder().decode([ClipData].self, from: data)
            else { return }
            clipDataList = list
        }

        private func clearClipDataState() {
            UserDefaults.standard.removeObject(forKey: clipDataKey)
        }
        
    
       private func postNotification(title: String, body: String, timeSensitive: Bool = false) {
           let content = UNMutableNotificationContent()
           content.title = title
           content.body = body
           content.sound = .default
           if timeSensitive {
               content.interruptionLevel = .timeSensitive
           }
           let request = UNNotificationRequest(
               identifier: UUID().uuidString,
               content: content,
               trigger: nil
           )
           UNUserNotificationCenter.current().add(request)
       }

       private func cleanupBackgroundTask(_ id: UIBackgroundTaskIdentifier) {
           UIApplication.shared.endBackgroundTask(id)
       }

       private func persistSession(_ entry: ExportProgress) {
           if !activeExports.contains(where: { $0.id == entry.id }) {
               activeExports.append(entry)
           } else if let idx = activeExports.firstIndex(where: { $0.id == entry.id }) {
               activeExports[idx] = entry
           }
       }
    
    @MainActor
    private func handleOrientationChange(newOrientation: UIDeviceOrientation) {

        // play the associated haptic
        if self.playHaptics && (self.rotationHaptics == .always || (self.rotationHaptics == .recording && self.isRecording)) {
            triggerHaptic(strength: rotationHapticsStrength)
        }
        
        guard isRecording else { return }
        
        if shouldStitchClips {
            // Log orientation change with timestamp
            let elapsedTime = Date().timeIntervalSince(recordingStartTime!)
            let newOrientationDesc = newOrientation.description
            orientationChanges.append((OrientationChange(time: elapsedTime - 0.15, orientation: newOrientationDesc)))
            print("Orientation changed to \(newOrientationDesc) at \(elapsedTime)s")
        } else {
            recordingQueue.async { [weak self] in
                guard let self = self else { return }

                Task { @MainActor in
                    guard !self.isRestarting else { return }
                    self.isRestarting = true

                    self.stopRecording { [weak self] in
                        guard let self = self else { return }
                        self.currentClipNumber += 1
                        self.startRecording()
                        self.isRestarting = false
                        print("♻️ Restarted recording as clip #\(self.currentClipNumber)")
                    }
                }
            }
        }
    }

    
    @MainActor
    func startRecording() {
        stitchingGroup = DispatchGroup()
        recordingStartTime = Date()
        orientationChanges.removeAll()

        if !isRestarting {
            durationTimer?.invalidate()
            videoDuration = 0.0
            
            // Start the timer to update every 0.01 seconds
            durationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.videoDuration += 0.01
                }
            }
        }
        
       // Record initial orientation
       let initialOrientation = previousOrientation.description
        orientationChanges.append((OrientationChange(time: 0.0, orientation: initialOrientation)))
       if playSounds {
            AudioServicesPlaySystemSound(1117)
        }
        
        stitchingGroup?.enter()
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        if permissionsManager.locationPermissionGranted {
            startLocationUpdates()
        }
        print("▶️ Started recording clip #\(currentClipNumber)")
        print("Starting recording with orientation: \(self.previousOrientation.description)")
    }
    
    @MainActor func stopRecording(completion: (() -> Void)? = nil) {
        stopCompletion = completion
        stopLocationUpdates()
        movieOutput.stopRecording()
        isRecording = false
        
        
        if !isRestarting {
            durationTimer?.invalidate()
            videoDuration = 0.0
            
            stitchingGroup?.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                if self.shouldStitchClips && !self.clipDataList.isEmpty {
                    self.stitchClips()
                }
                else {
                    currentClipNumber = 1
                }
                self.stitchingGroup = nil
            }
            if playSounds {
                AudioServicesPlaySystemSound(1118)
            }
        }
        print("⏹ Stopped recording clip #\(currentClipNumber)")
    }
}

extension CameraManager: @preconcurrency AVCaptureFileOutputRecordingDelegate {
    private func getNextClipNumber() -> String {
        let defaults = UserDefaults.standard
        let currentNumber = defaults.integer(forKey: "GyroCamClipNumber")
        defaults.set(currentNumber + 1, forKey: "GyroCamClipNumber")
        return String(format: "GRC_%02d", currentNumber)
    }
    
    @MainActor
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Immediately trigger completion to allow next recording
        stopCompletion?()
        stopCompletion = nil
        
        if let error = error {
            showError("Recording failed: \(error.localizedDescription)")
        }
        
        if shouldStitchClips {
            DispatchQueue.main.async {
                self.clipDataList.append(ClipData(id: UUID(), url: outputFileURL, orientationChanges: self.orientationChanges))
            }
        } else {
            saveFinalVideo(outputFileURL)
        }
        
        self.stitchingGroup?.leave()
    }
}


extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

extension AVCaptureDevice.Format {
    var maxFrameRate: Double {
        videoSupportedFrameRateRanges
            .compactMap { $0.maxFrameRate }
            .max() ?? 0
    }
}

// Location
extension CameraManager: @preconcurrency CLLocationManagerDelegate {
    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationAuthorizationStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location
    }

    @MainActor
    func startLocationUpdates() {
        
        // Check the authorization status to avoid unresponsivness
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showError("Location services restricted or denied")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            showError("Unknown location authorization status")
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}
