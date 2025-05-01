//
//  WishView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 5/1/25.
//


import SwiftUI
import WishKit

struct WishView: View {
    @ObservedObject var cameraManager: CameraManager

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        WishKit.configure(with: "2B4A8146-85FB-4AE8-B964-6CD7880392F1")
        WishKit.theme.primaryColor = cameraManager.accentColor
        WishKit.config.statusBadge = .show
        WishKit.config.buttons.addButton.bottomPadding = .small
        
//        WishKit.theme.secondaryColor = .set(light: cameraManager.primaryColor, dark: cameraManager.primaryColor)
        
        // background color
        WishKit.theme.tertiaryColor = .set(light: .clear, dark: .clear)
        
        if cameraManager.userEmail != "" {
            WishKit.config.emailField = .none
        }
    }

    var body: some View {
        ScrollView {
            WishKit.FeedbackListView()
        }
        .navigationTitle("Wish List")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(when: cameraManager.useBlurredBackground, accentColor: cameraManager.primaryColor)
    }
    
}
