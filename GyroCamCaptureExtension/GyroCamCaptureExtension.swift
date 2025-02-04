//
//  GyroCamCaptureExtension.swift
//  GyroCamCaptureExtension
//
//  Created by Fayaz Shaikh on 2/2/25.
//

import Foundation
import LockedCameraCapture
import SwiftUI

@main
struct GyroCamCaptureExtension: LockedCameraCaptureExtension {
    var body: some LockedCameraCaptureExtensionScene {
        LockedCameraCaptureUIScene { session in
            GyroCamCaptureExtensionViewFinder(session: session)
        }
    }
}
