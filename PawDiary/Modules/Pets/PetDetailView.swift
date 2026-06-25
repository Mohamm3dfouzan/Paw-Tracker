import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Bindable var pet: Pet
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                quickStats
                NavigationLink {
                    VaccinationsListView(pet: pet)
                } label: {
                    moduleRow(symbol: "syringe", title: "Vaccinations", count: pet.vaccinations.count)
                }
                NavigationLink {
                    WeightSectionView(pet: pet)
                } label: {
                    moduleRow(symbol: "scalemass", title: "Weight", count: pet.weightEntries.count)
                }
                NavigationLink {
                    FoodLogView(pet: pet)
                } label: {
                    moduleRow(symbol: "fork.knife", title: "Food Log", count: pet.foodEntries.count)
                }
                NavigationLink {
                    PhotoGalleryView(pet: pet)
                } label: {
                    moduleRow(symbol: "photo.on.rectangle", title: "Photos", count: pet.photos.count)
                }
                NavigationLink {
                    DocumentsListView(pet: pet)
                } label: {
                    moduleRow(symbol: "doc.text", title: "Documents", count: pet.documents.count)
                }
                NavigationLink {
                    RemindersListView(pet: pet)
                } label: {
                    moduleRow(symbol: "bell.badge", title: "Reminders", count: pet.reminders.filter { !$0.isCompleted }.count)
                }
            }
            .padding()
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { showingEdit = true }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditPetView(pet: pet)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            PetAvatarView(pet: pet, size: 80)
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name).font(.title2).bold()
                Text(pet.breed.isEmpty ? pet.species.label : "\(pet.species.label) • \(pet.breed)")
                    .foregroundStyle(.secondary)
                if let age = pet.ageInYears {
                    Text("\(age) year\(age == 1 ? "" : "s") old")
                        .font(.caption).foregroundStyle(.tertiary)
                }
            }
            Spacer()
        }
        .glassCard()
    }

    private var quickStats: some View {
        HStack(spacing: AppTheme.cardSpacing) {
            stat("Weight", value: pet.currentWeightKg.map { String(format: "%.1f kg", $0) } ?? "—", symbol: "scalemass")
            stat("Vaccines", value: "\(pet.vaccinations.count)", symbol: "syringe")
            stat("Photos", value: "\(pet.photos.count)", symbol: "photo")
        }
    }

    private func stat(_ title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(AppTheme.accent)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .glassCard(padding: 12)
    }

    private func moduleRow(symbol: String, title: String, count: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 36, height: 36)
                .foregroundStyle(.white)
                .background(AppTheme.warmGradient, in: RoundedRectangle(cornerRadius: 10))
            Text(title).font(.body)
            Spacer()
            Text("\(count)").foregroundStyle(.secondary)
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .glassCard(padding: 14)
        .foregroundStyle(.primary)
    }
}
