//
//  ChangelogView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct ChangelogView: View {
    var body: some View {
        Form {
            Section(header: header("Current Features")) {
                VersionEntry(version: "Alpha 005", changes: [
                    "Custom accent color theming system",
                    "Preview maximize/minimize toggle",
                    "Zoom slider controls",
                    "Background video saving for instant clip restart",
                    "Redesigned vibrant record button"
                ])
                
                VersionEntry(version: "Alpha 004", changes: [
                    "Complete quick settings panel",
                    "Photo library preview integration",
                    "Geotagging support",
                    "Fixed orientation header clipping",
                    "Added this changelog view"
                ])
            }
            
            Section(header: header("Core Development")) {
                VersionEntry(version: "Alpha 003", changes: [
                    "Double-tap lens switching",
                    "Dynamic UI color schemes",
                    "Enhanced recording indicators",
                    "Basic quick settings foundation"
                ])
                
                VersionEntry(version: "Alpha 002", changes: [
                    "iOS-style animated record button",
                    "System-wide dark/light mode",
                    "Persistent orientation headers",
                    "First app icon design"
                ])
                
                VersionEntry(version: "Alpha 001", changes: [
                    "4K/1080p resolution support",
                    "Front camera implementation",
                    "Clip counter badge",
                    "Default 60FPS recording",
                    "Fixed 144p encoding bug"
                ])
                
                VersionEntry(version: "Alpha 00", changes: [
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
