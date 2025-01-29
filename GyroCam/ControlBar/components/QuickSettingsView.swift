//
//  QuickSettingsView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct QuickSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Lens Picker
            Picker("Lens", selection: $cameraManager.currentLens) {
                ForEach(CameraManager.LensType.allCases, id: \.self) { lens in
                    Text(lens.rawValue)
                        .font(.system(size: 12))
                        .tag(lens)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            
            Divider()
                .frame(height: 20)
            
                .onChange(of: cameraManager.currentLens) { _ in
                    cameraManager.configureSession()
                }
            
            // Resolution Picker
            Picker("Res", selection: $cameraManager.currentFormat) {
                ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                    Text(format.rawValue)
                        .font(.system(size: 12))
                        .tag(format)
                }
                
                .onChange(of: cameraManager.currentFormat) { _ in
                    cameraManager.configureSession()
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            
            Divider()
                .frame(height: 20)
            
            // FPS Picker
            Picker("FPS", selection: $cameraManager.currentFPS) {
                ForEach(FrameRate.allCases) { fps in
                    Text(fps.description)
                        .font(.system(size: 12))
                        .tag(fps)
                }
                .onChange(of: cameraManager.currentFPS) { _ in
                    cameraManager.configureSession()
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            
            // More Settings Button
            Button {
                showSettings = true
                print("Settings opened")
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 14))
                    .padding(6)
            }
        
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Material.ultraThin)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
