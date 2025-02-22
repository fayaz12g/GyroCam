import CoreMotion
import UIKit
import AVFoundation

import CoreMotion
import UIKit
import AVFoundation

struct OrientationHelper {
    static func getOrientation(from motion: CMDeviceMotion, lockLandscape: Bool, currentOrientation: UIDeviceOrientation) -> UIDeviceOrientation {
        let gravity = motion.gravity
        let absX = abs(gravity.x)
        let absY = abs(gravity.y)
        let absZ = abs(gravity.z)
        
        // Skip face up/down check if locked to landscape
        if !lockLandscape {
            if absZ > max(absX, absY) {
                if gravity.z > 1 {
                    return .faceUp
                } else if gravity.z < -1 {
                    return .faceDown
                }
                // If not clearly face up/down, fall through to closest orientation logic
            }
        }
        
        // Determine the closest orientation based on gravity vector
        if absX > absY {
            // Landscape orientation
            return gravity.x > 0 ? .landscapeRight : .landscapeLeft
        } else if absY > absX {
            // Portrait orientation (only if not locked to landscape)
            if !lockLandscape {
                return gravity.y > 0 ? .portraitUpsideDown : .portrait
            } else {
                // If locked to landscape, return the current orientation to avoid flipping
                return currentOrientation
            }
        } else {
            // If X and Y are nearly equal (device is centered), retain the current orientation
            return currentOrientation
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
