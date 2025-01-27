//
//  CameraPreview.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        print("🖥️ Preview layer created: \(previewLayer.bounds)")
        
        // Add observer for session start
        NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionDidStartRunning,
            object: session,
            queue: .main
        ) { _ in
            print("🚀 Capture session started - updating preview")
            previewLayer.frame = view.bounds
            previewLayer.connection?.videoOrientation = .portrait
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
                print("⚠️ Missing preview layer in update")
                return
            }
            
            previewLayer.frame = uiView.bounds
            print("🔄 Updated preview layer frame: \(uiView.bounds)")
            
            // Sync with current device orientation
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let interfaceOrientation = windowScene.interfaceOrientation
                let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: interfaceOrientation)
                previewLayer.connection?.videoOrientation = videoOrientation ?? .portrait
                print("🧭 Updated preview orientation to: \(videoOrientation?.description ?? "unknown")")
            }
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        NotificationCenter.default.removeObserver(uiView)
    }
}

extension AVCaptureVideoOrientation {
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "Upside Down"
        case .landscapeLeft: return "Landscape Left"
        case .landscapeRight: return "Landscape Right"
        @unknown default: return "Unknown"
        }
    }
}
