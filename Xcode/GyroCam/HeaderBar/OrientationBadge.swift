//
//  OrientationBadge.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/2/25.
//


import SwiftUI

struct OrientationBadge: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var currentOrientation: String
    @Binding var showOrientationBadge: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var rotationAngle: Angle {
        switch cameraManager.realOrientation {
        case "Landscape Left": return .degrees(90)
        case "Landscape Right": return .degrees(-90)
        case "Upside Down": return .degrees(180)
        default: return .degrees(0)
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch cameraManager.realOrientation {
        case "Landscape Left", "Landscape Right": return 0
        case "Upside Down": return 32
        default: return 16
        }
    }
    
    private var verticalOffset: CGFloat {
        switch cameraManager.realOrientation {
        case "Landscape Left", "Landscape Right": return 45
        case "Upside Down": return 12
        default: return 0
        }
    }
    
    private var orientationArrow: String {
        switch currentOrientation {
        case "Landscape Left": return "arrow.left"
        case "Landscape Right": return "arrow.right"
        case "Upside Down": return "arrow.down"
        default: return "arrow.up"
        }
    }
    
    private var orientationPhone: String {
        switch currentOrientation {
        case "Landscape Left": return "iphone.landscape"
        case "Landscape Right": return "iphone.landscape"
        case "Upside Down": return "iphone"
        default: return "iphone"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Group {
                    if cameraManager.minimalOrientationBadge {
                        HStack(spacing: 4) {
                            Image(systemName: orientationArrow)
                            Image(systemName: orientationPhone)
                        }
                    } else {
                        Text(currentOrientation)
                            .font(.title3.bold())
//                            .fontWidth(.condensed)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        cameraManager.minimalOrientationBadge.toggle()
                    }
                }
                .font(.title3.weight(.semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                )
                .rotationEffect(rotationAngle)
                .fixedSize()
                .frame(width: rotationAngle != .zero ? 90 : nil,
                       height: rotationAngle != .zero ? 25 : nil)
                .padding(.leading, horizontalPadding)
                .padding(.top, geometry.safeAreaInsets.top > 47 ? 28 : 20)
                .offset(y: verticalOffset)
                .contextMenu {
                    Button {
                        showOrientationBadge.toggle()
                    } label: {
                        Label(showOrientationBadge ? "Hide Badge" : "Show Badge",
                              systemImage: showOrientationBadge ? "eye.slash" : "eye")
                    }
                }
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: cameraManager.realOrientation)
    }
}
