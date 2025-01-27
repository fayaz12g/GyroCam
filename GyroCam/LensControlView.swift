//
//  LensControlView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/26/25.
//


import SwiftUI

struct LensControlView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(CameraManager.LensType.allCases, id: \.self) { lens in
                Button(action: { cameraManager.switchLens(lens) }) {
                    Text(lens.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(cameraManager.currentLens == lens ? .yellow : .white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.leading)
    }
}
