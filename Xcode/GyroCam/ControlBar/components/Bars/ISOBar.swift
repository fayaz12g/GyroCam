//
//  ISOBar.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/25/25.
//

// ISOBar.swift

import SwiftUI

struct ISOBar: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width - 40
            let normalized = (cameraManager.manualISO - cameraManager.minISO) / (cameraManager.maxISO - cameraManager.minISO)
            let position = CGFloat(normalized) * barWidth
                
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 4)
                        .foregroundColor(colorScheme == .dark ? .gray.opacity(0.5) : .white.opacity(0.7))
                        .padding(.horizontal, 20)
                    
                    // Draggable thumb
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(colorScheme == .dark ? .black.opacity(0.7) : .white)
                        .overlay(
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(Int(cameraManager.manualISO))")
                                    .font(.system(size: 12, weight: .bold))
                                Text("ISO")
                                    .font(.system(size: 6, weight: .bold))
                            }
                        )
                        .rotationEffect(rotationAngle)
                        .shadow(radius: 3)
                        .offset(x: position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragPosition = min(max(0, value.location.x - 20), barWidth)
                                    let newISO = cameraManager.minISO + (Float(dragPosition / barWidth) * (cameraManager.maxISO - cameraManager.minISO))
                                    cameraManager.manualISO = newISO
                                }
                        )
                }
        }
        .frame(height: 40)
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
