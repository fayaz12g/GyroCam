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
    
    private func formatDuration(_ duration: Double) -> (minutes: String, seconds: String, milliseconds: String) {
        let totalSeconds = Int(duration)
        let milliseconds = Int((duration - Double(totalSeconds)) * 1000 / 10)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        // Return tuple of formatted strings
        return (
            String(format: "%d", minutes),
            String(format: "%02d", seconds),
            String(format: "%02d", milliseconds)
        )
    }

    var isAccentColorDark: Bool {
        return UIColor(cameraManager.accentColor).isDarkColor
    }

    var body: some View {
        let duration = formatDuration(cameraManager.videoDuration)
        
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Text(duration.minutes)
                        .rotationEffect(rotationAngle)
                    Text(":")
                        .rotationEffect(rotationAngle)
                    Text(duration.seconds)
                        .rotationEffect(rotationAngle)
                    Text(":")
                        .rotationEffect(rotationAngle)
                    Text(duration.milliseconds)
                        .rotationEffect(rotationAngle)
                }
                .font(.title3.weight(.semibold))
                .foregroundColor(isAccentColorDark ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .fill(colorScheme == .dark ? cameraManager.accentColor.opacity(0.9) : cameraManager.accentColor.opacity(0.9))
                )
                .frame(height: 40)
                .padding(.top, geometry.safeAreaInsets.top > 47 ? cameraManager.lockLandscape ? 50 : 28 : 20)
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
