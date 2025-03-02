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
            Section(header: header("Beta Releases")) {
                
                VersionEntry(cameraManager: cameraManager, version: "0.1.4 (Beta 4)", changes: [
                    ChangeEntry(title: "Badges", details: [
                        "A new 'Duration' badge shows how long you've been recording for.",
                        "Orientation Header renamed to orientation badge in the code"
                    ]),
                    ChangeEntry(title: "Stitching", details: [
                        "The record saving button shows clip duration as a percentage increasing",
                        "It hangs at 100% until complete",
                        
                    ]),
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.1.3 (Beta 3)", changes: [
                    ChangeEntry(title: "Settings", details: [
                        "New feature selection for export quality, though I always reccommend highest for HDR or 60FPS. This significantly increases export speed though.",
                        "Updated versioning naming conventions to match new one throughout the changelog",
                        "Added ISO control and toggling auto exposure off works now"
                    ]),
                    ChangeEntry(title: "Stitching", details: [
                        "Stitching can now take place in the background, including if you lock your phone!"
                    ]),
                    ChangeEntry(title: "Orientation Handling", details: [
                        "In Lock Landscape, badges now rotate to show you everything upright.",
                        "The above change also applies to the photo thumbnail and bar circles"
                    ]),
                    ChangeEntry(title: "ISO Control", details: [
                        "A new ISO bar exists with auto exposure off."
                    ]),
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.1.3 (Beta 2)", changes: [
                    ChangeEntry(title: "Haptics", details: [
                        "Fixed an issue where haptics were tied to the record button."
                    ]),
                    ChangeEntry(title: "Optical Zoom", details: [
                        "Optical zoom now shows the correct multiplier based on device."
                    ]),
                    ChangeEntry(title: "Photo Library", details: [
                        "The video display now displays as a sheet.",
                        "The photo library has a partiy done button to settings.",
                        "The grid view now shows library date sorting akin to masonry view.",
                        "The grid view now shows badges, pro mode info, and duration for landscape videos."
                    ]),
                    ChangeEntry(title: "Internal Structure", details: [
                        "Stitched and normal clips now use the same saving function.",
                        "Removed more redundant code such as error logging.",
                        "Seperated enumerators to AppSettings.",
                        "Added folders for PhotoLibrary and Bars.",
                        "Seperated structs from within PhotoLibraryView into their own files."
                    ]),
                    ChangeEntry(title: "More Info Views", details: [
                        "About view now pulls versioning info directly from the app.",
                        "Header bars positioning were fixed for the About view and Privacy Policy.",
                        "The changelog button was renamed to fit the header (version history).",
                        "Roadmap renamed back to upcoming features.",
                        "Upcoming features edited to reflect the GitHub issues closer, alongwith new section titles.",
                        "Minor verbiage changed in settings views for stitching navigation menu.",
                    ]),
                    ChangeEntry(title: "Other Fixes", details: [
                        "Fixed bug #18: Confirmation of reset defaults was bugged."
                    ]),
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.1.1 (Beta 1)", changes: [
                    ChangeEntry(title: "Sounds", details: [
                        "Added a new looping sound when saving stitched video.",
                    ]),
                    ChangeEntry(title: "Haptics", details: [
                        "Added haptics to record button, settings button, toggles, photo library button, and saving loop.",
                        "For now haptics require you to interact with the record button first. A better solution will be implemented later."
                    ]),
                    ChangeEntry(title: "Settings", details: [
                        "Added a setting to turn haptics off.",
                        "Added a setting to turn sounds off.",
                    ]),
                    ChangeEntry(title: "Saving Button", details: [
                        "The saving button now shows a double progress countdown while saving.",
                    ]),
                    ChangeEntry(title: "Versioning", details: [
                        "Brought the app into Beta releases.",
                    ]),
                ])
            }
                
            Section(header: header("Alpha Releases")) {
                        
            VersionEntry(cameraManager: cameraManager, version: "0.1.0 (Alpha 016)", changes: [
                ChangeEntry(title: "Video Saving", details: [
                    "Videos now save with appropriate GRC filenames.",
                    "Saved videos now contain location metadata.",
                ]),
                ChangeEntry(title: "Onboarding", details: [
                    "Tweaked text in oboarding"
                ]),
                ChangeEntry(title: "Other", details: [
                    "Adjusted badge locations"
                ]),
            ])
                    
            VersionEntry(cameraManager: cameraManager, version: "0.0.16 (Alpha 015)", changes: [
                ChangeEntry(title: "Onboarding", details: [
                    "Restructure with titles, sub bullets, and more symbols.",
                    "Improved the clutter of page three as well as verbiage in other pages.",
                    "Fixed an issue where the finish button did not work after reinstating priveleges"
                ]),
                ChangeEntry(title: "Settings", details: [
                    "The settinsg view has changed from a sheet to a full screen page.",
                    "Lock landscape has been moved to output seettings.",
                    "Stitch clips now requires lock landscape to be on.",
                ]),
                ChangeEntry(title: "Stitching", details: [
                    "Stitching now works with SEAMLESS integration",
                    "Stitching is no longer in beta"
                ]),
                ChangeEntry(title: "Recording Button", details: [
                    "A new saving indicator displays on the recording button",
                ]),
            ])
            VersionEntry(cameraManager: cameraManager, version: "0.0.15 (Alpha 014)", changes: [
                ChangeEntry(title: "Focus", details: [
                    "The focus bar now has a tappable circle handle that turns on auto focus",
                ]),
                ChangeEntry(title: "Stablization", details: [
                    "Stabilization added to settings",
                    "Switch between no stabilization, standard, cinematic, and extreme, or auto",
                ]),
                ChangeEntry(title: "Bux Fixes", details: [
                    "Fixed more warnings for deprecated syntax"
                ]),
                ChangeEntry(title: "Other", details: [
                    "Onboarding gyro cam logo now has matching color scheme",
                    "Light mode background reverted to white",
                    "Moved some settings around",
                    "Onboarding button shows next until the last page",
                    "Centered onboarding button",
                    "Updated permissions handling to navigate to settings and open onboarding on revoke"
                ]),
            ])

                    
                VersionEntry(cameraManager: cameraManager, version: "0.0.14 (Alpha 013)", changes: [
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
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.13 (Alpha 012)", changes: [
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
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.12 (Alpha 011)", changes: [
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
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.11 Alpha 010", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.10 (Alpha 009)", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.9 (Alpha 008)", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.8 (Alpha 007)", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.7 (Alpha 006)", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.6 (Alpha 005)", changes: [
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

                VersionEntry(cameraManager: cameraManager, version: "0.0.5 (Alpha 004)", changes: [
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
                VersionEntry(cameraManager: cameraManager, version: "0.0.4 (Alpha 003)", changes: [
                    ChangeEntry(title: nil, details: [
                        "Double-tap lens switching",
                        "Dynamic UI color schemes",
                        "Enhanced recording indicators",
                        "Basic quick settings foundation"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.3 (Alpha 002)", changes: [
                    ChangeEntry(title: nil, details: [
                        "iOS-style animated record button",
                        "System-wide dark/light mode",
                        "Persistent orientation headers",
                        "First app icon design"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.2 (Alpha 001)", changes: [
                    ChangeEntry(title: nil, details: [
                        "4K/1080p resolution support",
                        "Front camera implementation",
                        "Clip counter badge",
                        "Default 60FPS recording",
                        "Fixed 144p encoding bug"
                    ])
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "0.0.1 (Alpha 00)", changes: [
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
