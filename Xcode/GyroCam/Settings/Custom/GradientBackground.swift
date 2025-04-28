//
//  GradientBackground.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.1)
            ]
        } else {
            return [
                Color(red: 0.9, green: 0.95, blue: 1.0),
                Color(red: 0.8, green: 0.9, blue: 1.0)
            ]
        }
    }
}
