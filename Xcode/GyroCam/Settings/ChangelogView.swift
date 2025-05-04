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
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Beta Releases Section
                    SectionHeader(title: "Beta Releases")
                    
                    VStack(spacing: 20) {
                        
                        
                        VersionEntry(
                            version: "0.1.12",
                            date: "May 5, 2025",
                            type: .beta(version: 12),
                            changes: [
                                .init(type: .improved, description: "Updated the app icon."),
                                .init(type: .improved, description: "Updated the versioning information and names for initial betas (matched on the webpage too)."),
                            ],
                            fixedIssues: []
                        )
                        
                        VersionEntry(
                            version: "0.1.11",
                            date: "May 4, 2025",
                            type: .beta(version: 11),
                            changes: [
                                .init(type: .added, description: "Added WishKit integration for a custom feature wish list."),
                                .init(type: .added, description: "New profile view to manage a set name and email to be shared with WishKit."),
                                .init(type: .improved, description: "Adjusted naming of 'Upcoming Features' to 'GitHub Roadmap' to better differentiate the new Wish List View."),
                                .init(type: .fixed, description: "Fixed haptics not working on rotation after accessing a sheet."),
                                .init(type: .fixed, description: "Fixed changelog entries all saying beta 4"),
                                .init(type: .changed, description: "Removed the motion manager"),
                                .init(type: .fixed, description: "The app no longer crashes on startup due to async calls"),
                                .init(type: .changed, description: "Camera, motion and haptics are now killed when the app is not in focus (and restarted when back in focus)"),
                                .init(type: .added, description: "Added an option to disable real orientation display of ui"),
                                .init(type: .added, description: "Segmented picker now uses correct text color"),
                                .init(type: .fixed, description: "Lock landscape no longer starts with portrait"),
                                .init(type: .fixed, description: "Fixed non stitched clips saving in the incorrect orientation"),
                                .init(type: .added, description: "Added triggering for stopping and starting recording with volume up or down (optional)"),
                                .init(type: .added, description: "The entire permissions row is now clickable and has a background to match other ui elements."),
                                .init(type: .improved, description: "The GitHub roadmap page has been revamped"),
                            ],
                            fixedIssues: [46, 49, 50, 51, 53, 55, 56]
                        )
                        
                        VersionEntry(
                            version: "0.1.10",
                            date: "April 30, 2025",
                            type: .beta(version: 10),
                            changes: [
                                .init(type: .added, description: "The camera and microphone no longer remain in use with the settings menu and photo library views open."),
                                .init(type: .fixed, description: "Addressed a bug where the new permissions page in settings used the wrong user color."),
                                .init(type: .improved, description: "Adjusted badges in the privacy policy view to use the primary color."),
                                .init(type: .improved, description: "Added notification usage descriptions to the privacy policy."),
                                .init(type: .changed, description: "Settings Contrast renamed to Settings Backgrounds."),
                                .init(type: .added, description: "Settings can now be toggled between a sheet and full screen cover."),
                                .init(type: .added, description: "Added a new developer mode, which shows more settings"),
                                .init(type: .changed, description: "Moved the settings sheet toggle, hide export sheet duration, and allow recording while savings options behind developer mode."),
                                .init(type: .changed, description: "Updated the saving dots view to use an accurate export percentage."),
                                .init(type: .changed, description: "Reordered the pulsing recording effect to be behind the stop button (now that they're different colors)."),
                                .init(type: .added, description: "Added an option to disable the recording pulse"),
                                .init(type: .fixed, description: "Removed old code for focal adjustments."),
                                .init(type: .improved, description: "The quick lens switcher now orients properly based on real orientation."),
                                .init(type: .changed, description: "The ISO bar has been updated to have the new UI of the focus bar, including tap to switch to auto exposure, and moving the ISO thumb with value changes."),
                                .init(type: .changed, description: "Manual ISO in settings is now more obvious with a header and uses the new GyroScroll"),
                                .init(type: .fixed, description: "Removed all warnings (again)"),
                                .init(type: .fixed, description: "Renamed hardcoded 3x in quick lens switcher to 'tele'. May change to real number later."),
                                .init(type: .fixed, description: "Fixed an issue where returning from onboarding made the background show the camera."),
                                .init(type: .fixed, description: "Having settings backgrounds off now results in a whiter white or blacker black regardless of sheet or full screen cover."),
                            ],
                            fixedIssues: [32, 33, 38, 44, 48]
                        )
                        
                        VersionEntry(
                            version: "0.1.9",
                            date: "April 28, 2025",
                            type: .beta(version: 9),
                            changes: [
                                .init(type: .fixed, description: "Concurrent exports now support the proper orientation handling."),
                                .init(type: .added, description: "Failed exports can now be restarted."),
                                .init(type: .fixed, description: "Junk from failed exports can now be purged."),
                                .init(type: .improved, description: "The exports sheet now remains showing exports across force quitting the app."),
                                .init(type: .changed, description: "Many internal overhauls to the system that handles mapping orientation changes to URLs."),
                                .init(type: .added, description: "Notifications are now delivered upon successful exports."),
                                .init(type: .added, description: "Notifications can be allowed or skipped in onboarding, and configured later in settings."),
                                .init(type: .added, description: "Animations have been added to the export sheet, with a pulsing progress bar and spinning hourglass."),
                                .init(type: .changed, description: "Slightly updated the about view to have more conformant sizing."),
                                .init(type: .added, description: "Location privileges are now optional."),
                                .init(type: .changed, description: "Background colors across navigation views are now consistent and conform to in app contrast settings."),
                                .init(type: .added, description: "A new misc navigation page for permissions is visible. Accent color only appears when navigated to from settings, with the correct background too."),
                                .init(type: .added, description: "The background gradient is now a single custom view extension that can be used anywhere. This background indicates subsections of settings."),
                                .init(type: .fixed, description: "Fixed an incorrect SF Symbol in the Privacy Policy."),
                                .init(type: .added, description: "Introduced a new color option: Primary Color"),
                                .init(type: .fixed, description: "The focus bar updates position correctly in auto focus now, and has a better ring."),
                                .init(type: .improved, description: "Privacy policy now conforms to accent color."),
                                .init(type: .improved, description: "Settings backgrounds now conforms to primary color."),
                            ],
                            fixedIssues: [45, 47]
                        )
                        
                        VersionEntry(
                            version: "0.1.8",
                            date: "April 23, 2025",
                            type: .beta(version: 8),
                            changes: [
                                .init(type: .added, description: "Implemented a customizable haptic on orientation change."),
                                .init(type: .fixed, description: "Fixed an issue in the capture tab causing the reset defaults button to become inaccessible."),
                                .init(type: .changed, description: "The duration badge now matches the new glassy UI."),
                                .init(type: .changed, description: "The duration badge is now split into sections with subheadings."),
                                .init(type: .added, description: "New double dictating how long to close the export sheet after queueing."),
                                .init(type: .added, description: "The export sheet now animates in and out properly."),
                                .init(type: .added, description: "New variable default to false to show export sheet right after recording."),
                                .init(type: .changed, description: "A rudimentary updated algorithem flips the orientation sooner. Future update will log gyroscope data periodically as reference."),
                                .init(type: .changed, description: "The export sheet now shows a green checkmark upon completion before dissapearing."),
                                
                                    .init(type: .fixed, description: "Video metadata now properly shows the device the video was taken on. Lens metadata coming TBD."),
                            ],
                            fixedIssues: [22]
                        )
                        
                        VersionEntry(
                            version: "0.1.7",
                            date: "March 31, 2025",
                            type: .beta(version: 7),
                            changes: [
                                .init(type: .changed, description: "Restored badge fonts and settings circle"),
                                .init(type: .changed, description: "Updated bars to have the new glassy circles"),
                                .init(type: .changed, description: "Restored settings button shape, bigger bolder icon"),
                                .init(type: .changed, description: "Made the badges have rounded rectangular edges"),
                                .init(type: .changed, description: "Updated the bars to fit the number better and have descriptors in line with ISO bar"),
                                .init(type: .changed, description: "Updated the bars to all be the same length"),
                                .init(type: .changed, description: "Revamped the provacy policy view to match the new about view"),
                                .init(type: .changed, description: "Updated the gyrocam icon in the about view to match onboarding"),
                                .init(type: .changed, description: "Reduced animation timings in settings"),
                                
                            ],
                            fixedIssues: []
                        )
                        
                        VersionEntry(
                            version: "0.1.6",
                            date: "March 31, 2025",
                            type: .beta(version: 6),
                            changes: [
                                .init(type: .fixed, description: "Restored accent color customization"),
                                .init(type: .fixed, description: "Fixed a bug where the last clip is alwasys upside down"),
                                .init(type: .fixed, description: "Fixed a bug making the new QuickSettingsView subtext hard to read"),
                                .init(type: .changed, description: "Made the export stack button more modern and moved to a a better place"),
                                .init(type: .changed, description: "Updated the UI of the badges and settings button to have symmertry and match the visionOS like iOS 19 leaks"),
                                .init(type: .added, description: "Added a motion manager to create depth with badges"),
                                .init(type: .changed, description: "Update the belt to match this new UI"),
                                .init(type: .fixed, description: "Fixed a light mode issue of inconsistent backgrounds in settings"),
                                .init(type: .fixed, description: "Fixed the clipping of toggles on the far right (build 319)"),
                                .init(type: .added, description: "New toggle type replacing the old one."),
                                .init(type: .added, description: "New control bars category in settings"),
                                .init(type: .changed, description: "Adjusted the sizing of the clip badge to match the orientation badge"),
                                .init(type: .fixed, description: "Adjusted font color of toggles based on accent color darkness"),
                                .init(type: .fixed, description: "Fixed lock landscape duration badge being blocked by orientation badge in portrait"),
                                .init(type: .added, description: "New custom segemented pickers with headings"),
                                .init(type: .changed, description: "Internal name for pickers and toggles are prefixed with Gyro"),
                                .init(type: .changed, description: "Reordered some settings to better fit the new system"),
                                .init(type: .changed, description: "Reinvented the accent color picker with default presets included"),
                                .init(type: .changed, description: "Updated the background in the About and Privacy Policy Views"),
                                .init(type: .changed, description: "Completly revamped the about view to closely resemble the read me"),
                            ],
                            fixedIssues: [41, 42]
                        )
                        
                        VersionEntry(
                            version: "0.1.5",
                            date: "March 20, 2025",
                            type: .beta(version: 5),
                            changes: [
                                .init(type: .improved, description: "Redesigned settings interface with modern floating tab bar"),
                                .init(type: .added, description: "New belt-style navigation with animated tab transitions"),
                                .init(type: .fixed, description: "Fixed orientation issues with final video segment after flipping"),
                                .init(type: .improved, description: "Enhanced settings organization with expandable sections"),
                                .init(type: .added, description: "Added settings contrast toggle for better visibility"),
                                .init(type: .changed, description: "Moved export progress back to recording button"),
                                .init(type: .improved, description: "Modernized version history and information views"),
                                .init(type: .improved, description: "Improved the upcoming features view to pull directly from GitHub issues"),
                                .init(type: .improved, description: "Enhanced visual feedback for settings interactions")
                            ],
                            fixedIssues: [36, 11, 10, 1, 34, 30, 26, 27, 19, 9, 37]
                        )
                        
                        VersionEntry(
                            version: "0.1.4",
                            date: "March 2, 2025",
                            type: .beta(version: 4),
                            changes: [
                                .init(type: .added, description: "A new Duration badge shows how long you've been recording for."),
                                .init(type: .improved, description: "The duration badge changes the text color based on the backing accent color brightness."),
                                .init(type: .changed, description: "Orientation Header renamed to 'orientation badge' in the code."),
                                .init(type: .added, description: "The record saving button shows clip duration as a percentage increasing. It hangs add 100% till complete.")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.1.3",
                            date: "February 25, 2025",
                            type: .beta(version: 3),
                            changes: [
                                .init(type: .added, description: "New feature selection for export quality, though I always recommend the highest for HDR or 60FPS. This significantly increases export speed though."),
                                .init(type: .added, description: "Updated versioning naming conventions to match the new one throughout the changelog."),
                                .init(type: .added, description: "Added ISO control, and toggling auto exposure off works now."),
                                .init(type: .added, description: "Stitching can now take place in the background, including if you lock your phone!"),
                                .init(type: .added, description: "In Lock Landscape, badges now rotate to show you everything upright."),
                                .init(type: .added, description: "The above change also applies to the photo thumbnail and bar circles."),
                                .init(type: .added, description: "A new ISO bar exists that works when auto exposure is off."),
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.1.2",
                            date: "February 23, 2025",
                            type: .beta(version: 2),
                            changes: [
                                .init(type: .added, description: "Added a new looping sound when saving stitched video."),
                                .init(type: .added, description: "A new double timer counts down while saving to show progress."),
                                .init(type: .added, description: "Added haptics to record button, settings button, toggles, photo library button, and saving loop."),
                                .init(type: .added, description: "For now haptics require you to interact with the record button first. A better solution will be implemented later."),
                                .init(type: .added, description: "Added a setting to turn haptics off."),
                                .init(type: .added, description: "Added a setting to turn sounds off."),
                                .init(type: .added, description: "Brought the app into Beta releases."),
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.1.1",
                            date: "February 22, 2025",
                            type: .beta(version: 1),
                            changes: [
                                .init(type: .added, description: "Videos now save with appropriate GRC filenames"),
                                .init(type: .added, description: "Saved videos now contain location metadata"),
                                .init(type: .improved, description: "Tweaked text in onboarding"),
                                .init(type: .improved, description: "Adjusted badge locations")
                            ]
                        )
                    }
                    
                    
                    // Alpha Releases Section
                    SectionHeader(title: "Alpha Releases")
                
                    VStack(spacing: 20) {
                        VersionEntry(
                            version: "0.0.16",
                            date: "February 21, 2025",
                            type: .alpha(version: 16),
                            changes: [
                                .init(type: .improved, description: "Restructured onboarding with titles and sub bullets"),
                                .init(type: .fixed, description: "Fixed finish button not working after reinstating privileges"),
                                .init(type: .changed, description: "Settings view changed from sheet to full screen page"),
                                .init(type: .added, description: "Seamless stitching integration"),
                                .init(type: .added, description: "New saving indicator on recording button")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.15",
                            date: "February 21, 2025",
                            type: .alpha(version: 15),
                            changes: [
                                .init(type: .added, description: "Focus bar with tappable circle handle for auto focus"),
                                .init(type: .added, description: "Stabilization options in settings"),
                                .init(type: .fixed, description: "Fixed deprecated syntax warnings"),
                                .init(type: .improved, description: "Updated onboarding with matching color scheme"),
                                .init(type: .improved, description: "Enhanced permissions handling")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.14",
                            date: "February 20, 2025",
                            type: .alpha(version: 14),
                            changes: [
                                .init(type: .improved, description: "Major restructure of settings view"),
                                .init(type: .added, description: "New 'about' submenu with version info"),
                                .init(type: .improved, description: "Updated app icon with rainbow back"),
                                .init(type: .fixed, description: "Fixed iOS 17+ warnings"),
                                .init(type: .fixed, description: "Fixed thumbnail loading after recording")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.13",
                            date: "February 20, 2025",
                            type: .alpha(version: 13),
                            changes: [
                                .init(type: .added, description: "New camera gestures for focus and lens switching"),
                                .init(type: .improved, description: "Enhanced recording pulse effect"),
                                .init(type: .added, description: "Quick settings toggle"),
                                .init(type: .added, description: "Pro mode with additional information"),
                                .init(type: .changed, description: "New rainbow app icon")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.12",
                            date: "February 20, 2025",
                            type: .alpha(version: 12),
                            changes: [
                                .init(type: .improved, description: "Updated app logo design"),
                                .init(type: .added, description: "Context menu for orientation badge"),
                                .init(type: .improved, description: "Enhanced onboarding experience"),
                                .init(type: .added, description: "Fully functional zoom bar"),
                                .init(type: .added, description: "Focus system with manual and auto controls")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.11",
                            date: "February 20, 2025",
                            type: .alpha(version: 11),
                            changes: [
                                .init(type: .added, description: "Onboarding screen with centralized permissions"),
                                .init(type: .added, description: "Landscape Lock feature"),
                                .init(type: .improved, description: "Updated orientation handling"),
                                .init(type: .added, description: "Basic camera control support"),
                                .init(type: .changed, description: "Bumped to iOS 18 minimum")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.10",
                            date: "February 19, 2025",
                            type: .alpha(version: 10),
                            changes: [
                                .init(type: .added, description: "Zoom Bar beta feature"),
                                .init(type: .added, description: "Auto stitch beta feature"),
                                .init(type: .added, description: "Privacy Policy"),
                                .init(type: .improved, description: "Consolidated Camera Options")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.9",
                            date: "February 4, 2025",
                            type: .alpha(version: 9),
                            changes: [
                                .init(type: .added, description: "New settings for aspect ratio and badges"),
                                .init(type: .improved, description: "Re-centered quick settings"),
                                .init(type: .added, description: "Face down and face up support"),
                                .init(type: .changed, description: "Moved pro mode toggle to settings")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.8",
                            date: "February 3, 2025",
                            type: .alpha(version: 8),
                            changes: [
                                .init(type: .improved, description: "Enhanced settings accessibility"),
                                .init(type: .added, description: "Stock recording sound effect"),
                                .init(type: .improved, description: "Rebuilt photo library view"),
                                .init(type: .added, description: "Pro mode with badges"),
                                .init(type: .changed, description: "New rainbow app icon")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.7",
                            date: "February 1, 2025",
                            type: .alpha(version: 7),
                            changes: [
                                .init(type: .changed, description: "Replaced settings gear with ellipsis"),
                                .init(type: .added, description: "iPad compatibility"),
                                .init(type: .added, description: "120 and 240 FPS support"),
                                .init(type: .fixed, description: "Fixed orientation header position")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.6",
                            date: "Janruary 31, 2025",
                            type: .alpha(version: 6),
                            changes: [
                                .init(type: .added, description: "Custom accent color theming"),
                                .init(type: .added, description: "Preview controls and zoom slider"),
                                .init(type: .added, description: "Background video saving"),
                                .init(type: .improved, description: "Redesigned record button")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.5",
                            date: "Janruary 30, 2025",
                            type: .alpha(version: 5),
                            changes: [
                                .init(type: .added, description: "Complete quick settings panel"),
                                .init(type: .added, description: "Photo library preview"),
                                .init(type: .added, description: "Geotagging support"),
                                .init(type: .fixed, description: "Fixed orientation header clipping")
                            ]
                        )
                    }
                    
                    // Internal Builds Section
                    SectionHeader(title: "Internal Builds")
                    
                    VStack(spacing: 20) {
                        VersionEntry(
                            version: "0.0.4",
                            date: "Janruary 29, 2025",
                            type: .internal(version: 4),
                            changes: [
                                .init(type: .added, description: "Double-tap lens switching"),
                                .init(type: .added, description: "Dynamic UI color schemes"),
                                .init(type: .improved, description: "Enhanced recording indicators"),
                                .init(type: .added, description: "Basic quick settings foundation")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.3",
                            date: "Janruary 28, 2025",
                            type: .internal(version: 3),
                            changes: [
                                .init(type: .added, description: "iOS-style animated record button"),
                                .init(type: .added, description: "System-wide dark/light mode"),
                                .init(type: .added, description: "Persistent orientation headers"),
                                .init(type: .added, description: "First app icon design")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.2",
                            date: "Janruary 27, 2025",
                            type: .internal(version: 2),
                            changes: [
                                .init(type: .added, description: "4K/1080p resolution support"),
                                .init(type: .added, description: "Front camera implementation"),
                                .init(type: .added, description: "Clip counter badge"),
                                .init(type: .added, description: "Default 60FPS recording"),
                                .init(type: .fixed, description: "Fixed 144p encoding bug")
                            ]
                        )
                        
                        VersionEntry(
                            version: "0.0.1",
                            date: "Janruary 26, 2025",
                            type: .internal(version: 1),
                            changes: [
                                .init(type: .added, description: "Gyroscopic clip splitting"),
                                .init(type: .added, description: "720p HDR recording"),
                                .init(type: .added, description: "30/60FPS toggle"),
                                .init(type: .added, description: "Basic camera framework"),
                                .init(type: .added, description: "Initial orientation detection")
                            ]
                        )
                    }
                }
        
                
                .padding()
            }
        .navigationTitle("Version History")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(when: cameraManager.useBlurredBackground, accentColor: cameraManager.primaryColor)
    }
}

    
