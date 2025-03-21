//
//  FeatureGroup.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//

import SwiftUI

struct GitHubIssueDetails: Identifiable, Decodable {
    let id: Int
    let number: Int
    let title: String
    let labels: [GitHubLabel]
    let state: String
    let html_url: String
    
    var cleanTitle: String {
        title.replacingOccurrences(of: "\\[Feature Request\\]\\s*", with: "", options: .regularExpression)
             .replacingOccurrences(of: "\\[BUG\\]\\s*", with: "", options: .regularExpression)
             .trimmingCharacters(in: .whitespaces)
    }
}

struct GitHubLabel: Decodable {
    let name: String
    let color: String
}

struct ManualFeature: Identifiable {
    let id = UUID()
    let title: String
    let type: FeatureType
}

enum FeatureType {
    case enhancement
    case bug
    
    var icon: String {
        switch self {
        case .enhancement: return "star.fill"
        case .bug: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .enhancement: return .blue
        case .bug: return .red
        }
    }
}

struct FeatureGroup: View {
    let title: String
    @State private var isExpanded = false
    @State private var issues: [GitHubIssueDetails] = []
    @State private var isLoading = true
    @State private var error: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var enhancementIssues: [GitHubIssueDetails] {
        issues.filter { issue in
            issue.state == "open" && issue.labels.contains { $0.name == "enhancement" }
        }
    }
    
    var bugIssues: [GitHubIssueDetails] {
        issues.filter { issue in
            issue.state == "open" && issue.labels.contains { $0.name == "bug" }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("\(issues.filter { $0.state == "open" }.count) open")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                if let errorMessage = error {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        if !enhancementIssues.isEmpty {
                            issueSection(title: "Planned Features", issues: enhancementIssues, iconName: "star.fill", color: .blue)
                        }
                        
                        if !bugIssues.isEmpty {
                            issueSection(title: "Known Issues", issues: bugIssues, iconName: "exclamationmark.triangle.fill", color: .red)
                        }
                    }
                    .padding(.leading, 4)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .task {
            await fetchIssues()
        }
    }
    
    private func issueSection(title: String, issues: [GitHubIssueDetails], iconName: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            ForEach(issues) { issue in
                Link(destination: URL(string: issue.html_url)!) {
                    HStack(spacing: 6) {
                        Image(systemName: iconName)
                            .font(.system(size: 12))
                            .foregroundColor(color)
                        
                        Text("#\(issue.number)")
                            .font(.subheadline)
                            .foregroundColor(color)
                        
                        Text(issue.cleanTitle)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 4)
            }
        }
    }
    
    private func fetchIssues() async {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "https://api.github.com/repos/fayaz12g/GyroCam/issues?state=open") else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedIssues = try JSONDecoder().decode([GitHubIssueDetails].self, from: data)
            await MainActor.run {
                self.issues = decodedIssues
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load issues: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

