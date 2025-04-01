import SwiftUI
import CoreMotion

struct AboutView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollOffset: CGFloat = 0
    @State private var deviceRotation: Double = 0
    
    // For motion effects
    @State private var motionManager = MotionManager()
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var buildDate: String {
        return Bundle.main.infoDictionary?["BuildDate"] as? String ?? "Unknown"
    }
    
    var body: some View {
        ZStack {
            // Dynamic background
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // App Logo and Title
                    logoHeader
                    
                    // App Description
                    descriptionCard
                    
                    // Demo Video Card
                    demoVideoCard
                    
                    // About GyroCam
                    aboutCard
                    
                    // New Seamless Stitching Mode
                    stitchingCard
                    
                    // Features
                    featuresCard
                    
                    // Issue Tracking
                    issueTrackingCard
                    
                    // Story Behind GyroCam
                    storyCard
                    
                    // Version Info
                    versionInfoCard
                    
                    // Footer
                    Text("An app by Fayaz")
                        .font(.caption)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .coordinateSpace(name: "scroll")
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            motionManager.start()
        }
        .onDisappear {
            motionManager.stop()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color(red: 0.9, green: 0.95, blue: 1.0),
                colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.8, green: 0.9, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Components
    
    private var logoHeader: some View {
        VStack {
            Image("gyro_icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 110, height: 110)
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image("gyro_icon")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 150, height: 150)
                    )
                )
            
            Text("GyroCam")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("The Smart Orientation-Conscious Camera App")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .padding(.top, 1)
            
            Text("Never suffer from sideways videos again!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .italic()
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .padding(.top, 1)
        }
        .padding(.top, 20)
    }
    
    private var descriptionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("GyroCam revolutionizes mobile videography by automatically handling device orientation changes. Our unique Auto-Orientation System stops and restarts recording every time you rotate your device, ensuring perfect portrait/landscape alignment in every clip.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key Innovation:")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    HStack(alignment: .top) {
                        Text("✅")
                        VStack(alignment: .leading) {
                            Text("Orientation Lock")
                                .font(.subheadline).bold()
                            Text("Maintains natural perspective during complex movements")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("✅")
                        VStack(alignment: .leading) {
                            Text("Seamless Restart")
                                .font(.subheadline).bold()
                            Text("Instant recording continuation after rotation")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var demoVideoCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Demo Video 🎥")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Link(destination: URL(string: "https://www.youtube.com/watch?v=q6XoJlkMB5Q")!) {
                    ZStack {
                        Image(systemName: "play.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .foregroundColor(.red)
                            .opacity(0.8)
                        
                        Text("Watch on YouTube")
                            .font(.subheadline)
                            .bold()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("About GyroCam 🧭")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("GyroCam revolutionizes mobile videography by automatically handling device orientation changes. Our unique Auto-Orientation System stops and restarts recording every time you rotate your device, ensuring perfect portrait/landscape alignment in every clip.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding()
        }
    }
    
    private var stitchingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("✂️ New Seamless Stitching Mode")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Introducing the Seamless Stitching feature! This advanced mode eliminates gaps between clips, outputting a single continuous video where every device flip is pre-edited for you. The result? A perfectly smooth, uninterrupted final clip that automatically handles your orientation changes without missing a beat.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("This revolutionary update combines every clip into one length-perfect recording, so you no longer need to manually edit or align clips. Just capture and let GyroCam handle the rest!")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var featuresCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                Text("Features 🚀")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                AboutFeatureSection(
                    title: "📐 Orientation Intelligence",
                    items: [
                        "Real-time gyroscopic monitoring",
                        "Orientation badge overlay",
                        "Landscape lock override",
                        "Face up/down detection"
                    ]
                )
                
                AboutFeatureSection(
                    title: "🎥 Professional Capture",
                    items: [
                        "Resolutions: 4K UHD | 1080p | 720p",
                        "Frame Rates: 240fps | 120fps | 60fps | 30fps",
                        "HDR10+ Support",
                        "Multi-lens switching (Wide/Ultra Wide/Tele)",
                        "Pro Mode: Manual ISO & Shutter Speed"
                    ]
                )
                
                AboutFeatureSection(
                    title: "⚙️ Customization",
                    items: [
                        "Dynamic theme colors",
                        "Customizable UI elements",
                        "Zoom/Focus bars",
                        "Quick Settings panel",
                        "Preview maximization",
                        "Smart aspect ratio preservation"
                    ]
                )
                
                AboutFeatureSection(
                    title: "📱 Device Optimization",
                    items: [
                        "iPhone & iPad support",
                        "iOS 18 ready",
                        "Background processing",
                        "Low-light enhancements"
                    ]
                )
            }
            .padding()
        }
    }
    
    private var issueTrackingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Issue Tracking & Progress 🐛")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("We maintain complete transparency in our development process. Visit our interactive issue tracker to see:")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                VStack(alignment: .leading, spacing: 5) {
                    BulletPoint(text: "Current bug fixes in progress")
                    BulletPoint(text: "Upcoming feature development")
                    BulletPoint(text: "Recent resolutions and closed tickets")
                    BulletPoint(text: "Submit your own reports and requests")
                }
                
                Link(destination: URL(string: "https://fayaz.one/GyroCam/ISSUES.html")!) {
                    Text("View Live Issue Tracker")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                
                Text("All feature requests and bug reports are welcome! Please search existing issues before creating new ones.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var storyCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("The Story Behind GyroCam")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("GyroCam was born from a personal need. As someone living with bipolar depression, memory challenges, and processing past traumas, I found vlogging to be a powerful tool for preserving memories and making sense of my experiences. These video journals became my external memory bank - allowing me to revisit moments that would otherwise fade away.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("But there was a problem: every time I flipped my phone to switch between showing my face and my perspective, the orientation would change. What should have been a healing practice became a technical nightmare, with hours spent manually finding, splitting, and rotating segments - sometimes 10-20 orientation changes per minute of footage.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
                
                Text("GyroCam is my solution: an app that intelligently handles orientation changes as you record, eliminating hours of frustrating post-production work. What began as a personal tool to make my mental health journey easier has evolved into something I believe can help content creators, memory-keepers, and storytellers everywhere.")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
                
                Text("Every feature in this app was designed with one goal: to let you focus on capturing your story, not wrestling with technology.")
                    .font(.system(size: 16))
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var versionInfoCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("App Information")
                    .font(.title2)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Divider()
                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                
                InfoRow(label: "App Version", value: "Beta")
                InfoRow(label: "Version Number", value: appVersion)
                InfoRow(label: "Build Number", value: buildNumber)
                InfoRow(label: "Build Date", value: buildDate)
                
                Divider()
                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                
                Text("Contact Information")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
                
                Text("If you have any questions about this app or want to report a bug, contact me directly at:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("1@fayaz.one")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var motionManager = MotionManager()
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    // Base glass effect
                    RoundedRectangle(cornerRadius: 25)
                        .fill(colorScheme == .dark ?
                              Color.white.opacity(0.1) :
                              Color.white.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Material.ultraThinMaterial)
                        )
                    
//                    // Reflective highlight
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
//                                    Color.white.opacity(0.0)
//                                ]),
//                                startPoint: UnitPoint(
//                                    x: 0.5 + (motionManager.roll / 6),
//                                    y: 0.0 + (motionManager.pitch / 6)
//                                ),
//                                endPoint: UnitPoint(
//                                    x: 0.5 - (motionManager.roll / 6),
//                                    y: 1.0 - (motionManager.pitch / 6)
//                                )
//                            )
//                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
//            .rotation3DEffect(
//                .degrees(motionManager.roll * 2),
//                axis: (x: 0, y: 1, z: 0)
//            )
//            .rotation3DEffect(
//                .degrees(motionManager.pitch * 2),
//                axis: (x: 1, y: 0, z: 0)
//            )
//            .onAppear {
//                motionManager.start()
//            }
//            .onDisappear {
//                motionManager.stop()
//            }
    }
}

struct AboutFeatureSection: View {
    let title: String
    let items: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            ForEach(items, id: \.self) { item in
                BulletPoint(text: item)
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text(text)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
        }
    }
}

// MARK: - Preference Key for Scroll Offset

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
