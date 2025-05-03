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
    
    private var isLandscape: Bool {
        return cameraManager.realOrientation == "Landscape Left" || cameraManager.realOrientation == "Landscape Right"
    }
    
    private func formatDuration(_ duration: Double) -> (hours: String, minutes: String, seconds: String, milliseconds: String) {
        let totalSeconds = Int(duration)
        let milliseconds = Int((duration - Double(totalSeconds)) * 1000 / 10)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        // Return tuple of formatted strings
        return (
            String(format: "%d", hours),
            String(format: "%02d", minutes),
            String(format: "%02d", seconds),
            String(format: "%02d", milliseconds)
        )
    }

    var isAccentColorDark: Bool {
        return UIColor(cameraManager.accentColor).isDarkColor
    }

    var body: some View {
        let duration = formatDuration(cameraManager.videoDuration)
        
        VStack {
            if cameraManager.lockLandscape {
                Spacer().frame(height: 80)
            }
            else {
                Spacer().frame(height: 20)
            }
            
            ZStack {
                // Single rounded glassy rectangle that adapts to orientation
                RoundedRectangle(cornerRadius: 12)
                    .fill(cameraManager.accentColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                // Time components container that rotates as a unit
                Group {
                    if isLandscape {
                        VStack(spacing: 8) {
                            timeComponentView(value: duration.hours, label: "HOURS")
                            separatorView()
                            timeComponentView(value: duration.minutes, label: "MINUTES")
                            separatorView()
                            timeComponentView(value: duration.seconds, label: "SECONDS")
                            separatorView()
                            timeComponentView(value: duration.milliseconds, label: "MILLI")
                        }
                        .frame(width: 100) // Fix the width to keep it constant in landscape
                    } else {
                        HStack(spacing: 8) {
                            timeComponentView(value: duration.hours, label: "HOURS")
                            separatorView()
                            timeComponentView(value: duration.minutes, label: "MINUTES")
                            separatorView()
                            timeComponentView(value: duration.seconds, label: "SECONDS")
                            separatorView()
                            timeComponentView(value: duration.milliseconds, label: "MILLI")
                        }
                        .frame(height: 60) // Fix the height to keep it constant in portrait
                    }
                }
                .foregroundColor(isAccentColorDark ? .white : .black)
                .rotationEffect(rotationAngle)
            }
            .frame(width: 220, height: 60) // Fix the frame size to stay consistent
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
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: cameraManager.realOrientation)
    }
    
    private func timeComponentView(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.title3.weight(.semibold))
            Text(label)
                .font(.system(size: 8))
                .fontWeight(.medium)
        }
    }
    
    private func separatorView() -> some View {
        Group {
            if isLandscape {
                Rectangle()
                    .fill(isAccentColorDark ? Color.white.opacity(0.5) : Color.black.opacity(0.3))
                    .frame(width: 20, height: 1)
            } else {
                Rectangle()
                    .fill(isAccentColorDark ? Color.white.opacity(0.5) : Color.black.opacity(0.3))
                    .frame(width: 1, height: 20)
            }
        }
    }
}
