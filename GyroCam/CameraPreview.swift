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
    @ObservedObject var cameraManager: CameraManager
    @State private var lastScaleValue: CGFloat = 1.0
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = cameraManager.maximizePreview ? .resizeAspectFill : .resizeAspect
        previewLayer.connection?.videoRotationAngle = 0
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Add gesture recognizers
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator,
                                                   action: #selector(Coordinator.handlePinch(_:)))
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleTap(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                     action: #selector(Coordinator.handleDoubleTap(_:)))
        
        tapGesture.numberOfTapsRequired = 1
        doubleTapGesture.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTapGesture)
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(doubleTapGesture)
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraManager: cameraManager)
    }
    
    class Coordinator: NSObject {
        var parent: CameraPreview
        var cameraManager: CameraManager
        
        init(_ parent: CameraPreview, cameraManager: CameraManager) {
            self.parent = parent
            self.cameraManager = cameraManager
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let device = cameraManager.captureDevice else {
                print("No capture device available for zoom")
                return
            }
            
            switch gesture.state {
            case .began:
                parent.lastScaleValue = device.videoZoomFactor
            case .changed:
                let minZoomFactor: CGFloat = 1.0
                let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
                
                let desiredZoomFactor = parent.lastScaleValue * gesture.scale
                let zoomFactor = max(minZoomFactor, min(desiredZoomFactor, maxZoomFactor))
                
                do {
                    try device.lockForConfiguration()
                    device.videoZoomFactor = zoomFactor
                    device.unlockForConfiguration()
                    
                    cameraManager.currentZoom = zoomFactor
                    cameraManager.resetZoomTimer()
                } catch {
                    print("Error adjusting zoom: \(error)")
                }
            default:
                break
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let device = cameraManager.captureDevice,
                  device.isFocusPointOfInterestSupported else { return }
            
            let point = gesture.location(in: gesture.view)
            let focusPoint = CGPoint(
                x: point.x / gesture.view!.bounds.width,
                y: point.y / gesture.view!.bounds.height
            )
            
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
                device.unlockForConfiguration()
                
                // Add focus animation
                let focusView = UIView(frame: CGRect(x: point.x - 40, y: point.y - 40, width: 80, height: 80))
                focusView.layer.borderColor = UIColor.yellow.cgColor
                focusView.layer.borderWidth = 2
                focusView.alpha = 0
                gesture.view?.addSubview(focusView)
                
                UIView.animate(withDuration: 0.3) {
                    focusView.alpha = 1
                    focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                } completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        focusView.alpha = 0
                        focusView.transform = .identity
                    } completion: { _ in
                        focusView.removeFromSuperview()
                    }
                }
            } catch {
                print("Error setting focus: \(error)")
            }
        }
        
        @MainActor @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            cameraManager.switchCamera()
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        
        previewLayer.videoGravity = cameraManager.maximizePreview ? .resizeAspectFill : .resizeAspect
        previewLayer.frame = uiView.bounds
        
        // Add blurred background if not maximized
        if !cameraManager.maximizePreview {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            blurView.frame = uiView.bounds
            uiView.insertSubview(blurView, at: 0)
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
