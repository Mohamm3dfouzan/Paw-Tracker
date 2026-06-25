import SwiftUI
import SwiftData

struct FoodHubView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    EmptyStateView(symbol: "fork.knife", title: "Add a pet first", message: "Pets you add will show up here so you can log their meals.")
                } else {
                    List(pets) { pet in
                        NavigationLink {
                            FoodLogView(pet: pet)
                        } label: {
                            HStack {
                                PetAvatarView(pet: pet, size: 40)
                                VStack(alignment: .leading) {
                                    Text(pet.name).font(.headline)
                                    Text("\(pet.foodEntries.count) meals logged").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food")
        }
    }
}
