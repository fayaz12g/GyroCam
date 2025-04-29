//  GradientBackground.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var accentColor: Color
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            // For dark mode: subtle tint of accent color fading to black
            return [
                accentColor.opacity(0.2),
                Color.black
            ]
        } else {
            // For light mode: subtle tint of accent color fading to white
            return [
                accentColor.opacity(0.15),
                Color.white
            ]
        }
    }
}

// Keep color extension methods for potential future use
extension Color {
    func lighter(by amount: CGFloat = 0.2) -> Color {
        return self.adjust(brightnessMultiplier: 1 + amount)
    }
    
    func darker(by amount: CGFloat = 0.2) -> Color {
        return self.adjust(brightnessMultiplier: 1 - amount)
    }
    
    func adjust(brightnessMultiplier: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alpha: CGFloat = 0

        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightnessValue, alpha: &alpha) {
            let newBrightness = min(max(brightnessValue * brightnessMultiplier, 0), 1)
            return Color(hue: hue, saturation: saturation, brightness: newBrightness, opacity: Double(alpha))
        } else {
            return self
        }
    }
    
    func adjust(brightness: CGFloat, saturation: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha) {
            let newBrightness = min(max(brightness, 0), 1)
            let newSaturation = min(max(saturation, 0), 1)
            return Color(hue: hue, saturation: newSaturation, brightness: newBrightness, opacity: Double(alpha))
        } else {
            return self
        }
    }
}
