import AVFoundation
import CoreMotion
import UIKit
import Photos
import SwiftUI
import CoreLocation


enum FrameRate: Int, CaseIterable, Identifiable, Comparable {
    case twenty_four = 24
    case thirty = 30
    case sixty = 60
    case oneHundredTwenty = 120
    case twoHundredForty = 240
    
    var id: Int { rawValue }
    var description: String { "\(rawValue)fps" }
    
    static func < (lhs: FrameRate, rhs: FrameRate) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}


@MainActor
class CameraManager: NSObject, ObservableObject {
    
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let motionManager = CMMotionManager()
    private var currentDevice: AVCaptureDevice?
    private var activeInput: AVCaptureDeviceInput?
    private var stopCompletion: (() -> Void)?
    
    public var loadLatestThumbnail: Bool = false
    
    private var clipURLs: [URL] = []
    private var stitchingGroup: DispatchGroup?
    
    // location
    private let locationManager = CLLocationManager()
    private var lastKnownLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    
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
    
    
    private func stitchClips() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self, !self.clipURLs.isEmpty else { return }
            let clips = self.clipURLs
            // 1. Determine base orientation from first clip
            let firstAsset = AVURLAsset(url: self.clipURLs[0])
            guard let firstVideoTrack = try? await firstAsset.loadTracks(withMediaType: .video).first else {
                self.showError("Failed to load first clip")
                return
            }
            
            let baseTransform = try await firstVideoTrack.load(.preferredTransform)
            let baseSize = try await firstVideoTrack.load(.naturalSize)
            let baseOrientation = orientationFromTransform(baseTransform)
            let isPortrait = baseOrientation.isPortrait
            
            // 2. Create composition with base orientation
            let composition = AVMutableComposition()
            let videoTracks = clips.compactMap { AVAsset(url: $0).tracks(withMediaType: .video).first }
            
            guard let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                self.showError("Failed to create video track")
                return
            }
            
            // 3. Create video composition instructions
            let videoComposition = AVMutableVideoComposition()
            let instructions = try await createLayerInstructions(
                clips: self.clipURLs,
                baseOrientation: baseOrientation.orientation,
                baseSize: baseSize,
                compositionTrack: compositionVideoTrack
            )
            
            // 4. Configure video composition
            videoComposition.instructions = instructions
            videoComposition.renderSize = isPortrait ?
                CGSize(width: baseSize.height, height: baseSize.width) :
                baseSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            
            // 5. Export configuration
            guard let exporter = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality
            ) else {
                self.showError("Failed to create exporter")
                return
            }
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("stitched-\(UUID().uuidString)")
                .appendingPathExtension("mp4")
            
            exporter.outputURL = outputURL
            exporter.outputFileType = .mp4
            exporter.videoComposition = videoComposition
            
            // 6. Perform export
            await exporter.export()
            
            switch exporter.status {
            case .completed:
                self.saveFinalVideo(outputURL)
                self.cleanupClips()
            case .failed:
                self.showError("Export failed: \(exporter.error?.localizedDescription ?? "")")
            default: break
            }
        }
    }

    // Orientation helper function
    private func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        let assetAngle = atan2(transform.b, transform.a)
        let angleDegrees = abs(assetAngle * CGFloat(180) / .pi)
        
        switch angleDegrees {
        case 0:    return (.up, false)
        case 90:   return (.right, true)
        case 180:  return (.down, false)
        case 270:  return (.left, true)
        default:    return (.up, false)
        }
    }

    
    // Create layer instructions for all clips
    private func createLayerInstructions(clips: [URL],
                                       baseOrientation: UIImage.Orientation,
                                       baseSize: CGSize,
                                       compositionTrack: AVMutableCompositionTrack) async throws -> [AVVideoCompositionInstructionProtocol] {
        var instructions: [AVMutableVideoCompositionInstruction] = []
        var currentTime = CMTime.zero
        
        for (_, url) in clips.enumerated() {
            let asset = AVURLAsset(url: url)
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else { continue }
            
            let clipTransform = try await videoTrack.load(.preferredTransform)
            let clipSize = try await videoTrack.load(.naturalSize)
            let clipOrientation = orientationFromTransform(clipTransform)
            
            // Calculate required rotation
            let rotationAngle = rotationBetween(baseOrientation, clipOrientation.orientation)
            let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
            
            // Calculate scaling to maintain aspect ratio
            let scale = scaleToFill(
                sourceSize: clipSize.applying(clipTransform).applying(rotationTransform),
                targetSize: baseSize
            )
            let scaleTransform = CGAffineTransform(scaleX: scale.width, y: scale.height)
            
            // Combine transforms
            let finalTransform = clipTransform.concatenating(rotationTransform).concatenating(scaleTransform)
            
            // Create layer instruction
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(
                start: currentTime,
                duration: try await asset.load(.duration)
            )
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
            layerInstruction.setTransform(finalTransform, at: .zero)
            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
            
            // Insert into composition track
            try compositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: try await asset.load(.duration)),
                of: videoTrack,
                at: currentTime
            )
            
            currentTime = CMTimeAdd(currentTime, try await asset.load(.duration))
        }
        
        return instructions
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
                self.updateVideoOrientation(newOrientation)
            }
        }
    }
    
    @MainActor private func handleOrientationChange(newOrientation: UIDeviceOrientation) {
        guard isRecording else { return }
        
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
    
    @MainActor private func updateVideoOrientation(_ orientation: UIDeviceOrientation) {
            session.beginConfiguration()
            defer { session.commitConfiguration() }
        
            
            guard let connection = movieOutput.connection(with: .video) else { return }
            
            let videoOrientation: AVCaptureVideoOrientation
            switch orientation {
            case .portrait: videoOrientation = .portrait
            case .portraitUpsideDown: videoOrientation = .portraitUpsideDown
            case .landscapeLeft: videoOrientation = .landscapeRight
            case .landscapeRight: videoOrientation = .landscapeLeft
            default: videoOrientation = .portrait
            }
            
            connection.videoOrientation = videoOrientation
            
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = (currentLens == .frontWide)
            }
        }
    
    @MainActor func startRecording() {
        
        if !isRestarting {
               clipURLs.removeAll()
               stitchingGroup = DispatchGroup()
           }
           stitchingGroup?.enter()
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        if !isRestarting {
            AudioServicesPlaySystemSound(1117)
        }
        else{
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
//        startLocationUpdates()
        print("▶️ Started recording clip #\(currentClipNumber)")
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
                    self.stitchingGroup = nil
                }
            }
        print("⏹ Stopped recording clip #\(currentClipNumber)")
        
        if !isRestarting {
            self.currentClipNumber = 1 // reset
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
        if let error = error {
                self.errorMessage = "Recording failed: \(error.localizedDescription)"
            }
        
            
            // Immediately trigger completion to allow next recording
            stopCompletion?()
            stopCompletion = nil
            
        if self.shouldStitchClips {
                   self.clipURLs.append(outputFileURL)
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
