import SwiftUI

struct GyroScroll<T: BinaryFloatingPoint>: View where T.Stride: BinaryFloatingPoint {
    @Binding var value: T
    var rangeStart: T
    var rangeEnd: T
    var step: T = 1
    var label: String
    var accentColor: Color
    
    // Configure UI constants
    private let lineWidth: CGFloat = 4
    private let knobSize: CGFloat = 22
    private let height: CGFloat = 60
    private let tickHeight: CGFloat = 12
    private let majorTickSpacing: T = 10
    
    // Calculated properties
    private var range: ClosedRange<T> { rangeStart...rangeEnd }
    private var isAccentColorDark: Bool {
        return UIColor(accentColor).isDarkColor
    }
    
    // For drag gesture
    @State private var dragOffset: CGFloat = 0
    @State private var previousDragValue: CGFloat = 0
    @State private var isDragging: Bool = false
    
    // For numpad input
    @State private var isShowingNumpad: Bool = false
    @State private var tempInputValue: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Label and value display
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Value display that opens numpad when tapped
                Button(action: {
                    tempInputValue = "\(Int(value))"
                    isShowingNumpad = true
                }) {
                    Text("\(Int(value))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(accentColor.opacity(0.1))
                        )
                }
                .sheet(isPresented: $isShowingNumpad) {
                    numpadView()
                }
            }
            
            // Scroll indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: lineWidth/2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: lineWidth)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: lineWidth/2)
                        .fill(accentColor)
                        .frame(width: progressWidth(in: geometry.size.width), height: lineWidth)
                    
                    // Tick marks
                    tickMarks(in: geometry.size.width)
                    
                    // Knob
                    Circle()
                        .fill(accentColor)
                        .frame(width: knobSize, height: knobSize)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .offset(x: knobPosition(in: geometry.size.width) - knobSize/2)
                        .scaleEffect(isDragging ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: isDragging)
                }
                .frame(height: height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let newOffset = previousDragValue + gesture.translation.width
                            let ratio = newOffset / geometry.size.width
                            let newValue = T(rangeStart) + T(ratio) * (T(rangeEnd) - T(rangeStart))
                            let steppedValue = round(newValue / step) * step
                            value = min(max(steppedValue, rangeStart), rangeEnd)
                            dragOffset = newOffset
                        }
                        .onEnded { _ in
                            previousDragValue = knobPosition(in: geometry.size.width)
                            isDragging = false
                        }
                )
                .onAppear {
                    previousDragValue = knobPosition(in: geometry.size.width)
                }
            }
            .frame(height: height)
        }
        .padding(.horizontal, 20)
    }
    
    // Numpad sheet view
    private func numpadView() -> some View {
        VStack(spacing: 20) {
            // Header with value and close button
            HStack {
                Text("Enter Value")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    isShowingNumpad = false
                }
                .foregroundColor(accentColor)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Input display
            Text(tempInputValue.isEmpty ? "0" : tempInputValue)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal)
            
            // Numpad grid
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    numpadButton("1")
                    numpadButton("2")
                    numpadButton("3")
                }
                
                HStack(spacing: 15) {
                    numpadButton("4")
                    numpadButton("5")
                    numpadButton("6")
                }
                
                HStack(spacing: 15) {
                    numpadButton("7")
                    numpadButton("8")
                    numpadButton("9")
                }
                
                HStack(spacing: 15) {
                    numpadButton("Clear", action: {
                        tempInputValue = ""
                    })
                    numpadButton("0")
                    numpadButton("⌫", action: {
                        if !tempInputValue.isEmpty {
                            tempInputValue.removeLast()
                        }
                    })
                }
            }
            .padding(.horizontal)
            
            // Confirm button
            Button(action: {
                if let newValue = Double(tempInputValue),
                   newValue >= Double(rangeStart) && newValue <= Double(rangeEnd) {
                    value = T(newValue)
                }
                isShowingNumpad = false
            }) {
                Text("Confirm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(accentColor)
                    )
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.height(420)])
    }
    
    // Helper for numpad buttons
    private func numpadButton(_ label: String, action: (() -> Void)? = nil) -> some View {
        Button(action: {
            if let customAction = action {
                customAction()
            } else {
                // Prevent overly long input
                if tempInputValue.count < 5 {
                    tempInputValue += label
                }
            }
        }) {
            Text(label)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.primary)
                .frame(minWidth: 70, minHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                )
        }
    }
    
    // Calculate knob position
    private func knobPosition(in width: CGFloat) -> CGFloat {
        let ratio = (value - rangeStart) / (rangeEnd - rangeStart)
        return CGFloat(ratio) * width
    }
    
    // Calculate filled track width
    private func progressWidth(in width: CGFloat) -> CGFloat {
        return knobPosition(in: width)
    }
    
    // Generate tick marks
    private func tickMarks(in width: CGFloat) -> some View {
        ZStack {
            ForEach(0...Int(rangeEnd - rangeStart), id: \.self) { i in
                if T(i).truncatingRemainder(dividingBy: majorTickSpacing).isZero {
                    // Major tick
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 1, height: tickHeight)
                        .offset(x: CGFloat(i) / CGFloat(rangeEnd - rangeStart) * width)
                } else {
                    // Minor tick
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: tickHeight / 2)
                        .offset(x: CGFloat(i) / CGFloat(rangeEnd - rangeStart) * width)
                }
            }
        }
    }
}
