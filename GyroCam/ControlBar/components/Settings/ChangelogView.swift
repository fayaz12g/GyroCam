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
            Section(header: header("Current Features")) {
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 009", changes: [
                    "Brought Zoom Bar into beta",
                    "New beta auto stitch feature",
                    "Disabled coming soon toggle",
                    "Disabled minimal when orientation is hidden",
                    "Added a Privacy Policy",
                    "Consolidated Camera Options",
                    "Updated changelog",
                    "Incremented version number ;)",
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 008", changes: [
                    "Introduced new settings:",
                    "Preserve Aspect Ratio",
                    "Show Clip Badge",
                    "Show Orientation Header",
                    "Minimal Orientation Header",
                    "Added Coming Soon label to zoom bar and recording timer",
                    "Added hold down to clip badge",
                    "re-centered quick settings",
                    "Quick settings now only display when not recording",
                    "Settings button now goes to the main settings (ellipsis removed)",
                    "Fixed accent color in changelog and updated missing entries",
                    "Added face down and face up support",
                    "Moved pro mode toggle to the settings"
                    
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 007", changes: [
                    "Improved the ellipsis clickability for settings",
                    "Added a stock recording sound effect",
                    "Remade the photo library view to prevent aspect ratios",
                    "Rebuilt the photo library button to fill the space",
                    "Added pro mode with more information and badges",
                    "New rainbow app icon"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 006", changes: [
                    "Replaced the second settings gear with an ellipsis",
                    "Added iPad compatabiity",
                    "Added 120 and 240 FPS",
                    "Lens is now determined by device",
                    "iOS 17 support added",
                    "Fixed orientation header position"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 005", changes: [
                    "Custom accent color theming system",
                    "Preview maximize/minimize toggle",
                    "Zoom slider controls",
                    "Background video saving for instant clip restart",
                    "Redesigned vibrant record button"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 004", changes: [
                    "Complete quick settings panel",
                    "Photo library preview integration",
                    "Geotagging support",
                    "Fixed orientation header clipping",
                    "Added this changelog view"
                ])
            }
            
            Section(header: header("Core Development")) {
                VersionEntry(cameraManager: cameraManager, version: "Alpha 003", changes: [
                    "Double-tap lens switching",
                    "Dynamic UI color schemes",
                    "Enhanced recording indicators",
                    "Basic quick settings foundation"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 002", changes: [
                    "iOS-style animated record button",
                    "System-wide dark/light mode",
                    "Persistent orientation headers",
                    "First app icon design"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 001", changes: [
                    "4K/1080p resolution support",
                    "Front camera implementation",
                    "Clip counter badge",
                    "Default 60FPS recording",
                    "Fixed 144p encoding bug"
                ])
                
                VersionEntry(cameraManager: cameraManager, version: "Alpha 00", changes: [
                    "Gyroscopic clip splitting",
                    "720p HDR recording",
                    "30/60FPS toggle",
                    "Basic camera framework",
                    "Initial orientation detection"
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
