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
    @State private var currentPage = 0
    @State private var permissionsGranted = [false, false, false, false]
    @StateObject private var permissionsManager = PermissionsManager()
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: Image("newlogo"),
                    iconName: "",
                    title: "Welcome to GyroCam",
                    description: "The app where your videos are recorded with the proper orientation. Always."
                )
                .tag(0)
                
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "camera",
                    title: "Live in the Moment",
                    description: "Use the camera to capture high-quality videos without thinking about device orientation."
                )
                .tag(1)
                
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "film",
                    title: "Preview Clips",
                    description: "View your video clips with our pro mode library."
                )
                .tag(2)
                
                OnboardingPage(
                    cameraManager: cameraManager,
                    customIcon: nil,
                    iconName: "slider.horizontal.3",
                    title: "Customize Settings",
                    description: "Adjust camera settings including lens, frame rate, and resolution."
                )
                .tag(3)
                
                PermissionsPage(permissionsManager: permissionsManager)
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Spacer()
            
            Button(action: {
                if currentPage == 4 && permissionsManager.allPermissionsGranted {
                   UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                   showOnboarding = false
                   cameraManager.setupFreshStart()
               }
            }) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background((currentPage == 4 && permissionsManager.allPermissionsGranted) ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(!(currentPage == 4 && permissionsManager.allPermissionsGranted))
            .padding(.bottom, 20)
        }
    }
}

struct OnboardingPage: View {
    @ObservedObject var cameraManager: CameraManager
    let customIcon: Image?
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            if let customIcon = customIcon {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    customIcon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 120, height: 120)
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    customIcon
                        .resizable()
                        .frame(width: 120, height: 120)
                
                }

            } else {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(.clear) // Clear color to let the gradient show
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image(systemName: iconName) // Apply the mask to the icon
                                    .font(.system(size: 60))
                            )
                        )

                }
                
            }
                
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct PermissionsPage: View {
    @ObservedObject var permissionsManager: PermissionsManager
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon and Header
            VStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.clear) // Clear color to let the gradient show
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image(systemName: "lock.shield.fill") // Apply the mask to the icon
                                .font(.system(size: 60))
                        )
                    )
                Text("Permissions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("One more thing. These permissions are required for the app to function properly.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
            }
            
            // Permission Rows
            VStack(spacing: 20) {
                PermissionRow(
                    title: "Location",
                    description: "We need your location to offer location-based video settings.",
                    granted: permissionsManager.locationPermissionGranted,
                    action: permissionsManager.requestLocationPermission
                )
                
                PermissionRow(
                    title: "Camera",
                    description: "This app needs access to your camera for recording videos.",
                    granted: permissionsManager.cameraPermissionGranted,
                    action: permissionsManager.requestCameraPermission
                )
                
                PermissionRow(
                    title: "Microphone",
                    description: "The microphone is required for audio recording along with the video.",
                    granted: permissionsManager.microphonePermissionGranted,
                    action: permissionsManager.requestMicrophonePermission
                )
                
                PermissionRow(
                    title: "Photo Library",
                    description: "Access to your photo library is necessary to save your videos.",
                    granted: permissionsManager.photoLibraryPermissionGranted,
                    action: permissionsManager.requestPhotoLibraryPermission
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
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
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
                                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
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


// Permissions Manager
class PermissionsManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locationPermissionGranted = false
    @Published var cameraPermissionGranted = false
    @Published var microphonePermissionGranted = false
    @Published var photoLibraryPermissionGranted = false
    
    var allPermissionsGranted: Bool {
        locationPermissionGranted && cameraPermissionGranted && microphonePermissionGranted && photoLibraryPermissionGranted
    }
    
    override init() {
        super.init()
        checkPermissionsStatus()
        locationManager.delegate = self
    }
    
    func checkPermissionsStatus() {
        // Location
        locationPermissionGranted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        
        // Camera
        cameraPermissionGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        
        // Microphone
        microphonePermissionGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        
        // Photo Library
        photoLibraryPermissionGranted = PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
            }
        }
    }
    
    func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                self.microphonePermissionGranted = granted
            }
        }
    }
    
    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.photoLibraryPermissionGranted = status == .authorized
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionGranted = status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

