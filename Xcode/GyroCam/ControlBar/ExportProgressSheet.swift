import SwiftUI

struct ExportProgressSheet: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cameraManager.activeExports) { export in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(export.filename)
                                .font(.headline)
                            Spacer()
                            Text(export.isCompleted ? "Complete" : "\(Int(export.progress * 100))%")
                                .foregroundColor(export.isCompleted ? .green : .primary)
                                .font(.subheadline)
                        }
                        
                        ProgressView(value: export.progress)
                            .tint(export.isCompleted ? .green : cameraManager.accentColor)
                        
                        Text("Started \(export.startTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Exports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        cameraManager.showExportSheet = false
                    }
                }
            }
        }
    }
} 