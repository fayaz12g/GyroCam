//
//  GyroToggle.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/31/25.
//


//
//  GyroToggle.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/31/25.
//

import SwiftUI

struct GyroToggle: View {
    @Binding var isOn: Bool
    var label: String
    var accentColor: Color
    
    var isAccentColorDark: Bool {
        return UIColor(accentColor).isDarkColor
    }
    
    // Animation states
    @State private var fillPercentage: CGFloat = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isOn.toggle()
                
                // Animate fill percentage based on toggle state
                fillPercentage = isOn ? 1.0 : 0.0
            }
        }) {
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.1))
                
                // Fluid fill effect
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * fillPercentage)
                        .animation(.easeInOut(duration: 0.5), value: fillPercentage)
                }
                
                // Status indicator in top right
                Circle()
                    .fill(isOn ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                    .position(x: 16, y: 16)
                
                // Centered text
                Text(label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isOn && fillPercentage > 0.5 ? isAccentColorDark ? .white : .black : .primary)
                    .animation(.easeInOut(duration: 0.3), value: isOn)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal)
            }
            .frame(height: 50)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isOn) { _, newValue in
            // Initialize fill percentage when view loads based on isOn
            if newValue {
                fillPercentage = 1.0
            } else {
                fillPercentage = 0.0
            }
        }
        .padding(.horizontal, -20)
        .onAppear {
            // Initialize fill percentage when view loads based on isOn
            fillPercentage = isOn ? 1.0 : 0.0
        }
    }
}
