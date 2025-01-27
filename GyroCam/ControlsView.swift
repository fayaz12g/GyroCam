//
//  ControlsView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct ControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        HStack {
            LensControlView(cameraManager: cameraManager)
            
            Spacer()
            
            RecordingButton(isRecording: $cameraManager.isRecording) {
                cameraManager.isRecording ? cameraManager.stopRecording() : cameraManager.startRecording()
            }
            
            Spacer()
            
            SettingsMenu(cameraManager: cameraManager)
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }
}
