import SwiftUI
import SwiftData
import PhotosUI

struct PhotoGalleryView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var pet: Pet
    @State private var picks: [PhotosPickerItem] = []

    private let cols = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    var body: some View {
        ScrollView {
            if pet.photos.isEmpty {
                EmptyStateView(symbol: "photo.on.rectangle", title: "No photos yet", message: "Tap the picker above to add photos of \(pet.name).")
                    .frame(minHeight: 400)
            } else {
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(pet.photos.sorted(by: { $0.takenOn > $1.takenOn })) { photo in
                        if let ui = UIImage(data: photo.imageData) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contextMenu {
                                    Button(role: .destructive) {
                                        ctx.delete(photo); try? ctx.save()
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Photos")
        .toolbar {
            PhotosPicker(selection: $picks, maxSelectionCount: 10, matching: .images) {
                Image(systemName: "plus")
            }
        }
        .task(id: picks) {
            for item in picks {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    ctx.insert(PetPhoto(imageData: data, pet: pet))
                }
            }
            if !picks.isEmpty {
                try? ctx.save()
                picks.removeAll()
            }
        }
    }
}
