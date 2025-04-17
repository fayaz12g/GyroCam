//
//  FloatingTabBar.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/31/25.
//

import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var cameraManager: CameraManager
    let tabs: [FloatingTabItem]
    @State private var animationDirection: CGFloat = 1
    @Environment(\.colorScheme) var colorScheme
    
    private func getTabPosition(_ tab: FloatingTabItem) -> CGFloat {
        let currentIndex = tabs.firstIndex(where: { $0.tag == selectedTab }) ?? 1
        let tabIndex = tabs.firstIndex(where: { $0.id == tab.id }) ?? 1
        var offset = tabIndex - currentIndex
        
        // Ensure we maintain circular order
        if offset == 2 { offset = -1 }
        if offset == -2 { offset = 1 }
        
        return CGFloat(offset) * 70
    }
    
    var isAccentColorDark: Bool {
        return UIColor(cameraManager.accentColor).isDarkColor
    }
    
    var barColorDark: Bool {
        if colorScheme == .light {
            return isAccentColorDark
        } else {
            return isAccentColorDark
        }
    }
    
    func barBackgroundOverlay() -> Color {
        if colorScheme == .light {
            return isAccentColorDark ? Color.white.opacity(0.1) : Color.black.opacity(0.8)
        } else {
            return isAccentColorDark ? Color.white.opacity(0.8) : Color.black.opacity(0.1)
        }
    }
    
    var body: some View {
        ZStack {
            // Unified glassy belt background
            Capsule()
                .fill(.ultraThinMaterial)
                .background(
                    Capsule()
                        .fill(barBackgroundOverlay())
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5) // Subtle stroke
                )
                .frame(height: 60)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

            // Center tab bubble, merged and aligned lower
            Capsule()
                .fill(.ultraThinMaterial)
                .background(
                    Capsule()
                        .fill(barBackgroundOverlay())
                )
                .frame(width: 75, height: 75)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .offset(y: 0)

            
            // Tab items
            ForEach(tabs) { tab in
                let isCenter = selectedTab == tab.tag
                Button(action: {
                    let currentIndex = tabs.firstIndex(where: { $0.tag == selectedTab }) ?? 1
                    let newIndex = tabs.firstIndex(where: { $0.tag == tab.tag }) ?? 1
                    let direction: CGFloat = newIndex > currentIndex ? 1 : -1
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        animationDirection = direction
                        selectedTab = tab.tag
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: isCenter ? 32 : 16)) // Adjusted icon size
                            .foregroundColor(isCenter ? cameraManager.accentColor : (barColorDark ? Color.white.opacity(0.8) : Color.black.opacity(0.8)))
                            .shadow(color: colorScheme == .dark ? .white : .black, radius: 0.1, x: 0, y: 0)
                            .frame(maxWidth: .infinity, alignment: .center) // Center the icon
                        
                        Text(tab.title)
                            .font(.system(size: isCenter ? 10 : 8, weight: .bold))
                            .fontWidth(.compressed)
                            .foregroundColor(isCenter ? cameraManager.accentColor : (barColorDark ? Color.white.opacity(0.8) : Color.black.opacity(0.8)))
                            .shadow(color: colorScheme == .dark ? .white : .black, radius: 0.1, x: 0, y: 0)
                            .frame(maxWidth: .infinity, alignment: .center) // Center the text
                    }
                    .frame(width: 60)
                }
                .offset(x: getTabPosition(tab), y: isCenter ? 0 : 0)
                .zIndex(isCenter ? 1 : 0)
            }
        }
        .padding(.horizontal, 100)
        .frame(maxHeight: 75)
    }
}

struct FloatingTabItem: Identifiable {
    let id: Int
    let title: String
    let icon: String
    let tag: Int
}
