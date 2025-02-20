//
//  VersionEntry.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//


import SwiftUI

struct VersionEntry: View {
    @ObservedObject var cameraManager: CameraManager
    let version: String
    let changes: [ChangeEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(version)
                .font(.headline)
                .foregroundColor(cameraManager.accentColor)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(changes, id: \.self) { change in
                    VStack(alignment: .leading, spacing: 4) {
                        if let title = change.title {
                            Text(title)
                                .fontWeight(.bold)
                        }
                        
                        ForEach(change.details, id: \.self) { detail in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(detail)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
}

struct ChangeEntry: Hashable {
    let title: String?
    let details: [String]
}
