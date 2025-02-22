import SwiftUI

struct OrientationHeader: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var currentOrientation: String
    @Binding var showOrientationBadge: Bool
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
        .animation(.easeInOut(duration: 0.2), value: currentOrientation)
    }
}
