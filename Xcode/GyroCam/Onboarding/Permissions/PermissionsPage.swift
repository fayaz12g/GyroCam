//
//  PermissionsPage.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct PermissionsPage: View {
    @ObservedObject var permissionsManager: PermissionsManager
    @ObservedObject var cameraManager: CameraManager
    var message: String
    var isFromSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            
            VStack(spacing: 30) {
                Spacer()
                // Icon and Header
                VStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isFromSettings ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 60))
                            )
                        )
                    Text("Permissions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 3)
                    
                    Text(message)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                    
                }
                
                // Permission Rows
                VStack(spacing: 20) {
                    
                    PermissionRow(
                        title: "Camera",
                        description: "This app needs access to your camera for recording videos.",
                        granted: permissionsManager.cameraPermissionGranted,
                        action: permissionsManager.requestCameraPermission, cameraManager: cameraManager
                    )
                    
                    PermissionRow(
                        title: "Microphone",
                        description: "The microphone is required for audio recording along with the video.",
                        granted: permissionsManager.microphonePermissionGranted,
                        action: permissionsManager.requestMicrophonePermission, cameraManager: cameraManager
                    )
                    
                    PermissionRow(
                        title: "Photo Library",
                        description: "Access to your photo library is necessary to save your videos.",
                        granted: permissionsManager.photoLibraryPermissionGranted,
                        action: permissionsManager.requestPhotoLibraryPermission, cameraManager: cameraManager
                    )
                    
                    PermissionRow(
                        title: "Notifications",
                        description: "Allow GyroCam to send you notifications when an export completes or fails. This is optional.",
                        granted: permissionsManager.notificationsPermissionGranted,
                        action: permissionsManager.requestNotificationPermission, cameraManager: cameraManager
                    )
                    
                    PermissionRow(
                        title: "Location",
                        description: "We request your location to offer location-based video tagging. This is optional.",
                        granted: permissionsManager.locationPermissionGranted,
                        action: permissionsManager.requestLocationPermission, cameraManager: cameraManager
                    )
                    
                }
                
                Spacer()
            }
            .padding()
        
        .gradientBackground(when: (isFromSettings && cameraManager.useBlurredBackground))
    }
}
