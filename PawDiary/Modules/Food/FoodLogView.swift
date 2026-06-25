import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var pet: Pet
    @State private var showingAdd = false

    private var sorted: [FoodEntry] {
        pet.foodEntries.sorted { $0.loggedAt > $1.loggedAt }
    }

    var body: some View {
        Group {
            if sorted.isEmpty {
                EmptyStateView(symbol: "fork.knife", title: "No meals logged", message: "Track feeding so you know exactly what your pet's been eating.", actionTitle: "Log Meal") { showingAdd = true }
            } else {
                List {
                    ForEach(sorted) { e in
                        HStack {
                            Image(systemName: e.mealKind.symbol).foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.brand).font(.body)
                                Text("\(Int(e.portionGrams)) g • \(e.mealKind.label)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(e.loggedAt.shortDate).font(.caption2).foregroundStyle(.tertiary)
                        }
                    }
                    .onDelete { idx in
                        for i in idx { ctx.delete(sorted[i]) }
                        try? ctx.save()
                    }
                }
            }
        }
        .navigationTitle("Food")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) {
            NavigationStack { AddFoodEntryView(pet: pet) }
        }
    }
}
