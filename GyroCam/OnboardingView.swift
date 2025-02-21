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
    var setPage: Int?
    @State private var currentPage: Int
    @State private var permissionsGranted = [false, false, false, false]
    @StateObject private var permissionsManager = PermissionsManager()
    
    
    init(cameraManager: CameraManager, showOnboarding: Binding<Bool>, setPage: Int? = nil) {
            self.cameraManager = cameraManager
            self._showOnboarding = showOnboarding
            self.setPage = setPage
            // Initialize currentPage to setPage if provided, otherwise default to 0
            self._currentPage = State(initialValue: setPage ?? 0)
        }
    
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
                    description: "Adjust camera settings including lens, frame rate, and resolution. Other gesture controls include pinch to zoom, double tap to switch lens between front and back, and swipe to switch lens between wide, ultrawide and telephoto depending on device support. Showing the zoom bar and focus bars enables more options to zoom the elens and focus on the subject with manual precision, obscuring backgrounds."
                )
                .tag(3)
                
                PermissionsPage(permissionsManager: permissionsManager, cameraManager: cameraManager)
                                    .tag(4)
                if (UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && !permissionsManager.allPermissionsGranted) {
                    Text("It seems one of your permissions has been denied or revoked. Please navigate to settings to grant them.")
                    .font(.headline)}
                
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                            
                            Spacer()
                            
                            Button(action: {
                                if currentPage < 4 {
                                    currentPage += 1 // Navigate to next page
                                } else {
                                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                                    showOnboarding = false
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
            if let icon = customIcon {
                        if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                            icon
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 120, height: 120)
                                .foregroundColor(cameraManager.accentColor)
                        } else {
                            icon
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 120, height: 120)
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
                                            .frame(width: 120, height: 120)
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
                    action: permissionsManager.requestLocationPermission, cameraManager: cameraManager
                )
                
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
        locationManager.delegate = self
        checkPermissionsStatus()
    }
    
    func checkPermissionsStatus() {
        // Location
        let status = locationManager.authorizationStatus
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        // Camera
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionGranted = (cameraStatus == .authorized)
        
        // Microphone
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        microphonePermissionGranted = (microphoneStatus == .authorized)
        
        // Photo Library
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        photoLibraryPermissionGranted = (photoStatus == .authorized)
    }
    
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        switch status {
        case .denied, .restricted:
            // Open settings if permission was previously denied
            if let url = URL(string: UIApplication.openSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermissionGranted = granted
                }
            }
        default:
            break
        }
    }
    
    func requestMicrophonePermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    self.microphonePermissionGranted = granted
                }
            }
        default:
            break
        }
    }
    
    func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.photoLibraryPermissionGranted = status == .authorized
                }
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }
}

