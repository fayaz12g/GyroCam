//
//  AppSettings.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI
import AVFoundation

// Add Codable conformance to all necessary enums first
extension AVCaptureDevice.Position: Codable {}  // Add this



// Add these if they don't exist in your code
extension CameraManager.VideoFormat: Codable {}
extension FrameRate: Codable {}
extension CameraManager.LensType: Codable {}


struct AppSettings: Codable {
    var accentColor: Color = Color(red: 1.0, green: 0.204, blue: 0.169) // #FF000D
    var currentFormat: CameraManager.VideoFormat = .hd4K
    var currentFPS: FrameRate = .sixty
    var cameraPosition: AVCaptureDevice.Position = .back
    var currentLens: CameraManager.LensType = .wide
    var isHDREnabled: Bool = true
    var showZoomBar: Bool = false
    var showFocusBar: Bool = false
    var autoFocus: Bool = true
    var maximizePreview: Bool = true
    
    var lockLandscape: Bool = false
    
    var isSavingVideo: Bool = false
    
    var stabilizeVideo: CameraManager.StabilizationMode = .auto
    
    var showQuickSettings: Bool = true
    var isFlashOn: Bool = false
    
    var shouldStitchClips: Bool = false
    
    
    // exposure
    var autoExposure: Bool = true
    var manualISO: Float = 100
    var manualShutterSpeed: Double = 1/60
    
    // Header
    var showRecordingTimer: Bool = false
    var showOrientationBadge: Bool = true
    var showClipBadge: Bool = true
    var minimalOrientationBadge: Bool = false
    
    // Photo Library
    var isProMode: Bool = true
    var preserveAspectRatios: Bool = true
    

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
