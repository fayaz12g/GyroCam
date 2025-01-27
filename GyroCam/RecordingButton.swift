//
//  RecordingButton.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct RecordingButton: View {
    @Binding var isRecording: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 70, height: 70)
                    .foregroundColor(isRecording ? .red : .white)
                    .overlay(
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundColor(.white)
                    )
                
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
