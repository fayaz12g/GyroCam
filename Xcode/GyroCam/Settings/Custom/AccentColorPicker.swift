//
//  AccentColorPicker.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 3/31/25.
//


import SwiftUI

struct AccentColorPicker: View {
    @Binding var accentColor: Color
    @Binding var primaryColor: Color
    @State private var isShowingAccentColorPicker = false
    @State private var isShowingPrimaryColorPicker = false
    @State private var fillPercentage: CGFloat = 1.0
    
    var isAccentColorDark: Bool {
        return UIColor(accentColor).isDarkColor
    }
    
    var isPrimaryColorDark: Bool {
        return UIColor(primaryColor).isDarkColor
    }
    
    var body: some View {
        
        // Primary Color Changer
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isShowingPrimaryColorPicker.toggle()
            }
        }) {
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.1))
                
                // Fluid fill effect
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(primaryColor)
                        .frame(width: geometry.size.width * fillPercentage)
                        .animation(.easeInOut(duration: 0.5), value: fillPercentage)
                }
                
                // Status indicator in top right
                Circle()
                    .fill(primaryColor)
                    .frame(width: 12, height: 12)
                    .position(x: 16, y: 16)
                
                // Centered text with color preview
                HStack {
                    Text("Customize Primary Color")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isPrimaryColorDark ? .white : .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isShowingPrimaryColorPicker) {
            ColorPickerSheet(selectedColor: $primaryColor, isPresented: $isShowingPrimaryColorPicker)
        }
        .padding(.horizontal, -20)
        
        
        // Accent Color changer
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isShowingAccentColorPicker.toggle()
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
                    .fill(accentColor)
                    .frame(width: 12, height: 12)
                    .position(x: 16, y: 16)
                
                // Centered text with color preview
                HStack {
                    Text("Customize Accent Color")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isAccentColorDark ? .white : .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isShowingAccentColorPicker) {
            ColorPickerSheet(selectedColor: $accentColor, isPresented: $isShowingAccentColorPicker)
        }
        .padding(.horizontal, -20)
    }
}


struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Binding var isPresented: Bool
    @State private var tempColor: Color
    
    let presetColors: [Color] = [
        .blue,
        .red,
        .green,
        .orange,
        .purple,
        .pink,
        .yellow,
        Color(red: 1.0, green: 0.204, blue: 0.169), // Apple camera red
        Color(red: 0.5, green: 0.5, blue: 0.5),     // Gray
        Color(red: 0.0, green: 0.8, blue: 0.8),     // Aqua
        Color(red: 0.93, green: 0.33, blue: 0.6),   // Magenta
        Color(red: 0.1, green: 0.9, blue: 0.1),     // neon green
    ]

    
    init(selectedColor: Binding<Color>, isPresented: Binding<Bool>) {
        self._selectedColor = selectedColor
        self._isPresented = isPresented
        self._tempColor = State(initialValue: selectedColor.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Color preview
                RoundedRectangle(cornerRadius: 20)
                    .fill(tempColor)
                    .frame(height: 100)
                    .padding()
                
                // Preset colors
                VStack(alignment: .leading) {
                    Text("Preset Colors")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(0..<presetColors.count, id: \.self) { index in
                            Button(action: {
                                tempColor = presetColors[index]
                            }) {
                                Circle()
                                    .fill(presetColors[index])
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .opacity(tempColor == presetColors[index] ? 1 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Standard color picker
                ColorPicker("Custom Color", selection: $tempColor, supportsOpacity: false)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select a Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedColor = tempColor
                        isPresented = false
                    }
                }
            }
        }
    }
}
