import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DocumentsListView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var pet: Pet
    @State private var importing = false

    private var sorted: [MedicalDocument] {
        pet.documents.sorted { $0.addedOn > $1.addedOn }
    }

    var body: some View {
        Group {
            if sorted.isEmpty {
                EmptyStateView(symbol: "doc.text", title: "No documents", message: "Import PDFs or images of medical records, prescriptions, and lab results.", actionTitle: "Import") { importing = true }
            } else {
                List {
                    ForEach(sorted) { doc in
                        HStack {
                            Image(systemName: doc.kind.symbol).foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading) {
                                Text(doc.filename).font(.body).lineLimit(1)
                                Text("\(doc.kind.label) • \(doc.addedOn.shortDate)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { idx in
                        for i in idx { ctx.delete(sorted[i]) }
                        try? ctx.save()
                    }
                }
            }
        }
        .navigationTitle("Documents")
        .toolbar { Button { importing = true } label: { Image(systemName: "plus") } }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let granted = url.startAccessingSecurityScopedResource()
                defer { if granted { url.stopAccessingSecurityScopedResource() } }
                if let data = try? Data(contentsOf: url) {
                    let doc = MedicalDocument(
                        filename: url.lastPathComponent,
                        fileData: data,
                        kind: url.pathExtension.lowercased() == "pdf" ? .labResult : .other,
                        pet: pet
                    )
                    ctx.insert(doc)
                    try? ctx.save()
                }
            case .failure:
                break
            }
        }
    }
}
