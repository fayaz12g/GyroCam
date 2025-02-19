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
                FeatureGroup(title: "Core Functionality", features: [
                    "Fill preview bug fixes",
                    "Background haptics while saving",
                    "Device metadata improvements (location)",
                    "Aspect ratio mode selector with gridlines",
                    "Lens switching during recording (if Apple allows)"
                ])
                
                FeatureGroup(title: "Interface Enhancements", features: [
                    "HDR overlays to match image",
                    "Pinch-to-zoom gestures with full zoom bar",
                    "Tap-to-focus system",
                    "Recording status visualization with timer",
                ])
                
                FeatureGroup(title: "Advanced Capabilities", features: [
                    "Manual exposure controls (ISO/shutter)",
                    "Clip management tools (deletion, renaming)",
                    "Full audio feedback integration",
                ])
            }
        }
        .navigationTitle("Roadmap")
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

