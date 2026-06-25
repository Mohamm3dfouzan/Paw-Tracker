import SwiftUI
import SwiftData

struct PetsListView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Pet.createdAt, order: .reverse) private var pets: [Pet]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    EmptyStateView(
                        symbol: "pawprint.fill",
                        title: "No pets yet",
                        message: "Add your first pet to start tracking vaccines, food, weight, and more.",
                        actionTitle: "Add a Pet"
                    ) { showingAdd = true }
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.cardSpacing) {
                            BagheeraTipCard()
                            ForEach(pets) { pet in
                                NavigationLink(value: pet) {
                                    PetRow(pet: pet)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Pets")
            .navigationDestination(for: Pet.self) { pet in
                PetDetailView(pet: pet)
            }
            .toolbar {
                Button { showingAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditPetView(pet: nil)
            }
        }
    }
}

private struct PetRow: View {
    let pet: Pet
    var body: some View {
        HStack(spacing: 14) {
            PetAvatarView(pet: pet, size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name).font(.headline)
                Text("\(pet.species.label) • \(pet.breed.isEmpty ? "—" : pet.breed)")
                    .font(.subheadline).foregroundStyle(.secondary)
                if let kg = pet.currentWeightKg {
                    Text(String(format: "%.1f kg", kg))
                        .font(.caption).foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .glassCard()
    }
}

#Preview {
    PetsListView()
        .environment(Bagheera())
        .modelContainer(PreviewSeed.container)
}
