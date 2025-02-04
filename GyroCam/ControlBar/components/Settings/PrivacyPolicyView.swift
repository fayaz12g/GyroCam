//
//  PrivacyPolicyView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/4/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @ObservedObject var cameraManager: CameraManager

    var body: some View {
        NavigationView {
            Form {
                Section(header: header("Introduction")) {
                    Text("GyroCam (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and safeguard your information when you use our camera application, GyroCam, which records videos to your Photos app and utilizes gyroscope data to split clips, ensuring each clip is upright. All processing occurs on your device, and no personal data is collected or stored externally.")
                        .padding(.vertical, 8)
                }

                Section(header: header("Data Collection and Usage")) {
                    Text("Camera and Microphone Access: GyroCam requires access to your device's camera and microphone to record videos. These recordings are stored solely on your device and are not transmitted to any external servers.")
                        .padding(.vertical, 8)
                    Text("Gyroscope Data: The app uses gyroscope data to split video clips, ensuring each clip is upright. This data is processed entirely on your device and is not shared or stored externally.")
                        .padding(.vertical, 8)
                    Text("Location Data: GyroCam may access your device's location to embed location metadata into your videos. This information is stored within the video file and is not transmitted to any external servers.")
                        .padding(.vertical, 8)
                    Text("Photo Library Access: We never access your Photos library without your explicit consent. We only save and display recorded videos. The videos are not shared or uploaded to any external platforms. All content remains stored locally on device.")
                        .padding(.vertical, 8)
                }

                Section(header: header("Permissions")) {
                    Text("GyroCam requests the following permissions:")
                        .padding(.vertical, 8)
                    Text("Camera: To record videos.")
                        .padding(.vertical, 8)
                    Text("Microphone: To capture audio during video recording.")
                        .padding(.vertical, 8)
                    Text("Location: To embed location metadata into videos.")
                        .padding(.vertical, 8)
                    Text("Photo Library Access: To save and display recorded videos.")
                        .padding(.vertical, 8)
                    Text("These permissions are requested at runtime, and you can manage them through your device's settings at any time.")
                        .padding(.vertical, 8)
                }

                Section(header: header("Data Storage and Security")) {
                    Text("All data, including videos and associated metadata, is stored locally on your device. We do not collect, store, or transmit any personal data to external servers. Your privacy is our priority, and we ensure that all data remains on your device. GyroCam never makes any requests to external online servers or APIs.")
                        .padding(.vertical, 8)
                }

                Section(header: header("User Rights")) {
                    Text("As a user, you have the right to:")
                        .padding(.vertical, 8)
                    Text("Access: View the data stored on your device.")
                        .padding(.vertical, 8)
                    Text("Delete: Remove videos and associated metadata from your device.")
                        .padding(.vertical, 8)
                    Text("These actions can be performed directly through your device's settings.")
                        .padding(.vertical, 8)
                }

                Section(header: header("Changes to This Privacy Policy")) {
                    Text("We may update this Privacy Policy from time to time. Any changes will be reflected in this document, and the effective date will be updated accordingly. We encourage you to review this Privacy Policy periodically to stay informed about how we are protecting your information.")
                        .padding(.vertical, 8)
                }

                Section(header: header("Contact Us")) {
                    Text("If you have any questions or concerns about this Privacy Policy or our practices, please contact us at:")
                        .padding(.vertical, 8)
                    Text("1@fayaz.one")
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func header(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .textCase(nil)
            .padding(.vertical, 8)
    }
}
