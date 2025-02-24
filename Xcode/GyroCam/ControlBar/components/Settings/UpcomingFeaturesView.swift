//
//  UpcomingFeaturesView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct UpcomingFeaturesView: View {
    @ObservedObject var cameraManager: CameraManager
    var body: some View {
        Form {
            Section(header: header("Development Pipeline")) {

                FeatureGroup(title: "Features & Enhancements", features: [
                    "HDR overlays to match image",
                    "Recording status visualization with timer",
                    "Implement full iPhone 16+ Camera Control Support",
                    "Implement locked camera Control Center support",
                    "Aspect ratio mode selector with gridlines",
                    "Lens switching during recording/zooming",
                    "Manual exposure controls (ISO/shutter)",
                    "Clip management tools (deletion, renaming)",
                ])
                
                FeatureGroup(title: "Bug Fixes/Unexpected Behavior", features: [
                    "Maximize Preview doesn't reload till app reload",
                    "Export time estimate just shows the clip duration",
                    "Toggle flash causes weird issues when configuring session",
                    "Photo Library metadata does not display properly in Grid View for non 16:9 content",
                    "Saving button action is not disabled",
                    "Grammatical and spelling errors in Changelog View"
                    
                ])
            }
        }
        .navigationTitle("Upcoming Features")
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

