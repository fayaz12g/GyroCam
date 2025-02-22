import AVFoundation
import CoreMotion
import UIKit
import Photos
import SwiftUI
import CoreLocation

@MainActor
class CameraManager: NSObject, ObservableObject {
    
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let motionManager = CMMotionManager()
    private var currentDevice: AVCaptureDevice?
    private var activeInput: AVCaptureDeviceInput?
    private var stopCompletion: (() -> Void)?
    var orientations: [String] = [] // delete this later
    private var recordingStartTime: Date?
    private var orientationChanges: [(time: TimeInterval, orientation: String)] = []
    
    public var loadLatestThumbnail: Bool = false
    
    private var clipURLs: [URL] = []
    private var stitchingGroup: DispatchGroup?
    
    // location
    private let locationManager = CLLocationManager()
    private var lastKnownLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // New rotation method
    @MainActor private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var activeCameraDevice: AVCaptureDevice? {
        return activeInput?.device
    }
    
    enum StabilizationMode: String, CaseIterable, Codable {
        case off = "0"
        case standard = "1"
        case cinematic = "2"
        case cinematicExtended = "3"
        case auto = "Auto"
    }
    
    
    enum ShutterSpeed: CaseIterable {
        case speed1_1000
        case speed1_500
        case speed1_250
        case speed1_125
        case speed1_60
        case speed1_48
        case speed1_15
        case speed1_8
        case speed1_4
        case speed1_2
        case speed1
        
        var cmTime: CMTime {
            let seconds: Double
            switch self {
            case .speed1_1000: seconds = 1/1000
            case .speed1_500: seconds = 1/500
            case .speed1_250: seconds = 1/250
            case .speed1_125: seconds = 1/125
            case .speed1_60: seconds = 1/60
            case .speed1_48: seconds = 1/48
            case .speed1_15: seconds = 1/15
            case .speed1_8: seconds = 1/8
            case .speed1_4: seconds = 1/4
            case .speed1_2: seconds = 1/2
            case .speed1: seconds = 1
            }
            return CMTime(seconds: seconds, preferredTimescale: 1000000)
        }
        
        var description: String {
            switch self {
            case .speed1_1000: return "1/1000"
            case .speed1_500: return "1/500"
            case .speed1_250: return "1/250"
            case .speed1_125: return "1/125"
            case .speed1_60: return "1/60"
            case .speed1_48: return "1/48"
            case .speed1_15: return "1/15"
            case .speed1_8: return "1/8"
            case .speed1_4: return "1/4"
            case .speed1_2: return "1/2"
            case .speed1: return "1"
            }
        }
    }
    
    // Main actor isolated properties
    // Main properties
    
    
    @Published var focusValue: Float = 0.5 // Initial value
    
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
    
    @MainActor var stabilizeVideo: CameraManager.StabilizationMode {
        get { settings.stabilizeVideo }
        set { settings.stabilizeVideo = newValue }
    }
    
