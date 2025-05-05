//
//  PermissionRow.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct PermissionRow: View {
    let title: String
    let description: String
    let granted: Bool
    let action: () -> Void
    @ObservedObject var cameraManager: CameraManager
    var isFromSettings: Bool
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            if !granted {
                action()
            }
        }) {
            ZStack {
                // Background card style
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 12) {
                    // Circular Checkbox
                    ZStack {
                        Circle()
                            .stroke(granted ? LinearGradient(
                                gradient: Gradient(colors: isFromSettings ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : LinearGradient(
                                gradient: Gradient(colors: [.gray]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 2)
                            .frame(width: 30, height: 30)
                        
                        if granted {
                            Circle()
                                .fill(
                                    granted ? LinearGradient(
                                        gradient: Gradient(colors: isFromSettings ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : LinearGradient(
                                        gradient: Gradient(colors: [.clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Group {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .blendMode(.destinationOut)
                                        }
                                )
                                .compositingGroup() 
                        }
                    }
                    
                    // Permission Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}
