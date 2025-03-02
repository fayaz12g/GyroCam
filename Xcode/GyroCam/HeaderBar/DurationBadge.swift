//
//  DurationBadge.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/2/25.
//


import SwiftUI

struct DurationBadge: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var currentOrientation: String
    @Binding var showDurationBadge: Bool
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
    
    var isAccentColorDark: Bool {
        return UIColor(cameraManager.accentColor).isDarkColor
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Group {
                    Text("\(String(format: "%.1f", cameraManager.videoDuration))")
                }
                .font(.title3.weight(.semibold))
                .foregroundColor(isAccentColorDark ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .fill(colorScheme == .dark ? cameraManager.accentColor.opacity(0.9) : cameraManager.accentColor.opacity(0.9)) // change lighter opacity?
                )
                .rotationEffect(rotationAngle)
                .fixedSize()
                .frame(width: rotationAngle != .zero ? 100 : nil,
                       height: rotationAngle != .zero ? 30 : nil)
                .padding(.leading, horizontalPadding)
                .padding(.top, geometry.safeAreaInsets.top > 47 ? 28 : 20)
                .offset(y: verticalOffset)
                .contextMenu {
                    Button {
                        showDurationBadge.toggle()
                    } label: {
                        Label(showDurationBadge ? "Hide Badge" : "Show Badge",
                              systemImage: showDurationBadge ? "eye.slash" : "eye")
                    }
                }
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: cameraManager.realOrientation)
    }
}

extension UIColor {
    var isDarkColor: Bool {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white < 0.8
    }
}
