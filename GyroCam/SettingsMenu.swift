//
//  SettingsMenu.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct SettingsMenu: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Menu {
            Picker("Video Format", selection: $cameraManager.currentFormat) {
                ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .onChange(of: cameraManager.currentFormat) { _ in
                cameraManager.configureSession()
            }
            
            Divider()
            
            Picker("Camera Lens", selection: $cameraManager.currentLens) {
                ForEach(CameraManager.LensType.allCases, id: \.self) { lens in
                    Text(lens.rawValue).tag(lens)
                }
            }
            .onChange(of: cameraManager.currentLens) { _ in
                cameraManager.configureSession()
            }
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = .systemBlue
        }
    }
}
