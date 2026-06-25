import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var pets: [Pet]
    @State private var sharedURL: URL?
    @State private var showShare = false

    private let exportService = ExportService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Library") {
                    LabeledContent("Pets", value: "\(pets.count)")
                    let totalPhotos = pets.reduce(0) { $0 + $1.photos.count }
                    LabeledContent("Photos", value: "\(totalPhotos)")
                    let totalVax = pets.reduce(0) { $0 + $1.vaccinations.count }
                    LabeledContent("Vaccinations", value: "\(totalVax)")
                }
                Section("Data") {
                    Button {
                        exportJSON()
                    } label: {
                        Label("Export library as JSON", systemImage: "square.and.arrow.up")
                    }
                }
                Section("Sync") {
                    #if ICLOUD_SYNC
                    Label("iCloud sync enabled", systemImage: "icloud.fill").foregroundStyle(.blue)
                    Text("Your library syncs across devices signed in to the same Apple ID.")
                        .font(.caption).foregroundStyle(.secondary)
                    #else
                    Label("Local only", systemImage: "iphone").foregroundStyle(.secondary)
                    Text("To enable iCloud sync, set ICLOUD_SYNC=YES in project.yml and add the iCloud capability in Xcode.")
                        .font(.caption).foregroundStyle(.secondary)
                    #endif
                }

                Section("About") {
                    LabeledContent("App", value: "PawDiary")
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showShare) {
                if let url = sharedURL { ShareSheet(items: [url]) }
            }
        }
    }

    private func exportJSON() {
        do {
            let data = try exportService.exportAll(pets)
            let url = URL.documentsDirectory.appending(path: "pawdiary-export.json")
            try data.write(to: url)
            sharedURL = url
            showShare = true
        } catch { }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
