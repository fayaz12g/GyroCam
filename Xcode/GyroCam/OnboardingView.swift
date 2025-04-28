//
//  OnboardingView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/19/25.
//

import SwiftUI
import AVFoundation
import CoreLocation
import Photos


struct OnboardingView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var showOnboarding: Bool
    @Binding var forceOnboarding: Bool
    var setPage: Int?
    @State private var currentPage: Int
    @State private var permissionsGranted = [false, false, false, false]
    @StateObject private var permissionsManager = PermissionsManager()
    
    
    init(cameraManager: CameraManager, showOnboarding: Binding<Bool>, forceOnboarding: Binding<Bool>, setPage: Int? = nil) {
            self.cameraManager = cameraManager
            self._showOnboarding = showOnboarding
            self._forceOnboarding = forceOnboarding
            self.setPage = setPage
            self._currentPage = State(initialValue: setPage ?? 0)
        }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 0 - Welcome
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: Image("gyro_icon"),
                    iconName: "",
                    title: "Welcome to GyroCam",
                    features: [
                        FeatureSection(
                            iconName: "sparkles",
                            title: "Key Benefits",
                            items: [
                                "Automatic rotation handling",
                                "Perfect portrait/landscape videos",
                                "Professional-grade stabilization"
                            ]
                        ),
                        FeatureSection(
                            iconName: "iphone",
                            title: "Optimized For",
                            items: [
                                "iPhone & iPad",
                                "iOS 18 features",
                                "All camera systems"
                            ]
                        )
                    ]
                )
                .tag(0)

                // Page 1 - Capture
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "camera.aperture",
                    title: "Smart Capture System",
                    features: [
                        FeatureSection(
                            iconName: "gyroscope",
                            title: "Orientation Intelligence",
                            items: [
                                "Real-time gyro monitoring",
                                "Auto-restarts recording on rotation",
                                "Face up/down detection",
                                "Landscape lock override"
                            ]
                        ),
                        FeatureSection(
                            iconName: "video",
                            title: "Capture Features",
                            items: [
                                "4K UHD up to 240fps",
                                "Multi-lens switching",
                                "HDR10+ support",
                                "HEVC Dolby Vision support"
                            ]
                        )
                    ]
                )
                .tag(1)

                // Page 2 - Library
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "film.stack",
                    title: "Pro Media Library",
                    features: [
                        FeatureSection(
                            iconName: "folder",
                            title: "Organization",
                            items: [
                                "Automatic orientation-based clipping",
                                "Stitching support with lossless video",
                                "Metadata visualization"
                            ]
                        ),
                    ]
                )
                .tag(2)

                // Page 3 - Customization
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "slider.horizontal.3",
                    title: "Customize Your Experience",
                    features: [
                        FeatureSection(
                            iconName: "gear",
                            title: "Core Settings",
                            items: [
                                "Lens selection (Wide/Ultra Wide/Tele)",
                                "Resolution & frame rate profiles",
                                "HDR10+ toggle"
                            ]
                        ),
                        FeatureSection(
                            iconName: "hand.tap",
                            title: "Gesture Controls",
                            items: [
                                "Pinch to zoom",
                                "Double-tap camera swap",
                                "Swipe lens selector",
                                "Focus/zoom bar toggles"
                            ]
                        ),
                        FeatureSection(
                            iconName: "wrench.and.screwdriver",
                            title: "Pro Tools",
                            items: [
                                "Manual ISO/shutter speed",
                                "Audio monitoring",
                                "Background blur preservation"
                            ]
                        )
                    ]
                )
                .tag(3)
                
                PermissionsPage(permissionsManager: permissionsManager, cameraManager: cameraManager)
                                    .tag(4)
                
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Spacer()
            
            Button(action: {
                if currentPage < 4 {
                    currentPage += 1
                } else {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    showOnboarding = false
                    forceOnboarding = false
                    cameraManager.setupFreshStart()
                }
            }) {
                Text(currentPage < 4 ? "Next" : "Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        currentPage == 4 ?
                        (permissionsManager.allPermissionsGranted ? cameraManager.accentColor : Color.gray) :
                            cameraManager.accentColor
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(currentPage == 4 && !permissionsManager.allPermissionsGranted)
            .padding(.bottom, 20)
            .presentationBackground(cameraManager.useBlurredBackground ? Material.ultraThin : Material.ultraThick)
        }
    }
}



struct FeatureSection: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let items: [String]
}

struct OnboardingPage: View {
    @ObservedObject var cameraManager: CameraManager
    let customIcon: Image?
    let iconName: String
    let title: String
    let features: [FeatureSection]
    
    
    var body: some View {
        VStack(spacing: 15) {
            if let icon = customIcon {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 110, height: 110)
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 110, height: 110)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                icon
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 150, height: 150)
                            )
                        )
                }
                
            } else {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image(systemName: iconName)
                                    .font(.system(size: 60))
                            )
                        )
                    
                }
            }
            
            Text(title)
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { section in
                    featureSection(section: section)
                }
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }
    
    private func featureSection(section: FeatureSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.iconName)
                    .font(.title3)
                    .foregroundColor(cameraManager.accentColor)
                    .frame(width: 30)
                
                Text(section.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 7) {
                ForEach(section.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 5)
                            .foregroundColor(cameraManager.accentColor)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 25)
        }
    }
}

struct PermissionsPage: View {
    @ObservedObject var permissionsManager: PermissionsManager
    @ObservedObject var cameraManager: CameraManager
    
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
                            gradient: Gradient(colors: UserDefaults.standard.bool(forKey: "hasSeenOnboarding") ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
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
                
                if (UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && !permissionsManager.allPermissionsGranted) {
                    Text("It seems one of your permissions has been denied or revoked. Please click the button below to open settings and grant them.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                } else {
                    
                    Text("One more thing. These permissions are required for the app to function properly.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
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
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let granted: Bool
    let action: () -> Void
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        HStack {
            // Circular Checkbox
            Button(action: {
                if !granted {
                    action()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(granted ? LinearGradient(
                            gradient: Gradient(colors: UserDefaults.standard.bool(forKey: "hasSeenOnboarding") ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :  LinearGradient(
                            gradient: Gradient(colors: [.gray]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 2)
                    
                        .frame(width: 30, height: 30)
                    
                    if granted {
                        Circle()
                            .fill(
                                granted ? LinearGradient(
                                    gradient: Gradient(colors: UserDefaults.standard.bool(forKey: "hasSeenOnboarding") ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :  LinearGradient(
                                    gradient: Gradient(colors: [.clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20, height: 20)
                    }
                }

            }
            
            // Permission Details
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
