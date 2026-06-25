import SwiftUI
import SwiftData

struct PhotosHubView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    EmptyStateView(symbol: "photo.on.rectangle.angled", title: "Add a pet first", message: "Pets you add will show up here so you can build a photo gallery.")
                } else {
                    List(pets) { pet in
                        NavigationLink {
                            PhotoGalleryView(pet: pet)
                        } label: {
                            HStack {
                                PetAvatarView(pet: pet, size: 40)
                                VStack(alignment: .leading) {
                                    Text(pet.name).font(.headline)
                                    Text("\(pet.photos.count) photos").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Photos")
        }
    }
}
