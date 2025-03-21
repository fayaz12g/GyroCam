//
//  VersionEntry.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/29/25.
//


import SwiftUI

struct GitHubIssue: Identifiable {
    let id: Int
    var title: String = "Loading..." // Default title while loading
}

struct VersionEntry: View {
    let version: String
    let date: String
    let type: UpdateType
    let changes: [ChangeItem]
    var fixedIssues: [Int]? = nil
    
    @State private var isExpanded = false
    @State private var issues: [GitHubIssue] = []
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Version number with color
                    Text(version)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(type.color)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(date)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(changes) { change in
                        HStack(alignment: .top, spacing: 8) {
                            change.type.icon
                                .foregroundColor(change.type.color)
                                .font(.system(size: 14))
                                .frame(width: 20)
                            
                            Text(change.description)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if let issues = fixedIssues, !issues.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("GitHub Issues Addressed:")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        ForEach(self.issues) { issue in
                            Link(destination: URL(string: "https://github.com/fayaz12g/GyroCam/issues/\(issue.id)")!) {
                                HStack(spacing: 6) {
                                    Image(systemName: "number")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                    
                                    Text("\(issue.id)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    Text(issue.title)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.leading, 4)
                        }
                    }
                }
                .padding(.leading, 4)
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .onChange(of: isExpanded) { expanded in
            if expanded, let issueNumbers = fixedIssues {
                // Initialize issues array with loading state
                issues = issueNumbers.map { GitHubIssue(id: $0) }
                
                // Fetch issue titles
                for issueNumber in issueNumbers {
                    Task {
                        if let url = URL(string: "https://api.github.com/repos/fayaz12g/GyroCam/issues/\(issueNumber)") {
                            do {
                                let (data, _) = try await URLSession.shared.data(from: url)
                                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let title = json["title"] as? String {
                                    DispatchQueue.main.async {
                                        if let index = issues.firstIndex(where: { $0.id == issueNumber }) {
                                            issues[index].title = title
                                        }
                                    }
                                }
                            } catch {
                                print("Error fetching issue #\(issueNumber): \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}

enum UpdateType {
    case release(version: Int)  // 1.0.0 = Release 1
    case beta(version: Int)     // 0.1.3 = Beta 3
    case alpha(version: Int)    // 0.0.5 = Alpha 5
    case `internal`(version: Int) // 0.0.4 = Internal Build 4
    
    var badge: some View {
        Text(title)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    var title: String {
        switch self {
        case .release(let version): return "Release \(version)"
        case .beta(let version): return "Beta \(version)"
        case .alpha(let version): return "Alpha \(version)"
        case .internal(let version): return "Build \(version)"
        }
    }
    
    var color: Color {
        switch self {
        case .release: return .blue
        case .beta: return .red
        case .alpha: return .yellow
        case .internal: return .green
        }
    }
    
    static func fromVersion(_ version: String) -> UpdateType {
        let components = version.split(separator: ".")
        guard components.count == 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2]) else {
            return .internal(version: 0)
        }
        
        if major > 0 {
            return .release(version: major)
        } else if minor > 0 {
            return .beta(version: patch)
        } else {
            return patch >= 5 ? .alpha(version: patch) : .internal(version: patch)
        }
    }
}

struct ChangeItem: Identifiable {
    let id = UUID()
    let type: ChangeType
    let description: String
}

enum ChangeType {
    case added
    case improved
    case fixed
    case changed
    
    var icon: Image {
        switch self {
        case .added: return Image(systemName: "plus.circle.fill")
        case .improved: return Image(systemName: "arrow.up.circle.fill")
        case .fixed: return Image(systemName: "wrench.fill")
        case .changed: return Image(systemName: "arrow.triangle.2.circlepath")
        }
    }
    
    var color: Color {
        switch self {
        case .added: return .green
        case .improved: return .blue
        case .fixed: return .orange
        case .changed: return .purple
        }
    }
}

struct ChangeEntry: Hashable {
    let title: String?
    let details: [String]
}
