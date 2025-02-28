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
    private var recordingStartTime: Date?
    private var orientationChanges: [(time: TimeInterval, orientation: String)] = []
    var exportDuration: Double = 0.0
    
    private var previousOrientation: UIDeviceOrientation = .portrait
    private let recordingQueue = DispatchQueue(label: "recording.queue")
    public var isRestarting = false
    
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
    
    @MainActor @Published var isRecording = false
    @MainActor @Published var currentOrientation = "Portrait"
    @MainActor @Published var realOrientation = "Portrait"
    @MainActor @Published var presentMessage = ""
    @MainActor @Published var messageType = ""
    @MainActor @Published var currentClipNumber = 1
    private var currentCaptureDevice: AVCaptureDevice?
    
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
    
    @MainActor var stabilizeVideo: StabilizationMode {
        get { settings.stabilizeVideo }
        set { settings.stabilizeVideo = newValue }
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
    
    @MainActor var isFlashOn: Bool {
        get { settings.isFlashOn }
        set { settings.isFlashOn = newValue }
    }
    
    @MainActor var autoExposure: Bool {
        get { settings.autoExposure }
        set {
            settings.autoExposure = newValue
            configureExposureMode()
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

    private func configureExposureMode() {
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
        
        guard let clipURL = self.clipURLs.first else {
            print("❌ [1.1] No clips to stitch")
            self.showError("No video to stitch")
            return
        }
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let asset = AVURLAsset(url: clipURL)
            guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first,
                  let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first else {
                self.showError("Missing video/audio track")
                return
            }
            
            // Get video properties
            let naturalSize = try await videoTrack.load(.naturalSize)
            let assetDuration = try await asset.load(.duration)
            let frameRate = try await videoTrack.load(.nominalFrameRate)
            
            // Create composition with audio
            let composition = AVMutableComposition()
            guard let compVideoTrack = composition.addMutableTrack(withMediaType: .video,
                                                                   preferredTrackID: kCMPersistentTrackID_Invalid),
                  let compAudioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                                   preferredTrackID: kCMPersistentTrackID_Invalid) else {
                self.showError("Failed to create composition tracks")
                return
            }
            
            // Build segments properly
            var segments: [CMTimeRange] = []
            var prevTime = CMTime.zero
            for change in self.orientationChanges {
                let time = CMTime(seconds: change.time, preferredTimescale: 600)
                if time > prevTime {
                    segments.append(CMTimeRange(start: prevTime, end: time))
                    prevTime = time
                }
            }
            segments.append(CMTimeRange(start: prevTime, end: assetDuration))
            
            // Remove zero-length segments
            let validSegments = segments.filter { $0.duration.seconds > 0 }
            
            
            // Create video composition
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = naturalSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(frameRate))
            
            var instructions: [AVMutableVideoCompositionInstruction] = []
            var insertTime = CMTime.zero
            
            for (index, segment) in validSegments.enumerated() {
                // Insert video
                try compVideoTrack.insertTimeRange(segment, of: videoTrack, at: insertTime)
                
                // Insert audio
                try compAudioTrack.insertTimeRange(segment, of: audioTrack, at: insertTime)
                
                
                let num = (self.orientationChanges.first?.orientation == "Landscape Left") ? 1 : 0
                
                // Create rotation transform
                let transform: CGAffineTransform
                if index % 2 == num {
                    let centerX = naturalSize.width / 2
                    let centerY = naturalSize.height / 2
                    transform = CGAffineTransform(translationX: centerX, y: centerY)
                        .rotated(by: .pi)
                        .translatedBy(x: -centerX, y: -centerY)
                } else {
                    transform = .identity
                }
                
                // Create instruction
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRange(start: insertTime, duration: segment.duration)
                
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideoTrack)
                layerInstruction.setTransform(transform, at: .zero)
                instruction.layerInstructions = [layerInstruction]
                instructions.append(instruction)
                
                insertTime = CMTimeAdd(insertTime, segment.duration)
            }
            
            videoComposition.instructions = instructions
            
            // export and save video
            await exportVideo(composition: composition, videoComposition: videoComposition)

        }
    }
    
    private func exportVideo(composition: AVMutableComposition, videoComposition: AVMutableVideoComposition) async {
        // Get background task identifier
        var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            // End task if it expires
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        // Configure exporter
        guard let exporter = AVAssetExportSession(asset: composition,
                                                  presetName: self.exportQuality.preset) else {
            self.showError("Export failed")
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("stitched-\(UUID().uuidString)")
            .appendingPathExtension("mov")
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.videoComposition = videoComposition
        exporter.shouldOptimizeForNetworkUse = false
        exportDuration = CMTimeGetSeconds(composition.duration)
        
        print("📤 [10] Starting export")
        print("   📍 Output URL: \(outputURL)")
        print("   🎞 Video composition attached: \(exporter.videoComposition != nil ? "YES" : "NO")")
        print("   ⏳ Video duration: \(exportDuration)s")
        print("   🎥 Export Quality: \(exportQuality)")
        
        await exporter.export()
        
        if exporter.status == .completed {
            print("✅ [11] Export succeeded")
            await MainActor.run {
                self.saveFinalVideo(outputURL)
                self.cleanupClips()
                print("🧹 [12] Cleanup completed")
            }
        }
        
        // End background task
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
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
                creationRequest.location = currentLocation
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
                    } else {
                        print("Save error: \(error?.localizedDescription ?? "Unknown error")")
                        self.showError(error?.localizedDescription ?? "Failed to save video")
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
            DispatchQueue.main.async {
                if granted {
                    self?.configureSession()
                    self?.startSession()
                }
            }
        }
    }
    
    @MainActor func configureSession() {
        session.beginConfiguration()
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
        DispatchQueue.main.async {
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
        DispatchQueue.global(qos: .background).async { [weak self] in
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
        motionManager.deviceMotionUpdateInterval = 0.1
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
       stitchingGroup = DispatchGroup()
       recordingStartTime = Date()
       orientationChanges.removeAll()
       // Record initial orientation
       let initialOrientation = currentOrientation.description
       orientationChanges.append((time: 0.0, orientation: initialOrientation))
       if playSounds {
            AudioServicesPlaySystemSound(1117)
        }
        
        stitchingGroup?.enter()
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        startLocationUpdates()
        print("▶️ Started recording clip #\(currentClipNumber)")
        print("Starting recording with orientation: \(self.previousOrientation.description)")
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
            
        if self.shouldStitchClips {
            DispatchQueue.main.async {
                self.clipURLs.append(outputFileURL)
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
