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
            Section(header: header("Recent Updates")) {
                VersionEntry(version: "Alpha 03", changes: [
                    "Added photo library integration",
                    "Implemented preview size toggle",
                    "Introduced quick settings adjustments",
                    "Added lens switching gesture (double-tap)",
                    "Launched custom color theming system"
                ])
                
                VersionEntry(version: "Alpha 02", changes: [
                    "Initial camera implementation",
                    "Basic recording functionality",
                    "Foundation UI components"
                ])
            }
        }
        .navigationTitle("Changelog")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func header(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .textCase(nil)
            .padding(.vertical, 8)
    }
}
