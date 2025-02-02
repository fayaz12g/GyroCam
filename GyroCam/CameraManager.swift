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
    

    // location
    private let locationManager = CLLocationManager()
    private var lastKnownLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // Main actor isolated properties
    // Main properties
    
    
    @MainActor var isProMode: Bool {
        get { settings.isProMode }
        set { settings.isProMode = newValue }
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
    
    @MainActor var showZoomBar: Bool {
        get { settings.showZoomBar }
        set { settings.showZoomBar = newValue }
    }
    
    @MainActor var maximizePreview: Bool {
        get { settings.maximizePreview }
        set { settings.maximizePreview = newValue }
    }
    
    @MainActor var accentColor: Color {
        get { settings.accentColor }
        set { settings.accentColor = newValue }
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
    
    
    private var zoomTimer: Timer?
    
    // Add to existing properties
    var captureDevice: AVCaptureDevice? {
        return currentCaptureDevice
    }
    
    func resetZoomTimer() {
        zoomTimer?.invalidate()
        zoomTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.showZoomBar = self?.showZoomBar ?? true
        }
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
    private var isRestarting = false
    
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
        requestCameraAccess()
        requestLocationAccess()
        loadSettings()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update every 5 meters
        
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
        currentLens = lens
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
            
            let newOrientation = OrientationHelper.getOrientation(from: motion)
            
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
        print("⏹ Stopped recording clip #\(currentClipNumber)")
        if !isRestarting {
            self.currentClipNumber = 1 // reset
            AudioServicesPlaySystemSound(1118)
        }
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
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
                                } else {
                                    self?.setErrorMessage(error?.localizedDescription ?? "Save failed")
                                }
                            }
                        }
                    }
                }
            }
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


extension CameraManager: CLLocationManagerDelegate {
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
