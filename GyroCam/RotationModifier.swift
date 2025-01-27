//
//  RotationModifier.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/27/25.
//

import SwiftUI
import AVFoundation

// Add this to your project (new file or existing)
struct RotationModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(RotationModifier(action: action))
    }
}
