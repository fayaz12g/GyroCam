import CoreMotion
import UIKit
import AVFoundation

struct OrientationHelper {
    @MainActor static func getOrientation(from motion: CMDeviceMotion, currentOrientation: UIDeviceOrientation, cameraManager: CameraManager) -> UIDeviceOrientation {
        let gravity = motion.gravity
        let absX = abs(gravity.x)
        let absY = abs(gravity.y)
        let absZ = abs(gravity.z)
        
        // Determine the real device orientation first
        var realOrientation: UIDeviceOrientation = currentOrientation
        
    
        // Check for landscape/portrait
        if absX > absY {
            // Landscape orientation
            realOrientation = gravity.x > 0 ? .landscapeRight : .landscapeLeft
        } else if absY > absX {
            // Portrait orientation
            realOrientation = gravity.y > 0 ? .portraitUpsideDown : .portrait
        }
        
        if cameraManager.useRealOrientation {
            cameraManager.realOrientation = realOrientation.description
        }
        
        // If landscape lock is on, we need to determine what orientation to return
        if cameraManager.lockLandscape {
            // Skip face up/down check if locked to landscape
            if absZ > max(absX, absY) {
                // Even with face up/down, we maintain current orientation if landscape locked
                if !cameraManager.useRealOrientation {
                    cameraManager.realOrientation = currentOrientation.description
                }
                return currentOrientation
            }
            
            // For landscape orientations, return the detected orientation
            if absX > absY {
                if !cameraManager.useRealOrientation {
                    cameraManager.realOrientation = gravity.x > 0 ? "Landscape Right" : "Landscape Left"
                }
                return gravity.x > 0 ? .landscapeRight : .landscapeLeft
            } else if absY > absX {
                // If locked to landscape but device is in portrait, maintain current orientation
                if !cameraManager.useRealOrientation {
                    cameraManager.realOrientation = currentOrientation.description
                }
                return currentOrientation
            } else {
                // If X and Y are nearly equal (device is centered), retain the current orientation
                if !cameraManager.useRealOrientation {
                    cameraManager.realOrientation = currentOrientation.description
                }
                return currentOrientation
            }
        } else {
            // If not locked to landscape, just return the real orientation we already determined
            cameraManager.realOrientation = realOrientation.description
            return realOrientation
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
        case .faceUp: return "Face Up"
        case .faceDown: return "Face Down"
        default: return "Unknown"
        }
    }
}
