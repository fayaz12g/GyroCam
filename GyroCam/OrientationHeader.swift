//
//  OrientationHeader.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct OrientationHeader: View {
    @Binding var currentOrientation: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(currentOrientation)
                .font(.title3.weight(.semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                )
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 > 20 ? 30 : 15)
            
            Spacer()
        }
        .padding(.horizontal)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: currentOrientation)
    }
}
