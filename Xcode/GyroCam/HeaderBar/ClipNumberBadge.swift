import SwiftUI

struct ClipNumberBadge: View {
    let number: Int
    @Binding var currentOrientation: String
    @Binding var realOrientation: String
    @Binding var showClipBadge: Bool
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var motionManager = MotionManager()
    
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
                
                // Main badge container
                ZStack {
                    // Outer blur effect - moves slightly with gyroscope
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .offset(
                            x: motionManager.roll * 2.6,
                            y: motionManager.pitch * 2.6
                        )
                    
                    // Text layer - moves slightly more to create parallax
                    Text("Clip #\(number)")
                        .font(.title.weight(.medium))
                        .fontWidth(.condensed)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .offset(
                            x: motionManager.roll * 2.8,
                            y: motionManager.pitch * 2.8
                        )
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .frame(width: rotationAngle != .zero ? 90 : 90, height: rotationAngle != .zero ? 35 : 35)
                .rotationEffect(rotationAngle)
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
        .onAppear {
            motionManager.start()
        }
        .onDisappear {
            motionManager.stop()
        }
    }
}

