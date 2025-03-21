//
//  AppSettings.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI
import AVFoundation

// Add Codable conformance
extension AVCaptureDevice.Position: Codable {}

extension VideoFormat: Codable {}
extension FrameRate: Codable {}
extension LensType: Codable {}


struct AppSettings: Codable {
    
    // General Settings
    var accentColor: Color = Color(red: 1.0, green: 0.204, blue: 0.169) // #FF000D
    var isProMode: Bool = true
    var preserveAspectRatios: Bool = true
    var allowRecordingWhileSaving: Bool = false
    
    // Camera Settings
    var cameraPosition: AVCaptureDevice.Position = .back
    var currentLens: LensType = .wide
    var currentFormat: VideoFormat = .hd4K
    var currentFPS: FrameRate = .sixty
    var isHDREnabled: Bool = true
    var isFlashOn: Bool = false
    var useBlurredBackground: Bool = true
    
    // Video Settings
    var isSavingVideo: Bool = false
    var shouldStitchClips: Bool = false
    var stabilizeVideo: StabilizationMode = .auto
    
    // Focus Settings
    var autoFocus: Bool = true
    var showFocusBar: Bool = false
    var focusValue: Float = 0.5
    
    // Exposure Settings
    var autoExposure: Bool = true
    var manualISO: Float = 100
    var showISOBar: Bool = false
    var manualShutterSpeed: Double = 1/60
    
    // Preview Settings
    var maximizePreview: Bool = true
    var showZoomBar: Bool = false
    
    // Quick Settings
    var showQuickSettings: Bool = true
    
    // UI Elements: Header
    var showDurationBadge: Bool = true
    var showOrientationBadge: Bool = true
    var minimalOrientationBadge: Bool = false
    var showClipBadge: Bool = true
    
    // Orientation and Landscape Lock
    var lockLandscape: Bool = false
    
    // Audio and Haptic Feedback
    var playHaptics: Bool = true
    var playSounds: Bool = true
}


 extension Color: Codable {
     public init(from decoder: Decoder) throws {
         let container = try decoder.singleValueContainer()
         let data = try container.decode(Data.self)
         let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? UIColor.systemBlue
         self = Color(color)
     }
     
     public func encode(to encoder: Encoder) throws {
         var container = encoder.singleValueContainer()
         let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
         try container.encode(data)
     }
 }

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

enum StabilizationMode: String, CaseIterable, Codable {
    case off = "0"
    case standard = "1"
    case cinematic = "2"
    case cinematicExtended = "3"
    case auto = "Auto"
}

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

enum LensType: String, CaseIterable {
    case frontWide = "Front"
    case ultraWide = "0.5x"
    case wide = "1x"
    case telephoto = "Tele"
    
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
        case .hdr: return "mountain.2"
        case .hdrFallback: return "tv.fill"
        case .cinematic: return "film"
        case .highFrameRate: return "timer"
        case .timelapse: return "timelapse"
        case .hevc: return "h.square"
        }
    }
    
    // change label to AVCaptureVideoStabilizationMode? to eliminate camera manaegr function mapStabilizationMode
    var label: String {
        switch self {
        case .hdr: return "HDR"
        case .hdrFallback: return "Dolby Vision"
        case .cinematic: return "Cinematic"
        case .highFrameRate: return "Slo-Mo"
        case .timelapse: return "Timelapse"
        case .hevc: return "HEVC"
        }
    }
}

enum ExportQuality: String, CaseIterable, Identifiable {
    case fastest = "Potato"
    case balanced = "Okay"
    case high = "Good"
    case highest = "Best"
    
    var id: String { self.rawValue }
    
    var preset: String {
        switch self {
        case .fastest: return AVAssetExportPresetLowQuality
        case .balanced: return AVAssetExportPresetMediumQuality
        case .high: return AVAssetExportPresetHighestQuality
        case .highest: return AVAssetExportPresetHEVCHighestQuality
        }
    }
}
