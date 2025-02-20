//
//  CameraPreview.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    @ObservedObject var cameraManager: CameraManager
    @State private var lastScaleValue: CGFloat = 1.0
    @Binding var showOnboarding: Bool
    @Environment(\.colorScheme) var colorScheme
    
    
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
        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.handlePan(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator,
                                                            action: #selector(Coordinator.handleLongPress(_:)))
        
        tapGesture.numberOfTapsRequired = 1
        doubleTapGesture.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTapGesture)
        longPressGesture.minimumPressDuration = 0.5
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(doubleTapGesture)
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(longPressGesture)
        
        // Set initial focus mode based on autoFocus setting
        context.coordinator.updateFocusMode()
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraManager: cameraManager, colorScheme: colorScheme)
    }
    
    class Coordinator: NSObject {
        var colorScheme: ColorScheme
        private var overlayView: UIView?
        private var lensTypes: [(CameraManager.LensType, String, String)] = []
        var parent: CameraPreview
        var cameraManager: CameraManager
        private var initialPanPoint: CGFloat = 0
        private var lensSwitcherView: UIView?
        private var previewContainerView: UIView?
        private var lensViews: [UIView] = []
        
        init(_ parent: CameraPreview, cameraManager: CameraManager, colorScheme: ColorScheme) {
            self.parent = parent
            self.cameraManager = cameraManager
            self.colorScheme = colorScheme
            super.init()
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(autoFocusChanged),
                name: NSNotification.Name("AutoFocusChanged"),
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @MainActor @objc func autoFocusChanged() {
            updateFocusMode()
        }
        
        @MainActor func updateFocusMode() {
            guard let device = cameraManager.captureDevice else { return }
            
            do {
                try device.lockForConfiguration()
                
                if cameraManager.autoFocus {
                    // Reset any locked focus state
                    device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                    device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
                    
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                    }
                    if device.isExposureModeSupported(.continuousAutoExposure) {
                        device.exposureMode = .continuousAutoExposure
                    }
                } else {
                    if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                    }
                    if device.isExposureModeSupported(.autoExpose) {
                        device.exposureMode = .autoExpose
                    }
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Error updating focus mode: \(error)")
            }
        }
        
        @MainActor @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let device = cameraManager.captureDevice else {
                print("No capture device available for zoom")
                return
            }
            
            switch gesture.state {
            case .began:
                parent.lastScaleValue = device.videoZoomFactor
            case .changed:
                let minZoomFactor: CGFloat = 1.0
                let maxZoomFactor: CGFloat = 10.0
                
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
        
        @MainActor @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if cameraManager.autoFocus || cameraManager.showFocusBar {
                return
            }
            
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
        
        @MainActor func updateFocusValue(to value: Float) {
            guard let device = cameraManager.captureDevice else { return }
            do {
                try device.lockForConfiguration()
                device.setFocusModeLocked(lensPosition: value) { _ in }
                device.unlockForConfiguration()
            } catch {
                print("Error adjusting focus: \(error)")
            }
        }
        
        @objc @MainActor func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard !cameraManager.autoFocus else { return }
            
            let translation = gesture.translation(in: gesture.view)
            let screenWidth = gesture.view?.bounds.width ?? 1
            
            switch gesture.state {
            case .began:
                initialPanPoint = translation.x
            case .changed:
                // Calculate the movement delta normalized to screen width
                let delta = (translation.x - initialPanPoint) / screenWidth
                
                // Use the current focus value as the base
                let currentFocus = Double(cameraManager.focusValue)
                
                // Apply a constant speed factor
                let speedFactor = 0.1
                let change = delta * speedFactor
                
                // Calculate new focus value
                let newFocusValue = max(0, min(1, currentFocus + change))
                
                updateFocusValue(to: Float(newFocusValue))
                cameraManager.showFocusBar = true
                cameraManager.focusValue = Float(newFocusValue)
                
            default:
                break
            }
        }
        
        @MainActor @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            switch gesture.state {
            case .began:
                showLensSwitcher(in: gesture.view!)
            case .changed:
                let location = gesture.location(in: lensSwitcherView)
                updateLensSelection(at: location)
            case .ended:
                let location = gesture.location(in: lensSwitcherView)
                if let index = lensViews.firstIndex(where: { $0.frame.contains(location) }) {
                    let lensType = lensTypes[index].0
                    cameraManager.switchLens(lensType)
                    hideLensSwitcher()
                }
            case .cancelled, .failed:
                hideLensSwitcher()
            default: break
            }
        }

        
        @MainActor private func showLensSwitcher(in view: UIView) {
            // Create full-screen overlay
            overlayView = UIView(frame: UIScreen.main.bounds)
            guard let overlay = overlayView else { return }
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = overlay.bounds
            overlay.addSubview(blurView)
            
            // Add tap gesture for overlay
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap(_:)))
            overlay.addGestureRecognizer(tapGesture)
            
            // Create lens switcher content
            lensSwitcherView = UIView()
            setupLensOptions(in: overlay)
            overlay.addSubview(lensSwitcherView!)
            
            view.addSubview(overlay)
            
            // Animate appearance
            overlay.alpha = 0
            UIView.animate(withDuration: 0.3) {
                overlay.alpha = 1
            }
        }
        
        @MainActor @objc private func handleOverlayTap(_ gesture: UITapGestureRecognizer) {
            guard let lensSwitcher = lensSwitcherView else { return }
            let location = gesture.location(in: lensSwitcher)
            
            for (index, lensView) in lensViews.enumerated() {
                if lensView.frame.contains(location) {
                    let lensType = lensTypes[index].0
                    cameraManager.switchLens(lensType)
                    hideLensSwitcher()
                    return
                }
            }
            hideLensSwitcher()
        }
        

        
        @MainActor private func setupLensOptions(in view: UIView) {
            lensTypes = [
                (CameraManager.LensType.frontWide, "Front", "web.camera.fill"),
                (CameraManager.LensType.ultraWide, "0.5x", "camera.viewfinder"),
                (CameraManager.LensType.wide, "1x", "camera.fill"),
                (CameraManager.LensType.telephoto, "3x", "camera.macro")
            ]
            
            let optionSize = CGSize(width: 100, height: 100)
            let spacing: CGFloat = 20
            let totalWidth = 2 * optionSize.width + spacing
            _ = 2 * optionSize.height + spacing
            
            // Position higher up (1/3 of view height instead of 1/2.5)
            let gridOrigin = CGPoint(
                x: (view.bounds.width - totalWidth) / 2,
                y: view.bounds.height * (1/3)
            )
            
            lensViews = lensTypes.enumerated().map { (index, tuple) in
                let (lensType, zoomText, symbolName) = tuple
                
                // Calculate grid position
                let row = index / 2
                let col = index % 2
                
                let xOffset = gridOrigin.x + CGFloat(col) * (optionSize.width + spacing)
                let yOffset = gridOrigin.y + CGFloat(row) * (optionSize.height + spacing)
                
                let optionView = createLensOptionView(
                    lensType: lensType,
                    zoomText: zoomText,
                    symbolName: symbolName,
                    size: optionSize,
                    isSelected: cameraManager.currentLens == lensType
                )
                
                optionView.frame.origin = CGPoint(x: xOffset, y: yOffset)
                
                // Apply rotation transformation
                let rotationAngle: CGFloat = CGFloat(rotationAngle.radians) // Convert Angle to CGFloat radians
                optionView.transform = CGAffineTransform(rotationAngle: rotationAngle) // Apply rotation
                
                optionView.tag = index
                lensSwitcherView?.addSubview(optionView)
                
                return optionView
            }
        }

        @MainActor private func createLensOptionView(lensType: CameraManager.LensType, zoomText: String, symbolName: String, size: CGSize, isSelected: Bool) -> UIView {
            let view = UIView(frame: CGRect(origin: .zero, size: size))
            
            // Background for selection
            let selectionView = UIView(frame: view.bounds)
            selectionView.backgroundColor = (colorScheme == .dark ?
                UIColor.black.withAlphaComponent(0.7) :
                UIColor.white.withAlphaComponent(0.2))

            selectionView.layer.borderColor = (colorScheme == .dark ?
                UIColor.black.cgColor :
                UIColor.white.cgColor)
            
            selectionView.layer.cornerRadius = 16
            selectionView.layer.borderWidth = 2
            selectionView.alpha = isSelected ? 1 : 0
            selectionView.tag = 999
            view.addSubview(selectionView)
            
            // Symbol image
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
            let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)
            let imageView = UIImageView(image: symbolImage)
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: (size.width - 40)/2, y: 15, width: 40, height: 40)
            
            // Zoom text
            let label = UILabel(frame: CGRect(x: 0, y: 65, width: size.width, height: 30))
            label.text = zoomText
            label.textAlignment = .center
            label.textColor = .white
            label.font = .systemFont(ofSize: 18, weight: .medium)
            
            view.addSubview(imageView)
            view.addSubview(label)
            
            // Availability indicator
            if !cameraManager.availableLenses.contains(lensType) {
                view.alpha = 0.4
                let unavailableView = UIView(frame: view.bounds)
                unavailableView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                unavailableView.layer.cornerRadius = 16
                view.addSubview(unavailableView)
            }
            
            return view
        }

        @MainActor private var rotationAngle: Angle {
            switch cameraManager.currentOrientation {
            case "Landscape Left": return .degrees(90)
            case "Landscape Right": return .degrees(-90)
            case "Upside Down": return .degrees(180)
            default: return .degrees(0)
            }
        }
        
        @MainActor private func updateLensSelection(at location: CGPoint) {
            for lensView in lensViews {
                if let selectionView = lensView.viewWithTag(999) {
                    UIView.animate(withDuration: 0.2) {
                        selectionView.alpha = lensView.frame.contains(location) ? 1 : 0
                    }
                }
            }
        }

        @MainActor private func getSelectedLens() -> CameraManager.LensType? {
                for lensView in lensViews {
                    if lensView.backgroundColor == UIColor.lightGray {
                        return CameraManager.LensType.allCases[lensView.tag]
                    }
                }
                return nil
            }

                
        private func hideLensSwitcher() {
            UIView.animate(withDuration: 0.3) {
                self.overlayView?.alpha = 0
            } completion: { _ in
                self.overlayView?.removeFromSuperview()
                self.overlayView = nil
                self.lensSwitcherView = nil
                self.lensViews.removeAll()
                self.lensTypes.removeAll()
            }
        }
            
        
        static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
            NotificationCenter.default.removeObserver(uiView)
        }
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.colorScheme = colorScheme
        
        // Always operate on main thread
        DispatchQueue.main.async {
            guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
            
            previewLayer.videoGravity = cameraManager.maximizePreview ? .resizeAspectFill : .resizeAspect
            previewLayer.frame = uiView.bounds
            
            // Remove existing blur views
            uiView.subviews
                .filter { $0 is UIVisualEffectView }
                .forEach { $0.removeFromSuperview() }
            
            if !cameraManager.maximizePreview {
                let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                blurView.frame = uiView.bounds
                uiView.insertSubview(blurView, at: 0)
            }
        }
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

extension CameraManager {
    func getAvailableLenses() -> [AVCaptureDevice.DeviceType] {
        // Return array of available lens types for your device
        return [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera]
            .filter { type in
                AVCaptureDevice.default(type, for: .video, position: .back) != nil
            }
    }
    
    func switchToLens(_ lens: AVCaptureDevice.DeviceType) {
        guard let device = AVCaptureDevice.default(lens, for: .video, position: .back) else { return }
        // Implement lens switching logic here
    }
}
