//
//  AboutView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/20/25.
//

import SwiftUI

struct AboutView: View {
    @ObservedObject var cameraManager: CameraManager

    var appVersion: String {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
        
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var buildDate: String {
            return Bundle.main.infoDictionary?["BuildDate"] as? String ?? "Unknown"
        }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: header("About This App")) {
                    Text("GyroCam is created by a sole contributor, Fayaz Shaikh. It was developed over the course of a few weeks, heavily leaning into DeepSeek as a source to quickly learn the SwiftUI APIs. It began development around January 26th 2025, while the very next day I dislocated my shoulder, leading to slower development than anticipated. I just gained the ability to use a keyboard again in the past week and have been pushing constant updates, though I am also a full time undergrad student, and anticipating surgery soon. Some helpful info for you:")
                        .padding(.vertical, 8)
                    
                    Text("App Version: Beta")
                        .padding(.vertical, 2)
                    Text("Version Number: \(appVersion)")
                        .padding(.vertical, 2)
                    Text("Build Number: \(buildNumber)")
                        .padding(.vertical, 2)
                    Text("Build Date: \(buildDate)")
                        .padding(.vertical, 2)
                }


                Section(header: header("Contact Me")) {
                    Text("If you have any questions about this app or want to report a bug, contact me directly at:")
                        .padding(.vertical, 8)
                    Text("1@fayaz.one")
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func header(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .textCase(nil)
            .padding(.vertical, 8)
    }
}
