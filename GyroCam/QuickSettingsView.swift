//
//  QuickSettingsView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct QuickSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Lens", selection: $cameraManager.currentLens) {
                ForEach(CameraManager.LensType.allCases, id: \.self) { lens in
                    Text(lens.rawValue).tag(lens)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Picker("Resolution", selection: $cameraManager.currentFormat) {
                ForEach(CameraManager.VideoFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Picker("FPS", selection: $cameraManager.currentFPS) {
                ForEach(FrameRate.allCases) { fps in
                    Text(fps.description).tag(fps)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .frame(width: 300)
    }
}
