//
//  VersionEntry.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//


import SwiftUI


struct VersionEntry: View {
    let version: String
    let changes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(version)
                .font(.headline)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(changes, id: \.self) { change in
                    HStack(alignment: .top) {
                        Text("•")
                        Text(change)
                    }
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
}
