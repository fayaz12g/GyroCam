//
//  FocusBar.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/20/25.
//

import SwiftUI

struct FocusBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let maxFocus: CGFloat = 1.0
            let minFocus: CGFloat = 0.0
            let barWidth = geometry.size.width - 40
            let normalized = (CGFloat(cameraManager.focusValue) - minFocus) / (maxFocus - minFocus)
            let position = normalized * barWidth
            
            ZStack(alignment: .leading) {
                // Background Bar
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.7))
                    .padding(.horizontal, 20)
                
                // Focus Level Circle
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white)
                    .overlay(
                        Text("\(String(format: "%.1f", cameraManager.focusValue))f")
                            .font(.system(size: 12, weight: .bold))
                    )
                    .shadow(radius: 3)
                    .offset(x: position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Calculate new focus based on drag position
                                let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                let newFocus = minFocus + (dragPosition / barWidth) * (maxFocus - minFocus)
                                
                                // Update cameraManager's focus level
                                cameraManager.focusValue = Float(newFocus)
                                
                                // Update the actual focus on the capture device
                                if let device = cameraManager.captureDevice {
                                    do {
                                        try device.lockForConfiguration()
                                        device.setFocusModeLocked(lensPosition: Float(newFocus)) { _ in }
                                        device.unlockForConfiguration()
                                    } catch {
                                        print("Error adjusting focus: \(error)")
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 40)
    }
}

