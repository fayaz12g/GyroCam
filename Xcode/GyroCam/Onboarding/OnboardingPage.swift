//
//  OnboardingPage.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI
    
struct OnboardingPage: View {
    @ObservedObject var cameraManager: CameraManager
    let customIcon: Image?
    let iconName: String
    let title: String
    let features: [FeatureSection]
    
    
    var body: some View {
        VStack(spacing: 15) {
            if let icon = customIcon {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 110, height: 110)
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 110, height: 110)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                icon
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 150, height: 150)
                            )
                        )
                }
                
            } else {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(cameraManager.accentColor)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 60))
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image(systemName: iconName)
                                    .font(.system(size: 60))
                            )
                        )
                    
                }
            }
            
            Text(title)
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { section in
                    featureSection(section: section)
                }
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }
    
    private func featureSection(section: FeatureSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.iconName)
                    .font(.title3)
                    .foregroundColor(cameraManager.accentColor)
                    .frame(width: 30)
                
                Text(section.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 7) {
                ForEach(section.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 5)
                            .foregroundColor(cameraManager.accentColor)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 25)
        }
    }
}
