//
//  ChangelogView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct ChangelogView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Form {
            Section(header: header("Alpha Releases")) {
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 013", changes: [
                    ChangeEntry(title: "Changelog", details: [
                        "Renamed headers to be more aligned with proper descriptions",
                    ]),
                    ChangeEntry(title: "Settings", details: [
                        "Major restructure of the settings view",
                        "Added new 'about' submenu containing version number and brief description",
                        "An alert now pops up to display when default settings have been restored"
                    ]),
                    ChangeEntry(title: "App Icon", details: [
                        "Once again more changes have been made, this time reintroducing the color from previous iterations, as well as incorporating it agaisnt the rainbow back, witht the shadow consstent in dark mode.",
                    ]),
                    ChangeEntry(title: "Onboarding View", details: [
                        "Centered the permissions page",
                        "Change the color of the permissions page to accent color if seen before",
                        "Fixed a clipping issue with the lock icon"
                    ]),
                    ChangeEntry(title: "Bux Fixes", details: [
                        "Fixed a plethora of on change warnings to conform to iOS 17+",
                        "Fixed warnings involving loctaion manager",
                        "Load Latest thumbnail is now called on Photo Library Button after recording is saved",
                    ]),
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 012", changes: [
                    ChangeEntry(title: "Added new camera gestures:", details: [
                        "Drag across the screen to adjust focus while auto focus is off",
                        "Hold down to switch lenses in a new picker, now in a square format with rotation and device theme conformity"
                    ]),
                    ChangeEntry(title: "Recording Pulse Effect", details: [
                    "Changed the pulse effect to only display while recording",
                    "Updated the pulse effect to be faster and start from the center",
                    ]),
                    ChangeEntry(title: "Other", details: [
                        "Added a new toggle to show/hide quick settings",
                        "The zoom bar now moves at an exponentially increasing rate (such that 1x to 2x is the same as 5x to 10x)",
                        "Added a new torch option to the quick settings bar and settings page. This toggles the camera flash",
                        "Removed experimental shutter speed due to crashing on some devices",
                        "Updated the photo library button to refer to camera manager directly to handle rotation",
                        "Updated the changelog view to handle titles and sub bullets, including a full revamp of all previous entries",
                        "Added animations for the focal bar, zoom bar, and quick settings menu dissapearing"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 011", changes: [
                    ChangeEntry(title: "Logo Update", details: ["Updated the app logo, removing the camera icon for a cleaner look."]),
                    ChangeEntry(title: "Orientation Badge", details: ["Added context menu parity to hide the orientation badge for better UI customization."]),
                    ChangeEntry(title: "Onboarding View", details: ["Refined the onboarding experience with new content describing camera controls to help users understand their functionality."]),
                    ChangeEntry(title: "Zoom Bar", details: ["The zoom bar is now fully functional and has been brought out of beta."]),
                    ChangeEntry(title: "Pinch-to-Zoom Gestures", details: ["Implemented pinch-to-zoom gestures for intuitive zoom control, working seamlessly with the zoom bar."]),
                    ChangeEntry(title: "Focus Bar", details: ["Introduced a new Focus Bar, enabling manual focus controls for advanced users."]),
                    ChangeEntry(title: "Focus and Auto Focus Logic", details: ["Added logic to make manual focus and auto focus mutually exclusive, ensuring a smoother experience when adjusting focus."]),
                    ChangeEntry(title: "Tap-to-Focus", details: ["Added a tap-to-focus system, allowing users to tap the screen to set focus when auto focus is off."]),
                    ChangeEntry(title: "Continuous Auto Focus", details: ["Introduced a continuous auto focus system that tracks and adjusts focus automatically."]),
                    ChangeEntry(title: "Auto Exposure Controls", details: ["Added auto exposure control, with manual shutter speed and ISO options available for future functionality (shells only, no active functionality yet)."])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 010", changes: [
                    ChangeEntry(title: "Onboarding Screen", details: [
                        "Added the onboarding screen with centralized permissions requests"
                    ]),
                    ChangeEntry(title: "Roadmap", details: [
                        "Updated the roadmap to be more in line with planned features"
                    ]),
                    ChangeEntry(title: "App Logos", details: [
                        "Introduced new App Logos"
                    ]),
                    ChangeEntry(title: "Camera Orientation Updates", details: [
                        "Added the Landscape Lock feature",
                        "Adjusted how Face Up and Face Down orientations are handled"
                    ]),
                    ChangeEntry(title: "Onboarding Customization", details: [
                        "Added a show onboarding button in settings",
                        "Onboarding is rainbow-themed the first time and follows accent color after that"
                    ]),
                    ChangeEntry(title: "Camera Control", details: [
                        "Added rudimentary support for Camera Control"
                    ]),
                    ChangeEntry(title: "iOS 18 Compatibility", details: [
                        "Bumped to iOS 18 minimum"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 009", changes: [
                    ChangeEntry(title: "Zoom Bar", details: [
                        "Brought Zoom Bar into beta"
                    ]),
                    ChangeEntry(title: "Beta Features", details: [
                        "New beta auto stitch feature"
                    ]),
                    ChangeEntry(title: "Other Updates", details: [
                        "Disabled coming soon toggle",
                        "Disabled minimal when orientation is hidden",
                        "Added a Privacy Policy",
                        "Consolidated Camera Options",
                        "Updated changelog",
                        "Incremented version number ;)"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 008", changes: [
                    ChangeEntry(title: "New Settings", details: [
                        "Preserve Aspect Ratio",
                        "Show Clip Badge",
                        "Show Orientation Header",
                        "Minimal Orientation Header"
                    ]),
                    ChangeEntry(title: "Zoom and Recording", details: [
                        "Added Coming Soon label to zoom bar and recording timer"
                    ]),
                    ChangeEntry(title: "Quick Settings and UI Adjustments", details: [
                        "Re-centered quick settings",
                        "Quick settings now only display when not recording"
                    ]),
                    ChangeEntry(title: "Other Changes", details: [
                        "Settings button now goes to the main settings (ellipsis removed)",
                        "Fixed accent color in changelog and updated missing entries",
                        "Added face down and face up support",
                        "Moved pro mode toggle to the settings"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 007", changes: [
                    ChangeEntry(title: "Settings Improvements", details: [
                        "Improved the ellipsis clickability for settings"
                    ]),
                    ChangeEntry(title: "Sound Effects", details: [
                        "Added a stock recording sound effect"
                    ]),
                    ChangeEntry(title: "Photo Library Updates", details: [
                        "Remade the photo library view to prevent aspect ratios",
                        "Rebuilt the photo library button to fill the space"
                    ]),
                    ChangeEntry(title: "Pro Mode", details: [
                        "Added pro mode with more information and badges"
                    ]),
                    ChangeEntry(title: "App Icon", details: [
                        "New rainbow app icon"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 006", changes: [
                    ChangeEntry(title: "UI Changes", details: [
                        "Replaced the second settings gear with an ellipsis"
                    ]),
                    ChangeEntry(title: "iPad and FPS Support", details: [
                        "Added iPad compatibility",
                        "Added 120 and 240 FPS"
                    ]),
                    ChangeEntry(title: "Lens and iOS Updates", details: [
                        "Lens is now determined by device",
                        "iOS 17 support added"
                    ]),
                    ChangeEntry(title: "Orientation", details: [
                        "Fixed orientation header position"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 005", changes: [
                    ChangeEntry(title: "Custom Theming", details: [
                        "Custom accent color theming system"
                    ]),
                    ChangeEntry(title: "Preview and Zoom Controls", details: [
                        "Preview maximize/minimize toggle",
                        "Zoom slider controls"
                    ]),
                    ChangeEntry(title: "Background Processing", details: [
                        "Background video saving for instant clip restart"
                    ]),
                    ChangeEntry(title: "Record Button", details: [
                        "Redesigned vibrant record button"
                    ])
                ])

                VersionEntry(cameraManager: cameraManager, version: "Alpha 004", changes: [
                    ChangeEntry(title: "Quick Settings and Photo Library", details: [
                        "Complete quick settings panel",
                        "Photo library preview integration"
                    ]),
                    ChangeEntry(title: "New Features", details: [
                        "Geotagging support"
                    ]),
                    ChangeEntry(title: "Fixes", details: [
                        "Fixed orientation header clipping"
                    ]),
                    ChangeEntry(title: "Changelog", details: [
                        "Added this changelog view"
                    ])
                ])

            }
            
            Section(header: header("Internal Builds")) {
                VersionEntry(cameraManager: cameraManager, version: "Alpha 003", changes: [
                    ChangeEntry(title: nil, details: [
                        "Double-tap lens switching",
                        "Dynamic UI color schemes",
                        "Enhanced recording indicators",
                        "Basic quick settings foundation"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 002", changes: [
                    ChangeEntry(title: nil, details: [
                        "iOS-style animated record button",
                        "System-wide dark/light mode",
                        "Persistent orientation headers",
                        "First app icon design"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 001", changes: [
                    ChangeEntry(title: nil, details: [
                        "4K/1080p resolution support",
                        "Front camera implementation",
                        "Clip counter badge",
                        "Default 60FPS recording",
                        "Fixed 144p encoding bug"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 00", changes: [
                    ChangeEntry(title: nil, details: [
                        "Gyroscopic clip splitting",
                        "720p HDR recording",
                        "30/60FPS toggle",
                        "Basic camera framework",
                        "Initial orientation detection"
                    ])
                ])
            }
        }
        .navigationTitle("Version History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func header(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundColor(.primary)
            .textCase(nil)
            .padding(.vertical, 8)
    }
}
