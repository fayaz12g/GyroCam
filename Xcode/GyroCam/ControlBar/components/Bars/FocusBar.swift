//  FocusBar.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/20/25.
//

import SwiftUI

struct FocusBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var continuousFocusMode: Bool = false
    
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            .padding(.horizontal, 20)
                        )
                
                // Outer glass effect with blur
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .fill(continuousFocusMode ? Color.yellow.opacity(0.9) : Color.yellow.opacity(0))
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .overlay(
                        VStack(alignment: .center, spacing: 2) {
                            Text(continuousFocusMode ? "AUTO" : "\(String(format: "%.1f", (cameraManager.focusValue * 10)))")
                                .font(.system(size: 12, weight: .bold))
                            Text("FOCUS")
                                .font(.system(size: 6, weight: .bold))
                        }
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    .rotationEffect(rotationAngle)
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.focusValue)  // Animate focus value changes
                    .shadow(radius: 3)
                    .offset(x: position)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                continuousFocusMode.toggle()
                                
                                if continuousFocusMode {
                                    // Enable continuous autofocus
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.focusMode = .continuousAutoFocus
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error setting continuous autofocus: \(error)")
                                        }
                                    }
                                } else {
                                    // Disable continuous autofocus and switch to manual
                                    if let device = cameraManager.captureDevice {
                                        do {
                                            try device.lockForConfiguration()
                                            device.focusMode = .locked
                                            device.setFocusModeLocked(lensPosition: cameraManager.focusValue) { _ in }
                                            device.unlockForConfiguration()
                                        } catch {
                                            print("Error locking focus: \(error)")
                                        }
                                    }
                                }
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !continuousFocusMode {
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
                            }
                    )
            }
        }
        .frame(height: 40)
        .onChange(of: cameraManager.focusValue) { _, newValue in
            // Update circle position as autofocus changes
            if continuousFocusMode {
                cameraManager.focusValue = newValue  // Update value as autofocus sets it
            }
        }
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
