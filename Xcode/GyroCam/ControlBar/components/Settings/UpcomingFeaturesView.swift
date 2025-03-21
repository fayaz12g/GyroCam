//
//  UpcomingFeaturesView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct ManualFeatureGroup: View {
    let title: String
    @State private var isExpanded = false
    @Environment(\.colorScheme) var colorScheme
    
    let features = [
        (title: "Camera Control Support", type: FeatureType.enhancement),
        (title: "Other bug fixes", type: FeatureType.bug)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(features, id: \.title) { feature in
                        HStack(spacing: 6) {
                            Image(systemName: feature.type.icon)
                                .font(.system(size: 12))
                                .foregroundColor(feature.type.color)
                            
                            Text(feature.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding(.leading, 4)
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct UpcomingFeaturesView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            if cameraManager.useBlurredBackground {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    FeatureGroup(title: "GitHub Issues")
                    ManualFeatureGroup(title: "Other Features")
                }
                .padding()
            }
            .navigationTitle("Upcoming Features")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