    @MainActor var currentFormat: CameraManager.VideoFormat {
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
    
    @MainActor var showRecordingTimer: Bool {
        get { settings.showRecordingTimer }
        set { settings.showRecordingTimer = newValue }
    }
    
    @MainActor var showQuickSettings: Bool {
        get { settings.showQuickSettings }
        set { settings.showQuickSettings = newValue }
    }
    
    @MainActor var showZoomBar: Bool {
        get { settings.showZoomBar }
        set { settings.showZoomBar = newValue }
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
    
    
    @MainActor var maximizePreview: Bool {
        get { settings.maximizePreview }
        set { settings.maximizePreview = newValue }
    }
    
    @MainActor var accentColor: Color {
        get { settings.accentColor }
        set { settings.accentColor = newValue }
    }
    
    @MainActor var autoExposure: Bool {
        get { settings.autoExposure }
        set {
            settings.autoExposure = newValue
            configureSession()
        }
    }
    
    @MainActor var manualISO: Float {
        get { settings.manualISO }
        set {
            settings.manualISO = newValue
            updateExposureSettings()
        }
    }
    
    @MainActor var manualShutterSpeed: CMTime? {
        get { CMTime(seconds: settings.manualShutterSpeed, preferredTimescale: 1/60) }
        set {
            settings.manualShutterSpeed = newValue.map(CMTimeGetSeconds) ?? (1/60)
            updateExposureSettings()
        }
    }
    
    
    @MainActor var isFlashOn: Bool {
        get { settings.isFlashOn }
        set { settings.isFlashOn = newValue }
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
    
    private func updateExposureSettings() {
        guard !autoExposure,
              let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            if device.isExposureModeSupported(.custom) {
                device.exposureMode = .custom
                device.setExposureModeCustom(
                    duration: manualShutterSpeed ?? CMTime(seconds: 1/60, preferredTimescale: 1000000),
                    iso: manualISO,
                    completionHandler: nil
                )
            }
            device.unlockForConfiguration()
        } catch {
            print("Error updating exposure settings: \(error)")
        }
    }
    
    
    
    @MainActor @Published var isRecording = false
    @MainActor @Published var currentOrientation = "Portrait"
    @MainActor @Published var errorMessage = ""
    @MainActor @Published var currentClipNumber = 1
    private var currentCaptureDevice: AVCaptureDevice?
    
    
    @Published var currentZoom: CGFloat = 1.0
    
    // Published wrapper for settings
    @Published private var settings = AppSettings() {
        didSet {
            saveSettings()
        }
    }
    
    
    
    // Camera Control Elements
    
    
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
    
    // Orientation handling
    private var previousOrientation: UIDeviceOrientation = .portrait
    private let recordingQueue = DispatchQueue(label: "recording.queue")
    public var isRestarting = false
    
    enum LensType: String, CaseIterable {
        case frontWide = "Front"
        case ultraWide = "0.5x"
        case wide = "1x"
        case telephoto = "3x"
        
        var deviceType: AVCaptureDevice.DeviceType {
            switch self {
            case .frontWide:
                return .builtInWideAngleCamera
            case .ultraWide:
                return .builtInUltraWideCamera
            case .wide:
                return .builtInWideAngleCamera
            case .telephoto:
                return .builtInTelephotoCamera
            }
        }
        
        var position: AVCaptureDevice.Position {
            switch self {
            case .frontWide:
                return .front
            default:
                return .back
            }
        }}
    
    
    
    enum VideoFormat: String, CaseIterable {
        case hd4K = "4K"
        case hd1080p = "1080p"
        
        var resolution: CMVideoDimensions {
            switch self {
            case .hd4K: return CMVideoDimensions(width: 3840, height: 2160)
            case .hd1080p: return CMVideoDimensions(width: 1920, height: 1080)
            }
        }
    }
    
    
    private func calculateRenderSize(baseOrientation: String, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        if baseOrientation == "Portrait" {
            return CGSize(width: min(maxWidth, maxHeight),
                        height: max(maxWidth, maxHeight))
        }
        return CGSize(width: max(maxWidth, maxHeight),
                    height: min(maxWidth, maxHeight))
    }
    
    
    private func stitchClips() {
        print("⏳ Starting stitch process...")
        print("📐 Base orientation: \(self.orientationChanges.first?.orientation ?? "unknown")")
        self.isSavingVideo = true
        guard let clipURL = self.clipURLs.first else {
            self.showError("No video to stitch")
            return
        }
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let asset = AVURLAsset(url: clipURL)
            guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first else {
                self.showError("No video track found")
                return
            }
            
            // Get video properties
            let originalTransform = try await videoTrack.load(.preferredTransform)
            let naturalSize = try await videoTrack.load(.naturalSize)
            let assetDuration = try await asset.load(.duration)
            
            // Log original video properties
           print("📏 Natural size: \(naturalSize)")
           print("🔄 Original transform: \(originalTransform)")
           print("⏱ Total duration: \(CMTimeGetSeconds(assetDuration))s")
            
            // Determine base orientation from initial change
            let baseOrientation = self.orientationChanges.first?.orientation ?? "Portrait"
            let outputSize = self.calculateOutputSize(baseOrientation: baseOrientation, naturalSize: naturalSize)
            
            // Log output size
           print("🎯 Target output size: \(outputSize)")
            
            
            // Create composition
            let composition = AVMutableComposition()
            guard let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                self.showError("Failed to create composition track")
                return
            }
            
            // Insert entire video into composition
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: assetDuration),
                of: videoTrack,
                at: .zero
            )
            
            // Prepare video composition instructions
            let videoComposition = AVMutableVideoComposition()
            var instructions: [AVMutableVideoCompositionInstruction] = []
            var previousTime = CMTime.zero
            
            // Log orientation changes
            print("🧭 Orientation changes:")
            self.orientationChanges.forEach { print("- \($0.time)s: \($0.orientation)") }
            
