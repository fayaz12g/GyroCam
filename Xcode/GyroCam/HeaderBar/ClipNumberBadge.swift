import SwiftUI

struct ClipNumberBadge: View {
    let number: Int
    @Binding var currentOrientation: String
    @Binding var realOrientation: String
    @Binding var showClipBadge: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var rotationAngle: Angle {
        switch realOrientation {
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
        switch realOrientation {
        case "Landscape Left", "Landscape Right": return 8
        case "Upside Down": return 12
        default: return 0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                Text("Clip #\(number)")
                    .font(.caption.weight(.semibold))
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
                    .contextMenu {
                        Button {
                            showClipBadge.toggle()
                        } label: {
                            Label(showClipBadge ? "Hide Badge" : "Show Badge",
                                  systemImage: showClipBadge ? "eye.slash" : "eye")
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: realOrientation)
    }
}
