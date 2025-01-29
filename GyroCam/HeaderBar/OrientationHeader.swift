import SwiftUI

struct OrientationHeader: View {
    @Binding var currentOrientation: String
    @Environment(\.colorScheme) var colorScheme
    
    private var rotationAngle: Angle {
        switch currentOrientation {
        case "Landscape Left": return .degrees(90)
        case "Landscape Right": return .degrees(-90)
        case "Upside Down": return .degrees(180)
        default: return .degrees(0)
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch currentOrientation {
        case "Landscape Left", "Landscape Right": return 0
        case "Upside Down": return 32
        default: return 16
        }
    }
    private var verticalOffset: CGFloat {
        switch currentOrientation {
        case "Landscape Left", "Landscape Right": return 32
        case "Upside Down": return 12
        default: return 0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(currentOrientation)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                    )
                    .rotationEffect(rotationAngle)
                    .fixedSize()
                    .frame(width: rotationAngle != .zero ? 100 : nil,
                           height: rotationAngle != .zero ? 30 : nil)
                    .padding(.leading, horizontalPadding)
                    .padding(.top, geometry.safeAreaInsets.top > 47 ? 28 : 20)
                    .offset(y: verticalOffset)
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentOrientation)
    }
}
