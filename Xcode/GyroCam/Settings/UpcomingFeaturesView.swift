//
//  UpcomingFeaturesView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct UpcomingFeaturesView: View {
    @ObservedObject var cameraManager: CameraManager

    
    
    var body: some View {
        
                
                ScrollView {
                    VStack(spacing: 20) {
                        FeatureGroup(title: "GitHub Issues")
                        ManualFeatureGroup(title: "Other Features")
                    }
                    .padding()
                }
                .navigationTitle("Upcoming Features")
                .navigationBarTitleDisplayMode(.inline)
                .gradientBackground(when: cameraManager.useBlurredBackground)
                
            }
           
        }

    

