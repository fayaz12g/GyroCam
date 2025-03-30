//
//  MotionManager.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/30/25.
//

import CoreMotion
import SwiftUI

// Motion Manager class to handle gyroscope data
class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var pitch: CGFloat = 0
    @Published var roll: CGFloat = 0
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/60
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion, error == nil else { return }
                
                // Limit the range of motion for subtle effect
                self?.pitch = CGFloat(motion.attitude.pitch) * 3
                self?.roll = CGFloat(motion.attitude.roll) * 3
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
