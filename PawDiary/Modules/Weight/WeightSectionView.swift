import SwiftUI
import SwiftData
import Charts

struct WeightSectionView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var pet: Pet
    @State private var showingAdd = false

    private var sorted: [WeightEntry] {
        pet.weightEntries.sorted { $0.recordedOn < $1.recordedOn }
    }

    var body: some View {
        Group {
            if sorted.isEmpty {
                EmptyStateView(symbol: "scalemass", title: "No weight entries", message: "Log weight to see trends over time.", actionTitle: "Add Weight") { showingAdd = true }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        chart
                        list
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Weight")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) {
            NavigationStack { AddWeightEntryView(pet: pet) }
        }
    }

    private var chart: some View {
        VStack(alignment: .leading) {
            Text("Trend").font(.headline)
            Chart(sorted) { e in
                LineMark(x: .value("Date", e.recordedOn), y: .value("kg", e.kilograms))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppTheme.warmGradient)
                PointMark(x: .value("Date", e.recordedOn), y: .value("kg", e.kilograms))
                    .foregroundStyle(AppTheme.accent)
            }
            .frame(height: 200)
        }
        .glassCard()
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Entries").font(.headline)
            ForEach(sorted.reversed()) { e in
                HStack {
                    Text(String(format: "%.1f kg", e.kilograms)).font(.body.monospacedDigit())
                    Spacer()
                    Text(e.recordedOn.shortDate).font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .swipeActions {
                    Button(role: .destructive) {
                        ctx.delete(e); try? ctx.save()
                    } label: { Label("Delete", systemImage: "trash") }
                }
                Divider()
            }
        }
        .glassCard()
    }
}
