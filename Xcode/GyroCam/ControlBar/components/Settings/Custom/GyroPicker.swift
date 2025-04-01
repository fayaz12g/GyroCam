//
//  GyroPicker.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/31/25.
//

import SwiftUI

struct GyroPicker<Item: Identifiable & Hashable>: View {
    @Binding var selection: Item
    var items: [Item]
    var title: String
    var accentColor: Color
    var displayValue: (Item) -> String  // Closure to get display value from Item
    
    var isAccentColorDark: Bool {
        return UIColor(accentColor).isDarkColor
    }
    
    var body: some View {
        VStack {
            // Centered title
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, 8)
            
            // Picker buttons
            HStack {
                ForEach(items) { item in
                    Button(action: {
                        withAnimation(.bouncy(duration: 0.2)) {
                            selection = item
                        }
                    }) {
                        ZStack {
                            // Background with accent color if selected
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selection == item ? accentColor : Color.gray.opacity(0.1))
                            
                            // Display the item's description using the closure
                            Text(displayValue(item))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(selection == item && isAccentColorDark ? .white : .primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal)
                        }
                        .frame(height: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 3)
        }
        .padding(.horizontal, -20)
    }
}
