//
//  UpcomingFeaturesView.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 4/28/25.
//

import SwiftUI

struct UpcomingFeaturesView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var issues: [GitHubIssueDetails] = []
    @State private var isLoading = true
    @State private var error: String? = nil
    
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
        ZStack {
            if isLoading {
                ProgressView("Loading issues...")
                    .padding()
            } else if let errorMessage = error {
                VStack {
                    Text("Error loading issues")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        Task {
                            await fetchIssues()
                        }
                    }) {
                        Text("Try Again")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if enhancementIssues.isEmpty && bugIssues.isEmpty {
                            Text("No open issues found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            if !enhancementIssues.isEmpty {
                                SectionHeader(title: "Feature Requests")
                                
                                ForEach(enhancementIssues) { issue in
                                    IssueExpandableView(issue: issue, type: .enhancement)
                                }
                            }
                            
                            if !bugIssues.isEmpty {
                                SectionHeader(title: "Bug Reports")
                                
                                ForEach(bugIssues) { issue in
                                    IssueExpandableView(issue: issue, type: .bug)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("GitHub Roadmap")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(when: cameraManager.useBlurredBackground, accentColor: cameraManager.primaryColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let url = URL(string: "https://github.com/fayaz12g/GyroCam/issues/new/choose") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("New Issue")
                    }
                }
            }
        }
        .task {
            await fetchIssues()
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

struct IssueExpandableView: View {
    let issue: GitHubIssueDetails
    let type: FeatureType
    
    @State private var isExpanded = false
    @State private var comments: [GitHubComment] = []
    @State private var isLoadingComments = false
    @State private var commentsError: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    
                    if isExpanded && comments.isEmpty {
                        Task {
                            await fetchComments()
                        }
                    }
                }
            }) {
                HStack(alignment: .center, spacing: 12) {

//                    Image(systemName: type.icon)
//                        .font(.system(size: 16))
//                        .foregroundColor(type.color)
                        
                    Text("#\(issue.number)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(type.color)
                        .frame(width: 40, alignment: .center)

                    
                    // Issue title and preview
                    VStack(alignment: .leading, spacing: 4) {
                        Text(issue.cleanTitle)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                        
                        if !isExpanded, let raw = issue.sanitizedBody, !raw.isEmpty {
                            if let md = try? AttributedString(markdown: raw) {
                                Text(md)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                          }
                    }
                    
                    
                    
                    Spacer()
                    
                    // Expand/collapse indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.top, 2)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let raw = issue.sanitizedBody, !raw.isEmpty {
                          // Render Markdown nicely
                          if let md = try? AttributedString(markdown: raw) {
                            Text(md)
                              .font(.body)
                              .fixedSize(horizontal: false, vertical: true)
                          } else {
                            Text(raw)   // fallback
                              .font(.body)
                              .fixedSize(horizontal: false, vertical: true)
                          }
                        }
                    
                    // Comments section
                    VStack(alignment: .leading, spacing: 8) {
                        if isLoadingComments {
                            HStack {
                                Spacer()
                                ProgressView("Loading comments...")
                                    .padding(.vertical, 8)
                                Spacer()
                            }
                        } else if let error = commentsError {
                            Text("Failed to load comments: \(error)")
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.vertical, 4)
                        } else {
                            if comments.isEmpty {
                                Text("No comments yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 4)
                            } else {
                                Text("Comments (\(comments.count))")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)
                                
                                ForEach(comments) { comment in
                                    CommentView(comment: comment)
                                }
                            }
                        }
                    }
                    
                    // External link to view on GitHub
                    Link(destination: URL(string: issue.html_url)!) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                            Text("View on GitHub")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                }
                .padding(.leading, 52)
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    private func fetchComments() async {
        isLoadingComments = true
        commentsError = nil
        
        guard let url = URL(string: "https://api.github.com/repos/fayaz12g/GyroCam/issues/\(issue.number)/comments") else {
            commentsError = "Invalid URL"
            isLoadingComments = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedComments = try JSONDecoder().decode([GitHubComment].self, from: data)
            await MainActor.run {
                self.comments = decodedComments
                self.isLoadingComments = false
            }
        } catch {
            await MainActor.run {
                self.commentsError = error.localizedDescription
                self.isLoadingComments = false
            }
        }
    }
}

struct CommentView: View {
    let comment: GitHubComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let avatarURL = URL(string: comment.user.avatar_url) {
                    AsyncImage(url: avatarURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                }
                
                Text(comment.user.login)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(formatDate(comment.created_at))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.body)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        
        return displayFormatter.string(from: date)
    }
}

// Models for GitHub API
struct GitHubComment: Identifiable, Decodable {
    let id: Int
    let body: String
    let user: GitHubUser
    let created_at: String
}

struct GitHubUser: Decodable {
    let login: String
    let avatar_url: String
}

// Additional FeatureType enum property
extension FeatureType {
    static func fromIssueLabels(_ labels: [GitHubLabel]) -> FeatureType {
        if labels.contains(where: { $0.name == "bug" }) {
            return .bug
        } else {
            return .enhancement
        }
    }
}
