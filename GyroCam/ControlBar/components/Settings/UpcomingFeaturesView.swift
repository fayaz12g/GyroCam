//
//  UpcomingFeaturesView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct UpcomingFeaturesView: View {
    var body: some View {
        Form {
            Section(header: header("Development Pipeline")) {
                FeatureGroup(title: "Core Functionality", features: [
                    "Fill preview implementation",
                    "Background saving during next clip",
                    "Device metadata improvements",
                    "Aspect ratio mode selector",
                    "Lens switching during recording"
                ])
                
                FeatureGroup(title: "Interface Enhancements", features: [
                    "HDR visualization indicators",
                    "Pinch-to-zoom gesture control",
                    "Tap-to-focus targeting system",
                    "Recording status visualization",
                    "Contextual haptic feedback system"
                ])
                
                FeatureGroup(title: "Advanced Capabilities", features: [
                    "Manual exposure controls (ISO/shutter)",
                    "Clip management tools",
                    "Session timer display",
                    "Audio feedback integration",
                    "Smart file naming conventions"
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

