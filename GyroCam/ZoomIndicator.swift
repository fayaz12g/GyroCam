//
//  ZoomIndicator.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/20/25.
//

import SwiftUI

struct ZoomIndicator: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let maxZoom: CGFloat = 10.0
            let minZoom: CGFloat = 1.0
            let barWidth = geometry.size.width - 40
            let normalized = (cameraManager.currentZoom - minZoom) / (maxZoom - minZoom)
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
                    .shadow(radius: 3)
                    .offset(x: position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Calculate new zoom based on drag position
                                let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                let newZoom = minZoom + (dragPosition / barWidth) * (maxZoom - minZoom)
                                
                                // Update cameraManager's zoom level
                                cameraManager.currentZoom = newZoom
                                
                                // Update the actual zoom on the capture device
                                if let device = cameraManager.captureDevice {
                                    do {
                                        try device.lockForConfiguration()
                                        device.videoZoomFactor = newZoom
                                        device.unlockForConfiguration()
                                    } catch {
                                        print("Error adjusting zoom: \(error)")
                                    }
                                }
                            }
                    )

            }
        }
        .frame(height: 40)
    }
}
