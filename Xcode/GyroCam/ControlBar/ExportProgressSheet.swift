import SwiftUI

struct ExportProgressSheet: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showPurgeConfirm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(cameraManager.activeExports) { export in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(export.filename)
                                    .font(.headline)
                                Text("Started \(export.startTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                if export.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if let _ = export.errorMessage {
                                    Button {
                                        cameraManager.restartExport(export)
                                    } label: {
                                        Image(systemName: "arrow.clockwise.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Image(systemName: "hourglass.circle.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .font(.title3)
                        }

                        ProgressView(value: export.progress)
                            .tint(export.isCompleted ? .green : cameraManager.accentColor)

                        if let error = export.errorMessage {
                            Text("Error: \(error)")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .padding(.top, 2)
                        }
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
