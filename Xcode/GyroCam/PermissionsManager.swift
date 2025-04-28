//
//  PermissionsManager.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI
import CoreLocation
import AVFoundation
import Photos
import UserNotifications


class PermissionsManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locationPermissionGranted = false
    @Published var cameraPermissionGranted = false
    @Published var microphonePermissionGranted = false
    @Published var photoLibraryPermissionGranted = false
    @Published var notificationsPermissionGranted = false
    
    var allPermissionsGranted: Bool {
         cameraPermissionGranted && microphonePermissionGranted && photoLibraryPermissionGranted
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
        
        // Notifications
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                    // Open the app's settings if permission was previously denied or restricted
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                case .notDetermined:
                    // Request permission if not determined yet
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            self.notificationsPermissionGranted = granted
                        }
                    }
                case .authorized:
                    self.notificationsPermissionGranted = true
                case .provisional:
                    break
                case .ephemeral:
                    break
                @unknown default:
                    break
                }
            }
        }
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
