import SwiftUI
import SwiftData

struct HealthHubView: View {
    @Query private var pets: [Pet]

    private var upcomingVaccines: [(Pet, Vaccination)] {
        pets.flatMap { p in p.vaccinations.map { (p, $0) } }
            .filter { _, v in
                guard let due = v.dueOn else { return false }
                return due >= Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
            }
            .sorted { ($0.1.dueOn ?? .distantFuture) < ($1.1.dueOn ?? .distantFuture) }
            .prefix(20)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    EmptyStateView(symbol: "heart.text.square", title: "No pets yet", message: "Add a pet from the Pets tab to see health alerts here.")
                } else if upcomingVaccines.isEmpty {
                    EmptyStateView(symbol: "checkmark.circle", title: "All caught up", message: "No vaccinations are due in the next 30 days.")
                } else {
                    List(upcomingVaccines, id: \.1.id) { pet, vax in
                        HStack {
                            PetAvatarView(pet: pet, size: 36)
                            VStack(alignment: .leading) {
                                Text("\(pet.name) — \(vax.name)").font(.body)
                                Text("Due \(vax.dueOn.shortDateOrDash)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if vax.isDue {
                                StatusBadge(text: "Due", color: AppTheme.danger)
                            } else {
                                StatusBadge(text: "Soon", color: AppTheme.warning)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Health")
        }
    }
}
