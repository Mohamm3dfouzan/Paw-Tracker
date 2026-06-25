import SwiftUI
import SwiftData

struct VaccinationsListView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var pet: Pet
    @State private var showingAdd = false

    private var sorted: [Vaccination] {
        pet.vaccinations.sorted { ($0.dueOn ?? .distantFuture) < ($1.dueOn ?? .distantFuture) }
    }

    var body: some View {
        Group {
            if sorted.isEmpty {
                EmptyStateView(symbol: "syringe", title: "No vaccinations", message: "Log your pet's vaccines to track due dates.", actionTitle: "Add Vaccination") { showingAdd = true }
            } else {
                List {
                    ForEach(sorted) { vax in
                        NavigationLink {
                            AddEditVaccinationView(pet: pet, vaccination: vax)
                        } label: {
                            row(vax)
                        }
                    }
                    .onDelete { idx in
                        for i in idx { ctx.delete(sorted[i]) }
                        try? ctx.save()
                    }
                }
            }
        }
        .navigationTitle("Vaccinations")
        .toolbar {
            Button { showingAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack { AddEditVaccinationView(pet: pet, vaccination: nil) }
        }
    }

    @ViewBuilder private func row(_ vax: Vaccination) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(vax.name).font(.headline)
                Spacer()
                if vax.isDue {
                    StatusBadge(text: "Due", color: AppTheme.danger, symbol: "exclamationmark.circle")
                } else if let days = vax.daysUntilDue, days <= 30 {
                    StatusBadge(text: "Soon", color: AppTheme.warning, symbol: "clock")
                } else {
                    StatusBadge(text: "OK", color: AppTheme.success, symbol: "checkmark")
                }
            }
            Text("Given \(vax.administeredOn.shortDate) • Due \(vax.dueOn.shortDateOrDash)")
                .font(.caption).foregroundStyle(.secondary)
            if !vax.vet.isEmpty {
                Text("Vet: \(vax.vet)").font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
