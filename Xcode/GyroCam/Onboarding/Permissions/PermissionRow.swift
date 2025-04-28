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
                                gradient: Gradient(colors: isFromSettings ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
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
                                        gradient: Gradient(colors: isFromSettings ? [cameraManager.accentColor] : [.red, .orange, .yellow, .green, .blue, .indigo]),
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
