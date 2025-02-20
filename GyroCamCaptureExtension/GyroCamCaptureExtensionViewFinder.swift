//
//  GyroCamCaptureExtensionViewFinder.swift
//  GyroCamCaptureExtension
//
//  Created by Fayaz Shaikh on 2/2/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import LockedCameraCapture

struct GyroCamCaptureExtensionViewFinder: UIViewControllerRepresentable {
    let session: LockedCameraCaptureSession
    var sourceType: UIImagePickerController.SourceType = .camera

    init(session: LockedCameraCaptureSession) {
        self.session = session
    }
 
    func makeUIViewController(context: Self.Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        imagePicker.cameraDevice = .rear
 
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Self.Context) {
    }
}

