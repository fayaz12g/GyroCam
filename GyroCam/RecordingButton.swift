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
    @State private var animate = false
    
    var body: some View {
        Button(action: {
            action()
            triggerHaptic()
        }) {
            ZStack {
                // Background circle
                Circle()
                    .strokeBorder(Color.white, lineWidth: 5)
                    .background(Circle().fill(isRecording ? Color.clear : Color.red))
                    .frame(width: 70, height: 70)
                    .scaleEffect(animate ? 0.9 : 1)
                
                // Stop square
                if isRecording {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Circle())
        }
        .buttonStyle(RecordingButtonStyle())
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct RecordingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
