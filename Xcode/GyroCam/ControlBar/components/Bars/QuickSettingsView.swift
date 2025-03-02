//
//  QuickSettingsView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct QuickSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Lens Picker
            Picker("Lens", selection: $cameraManager.currentLens) {
                ForEach(cameraManager.availableLenses, id: \.self) { lens in
                    if lens.rawValue == "Tele" {
                        let zoomFactor = getTelephotoZoomFactor()
                        Text("\(Int(zoomFactor))x")
                            .font(.system(size: 12))
                            .tag(lens)
                    } else {
                        Text(lens.rawValue)
                            .font(.system(size: 12))
                            .tag(lens)
                    }
                }
            }
            
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            .onChange(of: cameraManager.currentLens) { _, _ in
                cameraManager.configureSession()
            }
            
            Divider()
                .frame(height: 20)
            
            // Resolution Picker
            Picker("Res", selection: $cameraManager.currentFormat) {
                ForEach(VideoFormat.allCases, id: \.self) { format in
                    Text(format.rawValue)
                        .font(.system(size: 12))
                        .tag(format)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            .onChange(of: cameraManager.currentFormat) { _, _ in
                cameraManager.configureSession()
            }
            
            Divider()
                .frame(height: 20)
            
            // FPS Picker
            Picker("FPS", selection: $cameraManager.currentFPS) {
                ForEach(cameraManager.availableFrameRates) { fps in
                    Text(fps.description)
                        .font(.system(size: 12))
                        .tag(fps)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .fixedSize()
            .onChange(of: cameraManager.currentFPS) { _, _ in
                cameraManager.configureSession()
            }
            
            Divider()
                .frame(height: 20)

            Button {
                cameraManager.toggleFlash()
            } label: {
                Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
            }
//            .disabled(!cameraManager.hasTorch)
            .tint(.primary)
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Material.ultraThin)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        
        // Map identifier to marketing name
        switch identifier {
            // iPhone 16 Pro models
            case "iPhone17,2": return "iPhone 16 Pro Max"
            case "iPhone17,1": return "iPhone 16 Pro"
            // iPhone 15 Pro models
            case "iPhone16,2": return "iPhone 15 Pro Max"
            case "iPhone16,1": return "iPhone 15 Pro"
            // iPhone 14 Pro models
            case "iPhone15,3": return "iPhone 14 Pro Max"
            case "iPhone15,2": return "iPhone 14 Pro"
            // iPhone 13 Pro models
            case "iPhone14,3": return "iPhone 13 Pro Max"
            case "iPhone14,2": return "iPhone 13 Pro"
            // iPhone 12 Pro models
            case "iPhone13,4": return "iPhone 12 Pro Max"
            case "iPhone13,3": return "iPhone 12 Pro"
            // iPhone 11 Pro models
            case "iPhone12,5": return "iPhone 11 Pro Max"
            case "iPhone12,3": return "iPhone 11 Pro"
            // iPhone XS models
            case "iPhone11,6", "iPhone11,4": return "iPhone XS Max"
            case "iPhone11,2": return "iPhone XS"
            // iPhone X
            case "iPhone10,6", "iPhone10,3": return "iPhone X"
            // iPhone 8 Plus
            case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
            // iPhone 7 Plus
            case "iPhone9,4", "iPhone9,2": return "iPhone 7 Plus"
            default: return "Unknown iPhone"
        }
    }()
}

func getTelephotoZoomFactor() -> Double {
    let device = UIDevice.modelName
    
    switch device {
    case "iPhone 16 Pro Max", "iPhone 16 Pro", "iPhone 15 Pro Max":
        return 5.0
    case "iPhone 15 Pro", "iPhone 14 Pro Max", "iPhone 14 Pro",
         "iPhone 13 Pro Max", "iPhone 13 Pro":
        return 3.0
    case "iPhone 12 Pro Max":
        return 2.5
    case "iPhone 12 Pro", "iPhone 11 Pro Max", "iPhone 11 Pro",
         "iPhone XS Max", "iPhone XS", "iPhone X",
         "iPhone 8 Plus", "iPhone 7 Plus":
        return 2.0
    default:
        return 1.0
    }
}
