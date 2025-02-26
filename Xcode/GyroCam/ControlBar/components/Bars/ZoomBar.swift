//
//  ZoomBar.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/25/25.
//


import SwiftUI

struct ZoomBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let maxZoom: CGFloat = 10.0
            let minZoom: CGFloat = 1.0
            let barWidth = geometry.size.width - 40
            
            // Non-linear mapping for zoom
            let normalized = logZoomNormalization(zoom: cameraManager.currentZoom, min: minZoom, max: maxZoom)
            let position = normalized * barWidth
            
            ZStack(alignment: .leading) {
                // Background Bar
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.7))
                    .padding(.horizontal, 20)
                
                // Zoom Level Circle
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white)
                    .overlay(
                        Text("\(String(format: "%.1f", cameraManager.currentZoom))x")
                            .font(.system(size: 12, weight: .bold))
                    )
                    .rotationEffect(rotationAngle)
                    .shadow(radius: 3)
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.currentOrientation)
                    .offset(x: position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                
                                // Convert drag position back to zoom using inverse logarithmic mapping
                                let normalizedPosition = dragPosition / barWidth
                                let newZoom = inverseLogZoomNormalization(
                                    normalized: normalizedPosition,
                                    min: minZoom,
                                    max: maxZoom
                                )
                                
                                // Update zoom
                                updateZoom(to: newZoom)
                            }
                    )
            }
        }
        .frame(height: 40)
    }
    
    // Helper function to update zoom
    private func updateZoom(to newZoom: CGFloat) {
        let clampedZoom = min(max(1.0, newZoom), 10.0)
        cameraManager.currentZoom = clampedZoom
        
        if let device = cameraManager.captureDevice {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clampedZoom
                device.unlockForConfiguration()
            } catch {
                print("Error adjusting zoom: \(error)")
            }
        }
    }
    
    // Logarithmic normalization for zoom values
    private func logZoomNormalization(zoom: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        let logMin = log(min)
        let logMax = log(max)
        let logZoom = log(zoom)
        
        return (logZoom - logMin) / (logMax - logMin)
    }
    
    // Inverse logarithmic normalization for converting position to zoom
    private func inverseLogZoomNormalization(normalized: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        let logMin = log(min)
        let logMax = log(max)
        
        return exp(normalized * (logMax - logMin) + logMin)
    }
    
    private var rotationAngle: Angle {
        switch cameraManager.realOrientation {
        case "Landscape Left": return .degrees(90)
        case "Landscape Right": return .degrees(-90)
        case "Upside Down": return .degrees(180)
        default: return .degrees(0)
        }
    }
}
