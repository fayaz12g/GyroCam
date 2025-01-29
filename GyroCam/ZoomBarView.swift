//
//  ZoomBarView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct ZoomBarView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(Color.black.opacity(0.3))
                    .frame(height: 4)
                
                Capsule()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * (cameraManager.currentZoom - 1) / 
                           (cameraManager.captureDevice?.activeFormat.videoMaxZoomFactor ?? 5 - 1),
                           height: 4)
                    .animation(.linear, value: cameraManager.currentZoom)
            }
            .frame(height: 20)
            .padding(.horizontal, 40)
        }
    }
}
