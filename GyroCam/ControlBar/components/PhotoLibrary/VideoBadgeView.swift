//
//  VideoBadgeView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/24/25.
//

import SwiftUI

struct VideoBadgeView: View {
    let type: VideoBadgeType
    let compactMode: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: compactMode ? 1 : 2) {
            Image(systemName: type.icon)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: compactMode ? 8 : 10))
            Text(type.label)
                .font(.system(size: compactMode ? 8 : 10, weight: .medium))
                .lineLimit(1)
        }
        .padding(.horizontal, compactMode ? 4 : 6)
        .padding(.vertical, compactMode ? 2 : 4)
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: compactMode ? 4 : 6))
    }
}
