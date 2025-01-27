//
//  OrientationHeader.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct OrientationHeader: View {
    @Binding var currentOrientation: String
    
    var body: some View {
        HStack {
            Text(currentOrientation)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())
                .padding(.top, 50)
                .transition(.opacity)  // Animation here
                .animation(.easeInOut(duration: 0.3), value: currentOrientation)
            
            Spacer()
        }
        .padding()
    }
}