            // Process each orientation segment
            for i in 0..<self.orientationChanges.count {
                let currentChange = self.orientationChanges[i]
                let nextTime = (i < self.orientationChanges.count - 1) ?
                    CMTime(seconds: self.orientationChanges[i+1].time, preferredTimescale: 600) :
                    assetDuration
                
                let timeRange = CMTimeRange(start: previousTime, end: nextTime)
                let orientation = currentChange.orientation
                
                // Calculate transform for this segment
                let transform = self.calculateSegmentTransform(
                    originalTransform: originalTransform,
                    naturalSize: naturalSize,
                    segmentOrientation: orientation,
                    baseOrientation: baseOrientation,
                    outputSize: outputSize
                )
                
                // Create instruction
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = timeRange
                
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                layerInstruction.setTransform(transform, at: .zero)
                instruction.layerInstructions = [layerInstruction]
                
                instructions.append(instruction)
                previousTime = nextTime
                
                print("✂️ Segment \(i+1):")
                print("   ⌚️ Time range: \(CMTimeGetSeconds(timeRange.start))s - \(CMTimeGetSeconds(timeRange.end))s")
                print("   🧭 Orientation: \(orientation)")
                print("   ➡️ Transform: \(transform)")
            }
            
            videoComposition.instructions = instructions
            videoComposition.renderSize = outputSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            
            // Log final video composition
            print("🎞 Video composition:")
            print("   📏 Render size: \(videoComposition.renderSize)")
            print("   📜 Instructions count: \(videoComposition.instructions.count)")
            
