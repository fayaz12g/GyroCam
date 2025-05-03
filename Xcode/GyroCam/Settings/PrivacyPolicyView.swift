//
//  PrivacyPolicyView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 2/4/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var scrollOffset: CGFloat = 0
    @State private var deviceRotation: Double = 0
    
    
    var body: some View {
            
            ScrollView {
                VStack(spacing: 25) {
                    // Policy Header
                    policyHeader
                    
                    // Policy Sections
                    privacyPromiseCard
                    dataUsageCard
                    permissionsCard
                    securityCard
                    yourRightsCard
                    changesCard
                    contactCard
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(when: cameraManager.useBlurredBackground, accentColor: cameraManager.primaryColor)
    }
    
    private var policyHeader: some View {
        VStack(spacing: 15) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 40))
                .foregroundColor(cameraManager.accentColor)
                .padding()
                .background(
                    Circle()
                        .fill(cameraManager.accentColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                )
            
            Text("Your Privacy Matters")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text("Transparent • Secure • Local-Only Processing")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 30)
    }
    
    private var privacyPromiseCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "lock.shield.fill", title: "Our Privacy Promise")
                
                PrivacyBullet(
                    accentColor: cameraManager.accentColor,
                    icon: "iphone",
                    title: "100% Device Processing",
                    content: "All data stays on your device - no cloud storage or external servers"
                )
                
                PrivacyBullet(
                    accentColor: cameraManager.accentColor,
                    icon: "eye.slash",
                    title: "No Hidden Access",
                    content: "We only access what's needed for core functionality"
                )
                
                PrivacyBullet(
                    accentColor: cameraManager.accentColor,
                    icon: "arrow.triangle.2.circlepath",
                    title: "Automatic Cleanup",
                    content: "Temporary files deleted immediately after processing"
                )
            }
            .padding()
        }
    }
    
    private var dataUsageCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "chart.pie.fill", title: "Data Usage Breakdown")
                
                VStack(alignment: .leading, spacing: 10) {
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "camera.fill",
                        title: "Camera Access",
                        description: "Required for video capture",
                        accessType: "Required While Using"
                    )
                    
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "gyroscope",
                        title: "Motion Sensors",
                        description: "Orientation detection",
                        accessType: "Required While Using"
                    )
                    
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "photo.on.rectangle.angled",
                        title: "Photo Library Access",
                        description: "Used to save videos and display recorded videos",
                        accessType: "Required While Using"
                    )
                    
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "mic.fill",
                        title: "Microphone",
                        description: "Audio recording for videos",
                        accessType: "Optional"
                    )
                    
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "location.fill",
                        title: "Location",
                        description: "Embedded in video metadata",
                        accessType: "Optional"
                    )
                    
                    DataUsageRow(
                        accentColor: cameraManager.primaryColor,
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Used to alert when exports finish/fail",
                        accessType: "Optional"
                    )
                    
                }
            }
            .padding()
        }
    }
    
    private var permissionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "checkerboard.shield", title: "Permission Control")
                
                Text("You have complete control over what GyroCam can access. All permissions can be managed through:")
                    .font(.subheadline)
                
                HStack(spacing: 20) {
                    PermissionBadge(
                        accentColor: cameraManager.accentColor,
                        systemImage: "gearshape.fill",
                        label: "Settings App"
                    )
                    
                    PermissionBadge(
                        accentColor: cameraManager.accentColor,
                        systemImage: "lock.fill",
                        label: "Privacy Settings"
                    )
                    
                    PermissionBadge(
                        accentColor: cameraManager.accentColor,
                        systemImage: "app.badge.fill",
                        label: "Runtime Prompts"
                    )
                }
                .frame(maxWidth: .infinity)
                
                Text("We request minimum necessary permissions and explain each requirement when access is needed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    private var securityCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "shield.lefthalf.filled", title: "Security Measures")
                
                SecurityFeature(
                    icon: "touchid",
                    title: "Local Storage Only",
                    description: "All data remains on your device's secure storage"
                )
                
                SecurityFeature(
                    icon: "network.slash",
                    title: "No Internet Access",
                    description: "Zero network calls or external connections"
                )
                
                SecurityFeature(
                    icon: "lock.doc.fill",
                    title: "Sandboxed Access",
                    description: "Restricted to only necessary system resources"
                )
            }
            .padding()
        }
    }
    
    private var yourRightsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "checkmark.circle.fill", title: "Your Rights")
                
                RightFeature(
                    icon: "trash.fill",
                    title: "Full Deletion",
                    description: "Remove all app data instantly through Settings"
                )
                
                RightFeature(
                    icon: "eye.fill",
                    title: "Transparent Access",
                    description: "Every video taken is stored in your Photos library"
                )
                
                RightFeature(
                    icon: "xmark.circle.fill",
                    title: "Revoke Access",
                    description: "Disable permissions anytime from settings"
                )
            }
            .padding()
        }
    }
    
    private var changesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "clock.badge.exclamationmark.fill", title: "Policy Updates")
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Last Updated:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Text("March 31, 2025")
                        .bold()
                    
                    Text("We'll notify you about significant changes through:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    HStack(spacing: 15) {
                        NotificationBadge(accentColor: cameraManager.accentColor, icon: "app.badge.fill", label: "App Update")
//                        NotificationBadge(icon: "envelope.fill", label: "Email")
                        NotificationBadge(accentColor: cameraManager.accentColor, icon: "bell.badge.fill", label: "In-App Alert")
                    }
                }
            }
            .padding()
        }
    }
    
    private var contactCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                PrivacySectionHeader(accentColor: cameraManager.accentColor, icon: "person.fill.questionmark", title: "Contact Us")
                
                VStack(alignment: .leading, spacing: 10) {
                    ContactMethod(
                        accentColor: cameraManager.accentColor,
                        icon: "envelope.fill",
                        label: "Email Support:",
                        value: "1@fayaz.one"
                    )
                    
                    ContactMethod(
                        accentColor: cameraManager.accentColor,
                        icon: "clock.fill",
                        label: "Response Time:",
                        value: "Typically < 24 hours"
                    )
                    
//                    ContactMethod(
//                        icon: "lock.fill",
//                        label: "Secure Channel:",
//                        value: "PGP Encryption Available"
//                    )
                }
                
                Text("We take all privacy concerns seriously and will respond promptly to any inquiries.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - Reusable Components

struct PrivacySectionHeader: View {
    var accentColor: Color
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(accentColor)
            
            Text(title)
                .font(.title2)
                .bold()
        }
        .padding(.bottom, 10)
    }
}

struct PrivacyBullet: View {
    var accentColor: Color
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundColor(accentColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DataUsageRow: View {
    var accentColor: Color
    let icon: String
    let title: String
    let description: String
    let accessType: String
    
    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(title)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(accessType)
                .font(.caption)
                .padding(5)
                .background(Capsule().fill(accentColor.opacity(0.2)))
        }
    }
}

// MARK: - Permission Badge
struct PermissionBadge: View {
    var accentColor: Color
    let systemImage: String
    let label: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
                .frame(width: 40, height: 40)
                .background(accentColor.opacity(0.2))
                .clipShape(Circle())
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
}

// MARK: - Security Feature
struct SecurityFeature: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Right Feature
struct RightFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Contact Method
struct ContactMethod: View {
    var accentColor: Color
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .bold()
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Notification Badge
struct NotificationBadge: View {
    var accentColor: Color
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accentColor.opacity(0.2))
        .clipShape(Capsule())
    }
}
