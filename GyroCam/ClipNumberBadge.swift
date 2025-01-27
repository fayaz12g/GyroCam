import SwiftUI

struct ClipNumberBadge: View {
    let number: Int
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
        rotationAngle == .degrees(0) ? 16 : 8
    }
    
    private var verticalOffset: CGFloat {
        switch currentOrientation {
        case "Landscape Left", "Landscape Right": return 32
        case "Upside Down": return 24
        default: return 0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                Text("Clip #\(number)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                    )
                    .rotationEffect(rotationAngle)
                    .fixedSize()
                    .frame(width: rotationAngle != .zero ? 80 : nil,
                           height: rotationAngle != .zero ? 30 : nil)
                    .padding(.trailing, horizontalPadding)
                    .padding(.top, geometry.safeAreaInsets.top > 47 ? 28 : 20)
                    .offset(y: verticalOffset)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentOrientation)
    }
}