            // Configure exporter
            guard let exporter = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality
            ) else {
                self.showError("Export session creation failed")
                return
            }
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("stitched-\(UUID().uuidString)")
                .appendingPathExtension("mov")
            
            exporter.outputURL = outputURL
            exporter.outputFileType = .mov
            exporter.videoComposition = videoComposition
            
            print("🛠 Exporter configuration:")
            print("   📏 Render size: \(videoComposition.renderSize)")
            print("   🎞 Video composition: \(exporter.videoComposition != nil ? "SET" : "MISSING")")
            print("   📁 Output URL: \(outputURL)")
            
            // Export
            await exporter.export()
            
            if exporter.status == .completed {
                self.saveFinalVideo(outputURL)
                self.cleanupClips()
            } else {
                self.showError("Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func calculateOutputSize(baseOrientation: String, naturalSize: CGSize) -> CGSize {
        let isBaseLandscape = baseOrientation.contains("Landscape")
        let baseWidth = isBaseLandscape ?
            max(naturalSize.width, naturalSize.height) :
            min(naturalSize.width, naturalSize.height)
        let baseHeight = isBaseLandscape ?
            min(naturalSize.width, naturalSize.height) :
            max(naturalSize.width, naturalSize.height)
        
        // Ensure even dimensions for video encoder compatibility
        return CGSize(
            width: (Int(baseWidth) % 2 == 0) ? baseWidth : baseWidth + 1,
            height: (Int(baseHeight) % 2 == 0) ? baseHeight : baseHeight + 1
        )
    }

    private func calculateSegmentTransform(
        originalTransform: CGAffineTransform,
        naturalSize: CGSize,
        segmentOrientation: String,
        baseOrientation: String,
        outputSize: CGSize
    ) -> CGAffineTransform {
        // 1. Calculate needed rotation
        let rotationAngle = rotationBetween(segmentOrientation, baseOrientation)
        
        // 2. Create rotation transform
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        // 3. Combine with original transform
        var transform = originalTransform.concatenating(rotationTransform)
        
        // 4. Calculate scale to fill output size while maintaining aspect ratio
        let transformedSize = naturalSize.applying(transform)
        let scale = min(
            outputSize.width / abs(transformedSize.width),
            outputSize.height / abs(transformedSize.height)
        )
        
        // 5. Apply scaling centered in frame
        transform = transform.scaledBy(x: scale, y: scale)
        
        // 6. Calculate translation to center in output frame
        let translatedSize = naturalSize.applying(transform)
        let xOffset = (outputSize.width - translatedSize.width) / 2
        let yOffset = (outputSize.height - translatedSize.height) / 2
        
        return transform.translatedBy(x: xOffset, y: yOffset)
    }

    private func rotationBetween(_ from: String, _ to: String) -> CGFloat {
        let orientationMap: [String: CGFloat] = [
            "Portrait": 0,
            "LandscapeRight": .pi/2,
            "LandscapeLeft": -.pi/2,
            "PortraitUpsideDown": .pi
        ]
        
        guard let fromAngle = orientationMap[from],
              let toAngle = orientationMap[to] else { return 0 }
        
        // Calculate shortest rotation path
        let rotation = toAngle - fromAngle
        return rotation
    }

    

    private func scaleTransform(_ transform: CGAffineTransform, naturalSize: CGSize, outputSize: CGSize) -> CGAffineTransform {
        // Calculate scale to fill output size
        let scaledSize = naturalSize.applying(transform)
        let scaleX = outputSize.width / scaledSize.width
        let scaleY = outputSize.height / scaledSize.height
        let scale = min(scaleX, scaleY)
        return transform.scaledBy(x: scale, y: scale)
    }
    
    private let videoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
    
    // Calculate rotation needed between two orientations
    private func rotationBetween(_ target: UIImage.Orientation, _ source: UIImage.Orientation) -> CGFloat {
        let rotationMap: [UIImage.Orientation: CGFloat] = [
            .up: 0,
            .right: .pi/2,
            .down: .pi,
            .left: 3 * .pi/2
        ]
        
        let sourceAngle = rotationMap[source] ?? 0
        let targetAngle = rotationMap[target] ?? 0
        return targetAngle - sourceAngle
    }
    
    // Calculate scale to fill target size while maintaining aspect ratio
    private func scaleToFill(sourceSize: CGSize, targetSize: CGSize) -> CGSize {
        let widthRatio = targetSize.width / sourceSize.width
        let heightRatio = targetSize.height / sourceSize.height
        let scale = max(widthRatio, heightRatio)
        return CGSize(width: scale, height: scale)
    }
    
    @MainActor
    private func saveFinalVideo(_ url: URL) {
        PHPhotoLibrary.shared().performChanges {
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            options.originalFilename = "GRC-\(self.videoDateFormatter.string(from: Date()))"
            
            PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: url, options: options)
            
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Successfully saved stitched video")
                    try? FileManager.default.removeItem(at: url)
                    self.isSavingVideo = false
                } else {
                    print("Save error: \(error?.localizedDescription ?? "Unknown error")")
                    self.errorMessage = error?.localizedDescription ?? "Failed to save video"
                }
            }
        }
    }
    
    @MainActor
    private func cleanupClips() {
        clipURLs.forEach { try? FileManager.default.removeItem(at: $0) }
        clipURLs.removeAll()
        orientationChanges.removeAll()
        currentClipNumber = 1
    }
    
    @MainActor
    private func showError(_ message: String) {
        errorMessage = message
        //        isExporting = false
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
        settings.accentColor = Color(red: 1.0, green: 0.0, blue: 0.05098) // #FF000D
        configureSession()
    }
    
    override init() {
        super.init()
        
        if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            requestCameraAccess()
            requestLocationAccess()
        }
        
        loadSettings()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update every 5 meters
        
    }
    
    public func setupFreshStart() {
        requestCameraAccess()
        requestLocationAccess()
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.configureSession()
                    self?.startSession()
                }
            }
        }
    }
    
    @MainActor
    private func setErrorMessage(_ message: String) {
        errorMessage = message
    }
    
    
    @MainActor func configureSession() {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
            //            print("Active Stabilization: \(activeVideoStabilizationMode)")
            print("Session configuration committed")
        }
        
        do {
            try setupInputs()
            try setupOutputs()
            try configureDeviceFormat()
        } catch {
            setErrorMessage("Session error: \(error.localizedDescription)")
        }
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
    
    private func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.main.async { [weak self] in
            self?.session.startRunning()
        }
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
        
        // Wide angle is typically always available on back
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil {
            lenses.append(.wide)
        }
        
        // Check telephoto
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
        
        // Check if the stabilization mode is supported
        if device.activeFormat.isVideoStabilizationModeSupported(mapStabilizationMode(stabilizeVideo)) {
            print("Stabilization mode \(stabilizeVideo.rawValue) is supported.")
        } else {
            print("Stabilization mode \(stabilizeVideo.rawValue) is NOT supported.")
        }
        
        
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
        
        return try device.formats
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
            setErrorMessage("Selected lens is unavailable")
            return
        }
        print("Lens switching detected. Switching from:")
        print(currentLens)
        print("To target lens:")
        print(lens)
        currentLens = lens
        print("Successfully switched to:")
        print(currentLens)
        configureSession()
    }
    
    @MainActor func startOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            setErrorMessage("Motion data unavailable")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            guard let motion = motion, error == nil else {
                self.setErrorMessage(error?.localizedDescription ?? "Motion updates failed")
                return
            }
            
            let newOrientation = OrientationHelper.getOrientation(from: motion, lockLandscape: lockLandscape, currentOrientation: self.previousOrientation)
            
            if newOrientation != self.previousOrientation && newOrientation != .unknown {
                self.handleOrientationChange(newOrientation: newOrientation)
                self.previousOrientation = newOrientation
            }
            
            DispatchQueue.main.async {
                self.currentOrientation = newOrientation.description
            }
        }
    }
    
    @MainActor private func handleOrientationChange(newOrientation: UIDeviceOrientation) {
        guard isRecording else { return }
        
        if shouldStitchClips {
            // Log orientation change with timestamp
            let elapsedTime = Date().timeIntervalSince(recordingStartTime!)
            let newOrientationDesc = newOrientation.description
            orientationChanges.append((time: elapsedTime, orientation: newOrientationDesc))
            print("Orientation changed to \(newOrientationDesc) at \(elapsedTime)s")
        } else {
            recordingQueue.async { [weak self] in
                guard let self = self, !self.isRestarting else { return }
                self.isRestarting = true
                DispatchQueue.main.async { // Ensure main thread
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
    
    @MainActor func startRecording() {
        if !isRestarting {
            stitchingGroup = DispatchGroup()
           recordingStartTime = Date()
           orientationChanges.removeAll()
           // Record initial orientation
           let initialOrientation = previousOrientation.description
           orientationChanges.append((time: 0.0, orientation: initialOrientation))
            AudioServicesPlaySystemSound(1117)
        } else {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        stitchingGroup?.enter()
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        //        startLocationUpdates()
        print("▶️ Started recording clip #\(currentClipNumber)")
        print("Starting recording with orientation: \(self.previousOrientation.description)")
        if self.shouldStitchClips {
            DispatchQueue.main.async {
                self.orientations.append(self.previousOrientation.description)
                print("Orientations array as follows:")
                print(self.orientations)
            }
        }
    }
    
    @MainActor func stopRecording(completion: (() -> Void)? = nil) {
        stopCompletion = completion
        stopLocationUpdates()
        movieOutput.stopRecording()
        isRecording = false
        
        
        if !isRestarting {
            stitchingGroup?.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                if self.shouldStitchClips && !self.clipURLs.isEmpty {
                    self.stitchClips()
                }
                else {
                    currentClipNumber = 1
                }
                self.stitchingGroup = nil
            }
        }
        
        print("⏹ Stopped recording clip #\(currentClipNumber)")
        
        if !isRestarting {
            AudioServicesPlaySystemSound(1118)
        }
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
                self.errorMessage = "Recording failed: \(error.localizedDescription)"
            }
            
        if self.shouldStitchClips {
            DispatchQueue.main.async {
                self.clipURLs.append(outputFileURL)
            }
        } else {
            
            // Capture necessary data for background processing
            let clipName = getNextClipNumber()
            let metadata = [
                "CreatedByApp": "GyroCam",
                "LensType": currentLens.rawValue,
                "Resolution": currentFormat.rawValue,
                "FPS": currentFPS.rawValue,
                "HDREnabled": isHDREnabled,
                "DeviceModel": UIDevice.current.modelName,
                "GPSHorizontalAccuracy": lastKnownLocation?.horizontalAccuracy ?? 0,
                "GPSAltitude": lastKnownLocation?.altitude ?? 0
            ] as [String : Any]
            
            // Move saving to background queue
            DispatchQueue.global(qos: .background).async { [weak self] in
                // Store metadata externally if needed
                print("Metadata for clip \(clipName): \(metadata)")
                
                // Perform photo library operations on main thread
                DispatchQueue.main.async {
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized else {
                            self?.setErrorMessage("Photo library access denied")
                            return
                        }
                        
                        PHPhotoLibrary.shared().performChanges({
                            let options = PHAssetResourceCreationOptions()
                            options.originalFilename = clipName
                            options.shouldMoveFile = true
                            
                            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)?.placeholderForCreatedAsset
                        }) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    try? FileManager.default.removeItem(at: outputFileURL)
                                    print("✅ Saved \(clipName)")
                                    self?.loadLatestThumbnail.toggle()
                                } else {
                                    self?.setErrorMessage(error?.localizedDescription ?? "Save failed")
                                }
                            }
                        }
                    }
                }
            }
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
    
    @MainActor func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            setErrorMessage("Location services unavailable")
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

