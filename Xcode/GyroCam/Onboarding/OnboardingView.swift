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
    @ObservedObject var permissionsManager: PermissionsManager
    @Binding var showOnboarding: Bool
    @Binding var forceOnboarding: Bool
    var setPage: Int?
    @State private var currentPage: Int
    @State private var permissionsGranted = [false, false, false, false]
    var message = ""
    
    init(
            cameraManager: CameraManager,
            permissionsManager: PermissionsManager,
            showOnboarding: Binding<Bool>,
            forceOnboarding: Binding<Bool>,
            setPage: Int? = nil
        ) {
            self.cameraManager = cameraManager
            self.permissionsManager = permissionsManager
            self._showOnboarding = showOnboarding
            self._forceOnboarding = forceOnboarding
            self.setPage = setPage
            self._currentPage = State(initialValue: setPage ?? 0)
            
            if (UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && !permissionsManager.allPermissionsGranted) {
                self.message = "It seems one of your permissions has been denied or revoked. Please click the button below to open settings and grant them."
            }
            else {
                self.message = "One more thing. These permissions are required for the app to function properly."
            }
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
                
                
                PermissionsPage(permissionsManager: permissionsManager, cameraManager: cameraManager, message: message)
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
