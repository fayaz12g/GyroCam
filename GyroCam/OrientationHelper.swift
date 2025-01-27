//
//  OrientationHelper.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import CoreMotion
import UIKit
import AVFoundation

struct OrientationHelper {
    static func getOrientation(from motion: CMDeviceMotion) -> UIDeviceOrientation {
        let gravity = motion.gravity
        let absX = abs(gravity.x)
        let absY = abs(gravity.y)
        
        // Only consider orientation changes when tilt exceeds 45 degrees
        if max(absX, absY) < 0.5 { // ~30 degree threshold
            return .unknown
        }
        
        if absX > absY {
            return gravity.x > 0 ? .landscapeRight : .landscapeLeft
        } else {
            return gravity.y > 0 ? .portraitUpsideDown : .portrait
        }
    }
}

extension UIDeviceOrientation {
    var description: String {
        switch self {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "Upside Down"
        case .landscapeLeft: return "Landscape Left"
        case .landscapeRight: return "Landscape Right"
        default: return "Unknown"
        }
    }
    
    var videoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight // Fix mirroring
        case .landscapeRight: return .landscapeLeft // Fix mirroring
        default: return .portrait
        }
    }
}
