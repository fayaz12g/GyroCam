import AVFoundation
import CoreMotion
import UIKit
import Photos

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let motionManager = CMMotionManager()
    private var currentDevice: AVCaptureDevice?
    private var activeInput: AVCaptureDeviceInput?
    private var stopCompletion: (() -> Void)?
    
    @Published var currentLens: LensType = .wide
    @Published var currentFormat: VideoFormat = .hdr4K60
    @Published var isRecording = false
    @Published var currentOrientation = "Portrait"
    @Published var errorMessage = ""
    @Published var currentClipNumber = 1
    
    // Orientation handling
    private var previousOrientation: UIDeviceOrientation = .portrait
    private let recordingQueue = DispatchQueue(label: "recording.queue")
    private var isRestarting = false
    
    enum LensType: String, CaseIterable {
        case ultraWide = "0.5x", wide = "1x", telephoto = "3x"
    }
    
    enum VideoFormat: String, CaseIterable {
        case hdr4K60 = "4K HDR 60fps", hdr4K30 = "4K HDR 30fps", hd1080p60 = "1080p 60fps"
        
        var preset: AVCaptureSession.Preset {
            switch self {
            case .hdr4K60, .hdr4K30: return .hd4K3840x2160
            case .hd1080p60: return .hd1920x1080
            }
        }
    }
    
    override init() {
        super.init()
        requestCameraAccess()
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else {
                self?.errorMessage = "Camera access denied"
                return
            }
            
            DispatchQueue.main.async {
                self?.configureSession()
                self?.startSession()
                self?.startOrientationUpdates()
            }
        }
    }
    
    func configureSession() {
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
            errorMessage = "Session error: \(error.localizedDescription)"
        }
    }
    
    private func setupInputs() throws {
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
        
        session.sessionPreset = currentFormat.preset
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                print("Capture session started")
            }
        }
    }
    
    private func getCurrentDevice() -> AVCaptureDevice? {
        switch currentLens {
        case .ultraWide: return AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
        case .wide: return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        case .telephoto: return AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back)
        }
    }
    
    private func configureDeviceFormat() throws {
        guard let device = currentDevice else { return }
        
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        
        let targetFormat = try findBestFormat(for: device)
        device.activeFormat = targetFormat
        
        let frameDuration = CMTimeMake(value: 1, timescale: currentFormat == .hdr4K60 ? 60 : 30)
        device.activeVideoMinFrameDuration = frameDuration
        device.activeVideoMaxFrameDuration = frameDuration
    }
    
    private func findBestFormat(for device: AVCaptureDevice) throws -> AVCaptureDevice.Format {
        let formats = device.formats
        guard !formats.isEmpty else {
            throw NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No valid formats found"])
        }
        
        switch currentFormat {
        case .hdr4K60: return formats.first { $0.supportedColorSpaces.contains(.HLG_BT2020) && $0.maxFrameRate >= 60 } ?? device.activeFormat
        case .hdr4K30: return formats.first { $0.supportedColorSpaces.contains(.HLG_BT2020) && $0.maxFrameRate >= 30 } ?? device.activeFormat
        case .hd1080p60: return formats.first { $0.maxFrameRate >= 60 } ?? device.activeFormat
        }
    }
    
    func switchLens(_ lens: LensType) {
        currentLens = lens
        configureSession()
    }
    
    func startOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "Motion data unavailable"
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            guard let motion = motion, error == nil else {
                self.errorMessage = error?.localizedDescription ?? "Motion updates failed"
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
    
    private func handleOrientationChange(newOrientation: UIDeviceOrientation) {
        guard isRecording else { return }
        
        recordingQueue.async { [weak self] in
            guard let self = self, !self.isRestarting else { return }
            self.isRestarting = true
            
            self.stopRecording { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.currentClipNumber += 1
                    self.startRecording()
                    self.isRestarting = false
                    print("♻️ Restarted recording as clip #\(self.currentClipNumber)")
                }
            }
        }
    }
    
    private func updateVideoOrientation(_ orientation: UIDeviceOrientation) {
        recordingQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            let videoOrientation = orientation.videoOrientation
            self.session.outputs.first?.connection(with: .video)?.videoOrientation = videoOrientation
            self.movieOutput.connection(with: .video)?.videoOrientation = videoOrientation
        }
    }
    
    func startRecording() {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        print("▶️ Started recording clip #\(currentClipNumber)")
    }
    
    func stopRecording(completion: (() -> Void)? = nil) {
        movieOutput.stopRecording()
        isRecording = false
        print("⏹ Stopped recording clip #\(currentClipNumber)")
        stopCompletion = completion // Store completion handler
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    // Update the fileOutput delegate method
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            errorMessage = "Recording failed: \(error.localizedDescription)"
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                self?.errorMessage = "Photo library access denied"
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Saved clip #\(self?.currentClipNumber ?? 0)")
                    } else {
                        self?.errorMessage = error?.localizedDescription ?? "Save failed"
                    }
                    // Call completion handler when saving is complete
                    self?.stopCompletion?()
                    self?.stopCompletion = nil
                }
            }
        }
    }
}

extension AVCaptureDevice.Format {
    var maxFrameRate: Double {
        videoSupportedFrameRateRanges
            .compactMap { $0.maxFrameRate }
            .max() ?? 0
    }
}
