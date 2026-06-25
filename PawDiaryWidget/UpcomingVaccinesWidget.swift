import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Entry

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let items: [UpcomingItem]
}

struct UpcomingItem: Identifiable, Hashable {
    let id: UUID
    let petName: String
    let vaccineName: String
    let dueOn: Date

    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: .now, to: dueOn).day ?? 0
    }
    var isOverdue: Bool { dueOn < .now }
}

// MARK: - Provider

struct UpcomingProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingEntry {
        UpcomingEntry(date: .now, items: Self.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingEntry) -> Void) {
        completion(UpcomingEntry(date: .now, items: context.isPreview ? Self.sample : Self.loadItems()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingEntry>) -> Void) {
        let entry = UpcomingEntry(date: .now, items: Self.loadItems())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now.addingTimeInterval(3600 * 6)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private static var sample: [UpcomingItem] {
        [
            UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "Rabies", dueOn: .now.addingTimeInterval(86400 * 7)),
            UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "DHPP", dueOn: .now.addingTimeInterval(86400 * 21)),
            UpcomingItem(id: UUID(), petName: "Luna", vaccineName: "FVRCP", dueOn: .now.addingTimeInterval(86400 * 42)),
        ]
    }

    private static func loadItems() -> [UpcomingItem] {
        let schema = Schema([
            Pet.self, Vaccination.self, FoodEntry.self, WeightEntry.self,
            PetPhoto.self, MedicalDocument.self, Reminder.self,
        ])
        let config = ModelConfiguration(schema: schema, url: SharedContainer.storeURL, cloudKitDatabase: .none)
        guard let container = try? ModelContainer(for: schema, configurations: config) else {
            return []
        }
        let ctx = ModelContext(container)
        let now = Date.now
        let horizon = Calendar.current.date(byAdding: .day, value: 90, to: now) ?? now
        let predicate = #Predicate<Vaccination> { v in
            v.dueOn != nil && v.dueOn! <= horizon
        }
        var fetch = FetchDescriptor<Vaccination>(predicate: predicate, sortBy: [SortDescriptor(\.dueOn, order: .forward)])
        fetch.fetchLimit = 8
        guard let rows = try? ctx.fetch(fetch) else { return [] }
        return rows.compactMap { v in
            guard let due = v.dueOn else { return nil }
            return UpcomingItem(id: v.id, petName: v.pet?.name ?? "—", vaccineName: v.name, dueOn: due)
        }
    }
}

// MARK: - Widget

struct UpcomingVaccinesWidget: Widget {
    let kind = "UpcomingVaccinesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingProvider()) { entry in
            UpcomingVaccinesView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Upcoming Vaccines")
        .description("Next vaccinations due for your pets.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryCircular, .accessoryRectangular, .accessoryInline,
        ])
    }
}

// MARK: - View

struct UpcomingVaccinesView: View {
    @Environment(\.widgetFamily) private var family
    let entry: UpcomingEntry

    var body: some View {
        switch family {
        case .systemSmall:           small
        case .systemMedium:          medium
        case .systemLarge:           large
        case .accessoryCircular:     accessoryCircular
        case .accessoryRectangular:  accessoryRectangular
        case .accessoryInline:       accessoryInline
        default:                     medium
        }
    }

    // MARK: Home Screen

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            Spacer(minLength: 0)
            if let first = entry.items.first {
                Text(first.vaccineName).font(.subheadline).bold().lineLimit(1)
                Text(first.petName).font(.caption).foregroundStyle(.secondary)
                Text(dueLabel(first)).font(.caption2).foregroundStyle(badgeColor(first))
            } else {
                Text("Nothing due").font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(2)
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            if entry.items.isEmpty {
                Text("No upcoming vaccinations").font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(entry.items.prefix(3)) { row($0) }
            }
        }
    }

    private var large: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            if entry.items.isEmpty {
                Spacer()
                Text("No upcoming vaccinations").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(entry.items.prefix(6)) { row($0) }
            }
        }
    }

    // MARK: Lock Screen

    /// Small round complication — Bagheera silhouette with days-until.
    @ViewBuilder private var accessoryCircular: some View {
        if let first = entry.items.first {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: -1) {
                    BagheeraSilhouetteShape()
                        .fill(.primary)
                        .frame(width: 18, height: 18)
                    let d = first.daysUntil
                    Text(first.isOverdue ? "!" : (d == 0 ? "0d" : "\(d)d"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                }
                .widgetAccentable()
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    BagheeraSilhouetteShape()
                        .fill(.primary)
                        .frame(width: 18, height: 18)
                    Image(systemName: "checkmark").font(.caption2)
                }
                .widgetAccentable()
            }
        }
    }

    /// Wide lock-screen complication — Bagheera + next vaccine.
    @ViewBuilder private var accessoryRectangular: some View {
        if let first = entry.items.first {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    BagheeraSilhouetteShape()
                        .fill(.primary)
                        .frame(width: 12, height: 12)
                    Text("Bagheera says").font(.caption2.weight(.semibold))
                }
                .widgetAccentable()
                Text("\(first.petName) — \(first.vaccineName)")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Text(dueLabel(first))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading) {
                Text("Bagheera says").font(.caption2.weight(.semibold)).widgetAccentable()
                Text("All vaccines up to date.").font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Single-line complication just above the clock.
    @ViewBuilder private var accessoryInline: some View {
        if let first = entry.items.first {
            Text("🐈‍⬛ \(first.petName)'s \(first.vaccineName) — \(dueLabel(first))")
        } else {
            Text("🐈‍⬛ All vaccines up to date")
        }
    }

    // MARK: - Building blocks

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "syringe")
                .foregroundStyle(.pink)
            Text("Vaccines").font(.caption).bold().textCase(.uppercase)
            Spacer()
            Text(entry.date, style: .date).font(.caption2).foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder private func row(_ item: UpcomingItem) -> some View {
        HStack(spacing: 8) {
            Circle().fill(badgeColor(item)).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(item.petName) — \(item.vaccineName)").font(.caption).lineLimit(1)
                Text(dueLabel(item)).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func dueLabel(_ item: UpcomingItem) -> String {
        if item.isOverdue { return "Overdue" }
        let d = item.daysUntil
        if d == 0 { return "Today" }
        if d == 1 { return "Tomorrow" }
        return "In \(d) days"
    }

    private func badgeColor(_ item: UpcomingItem) -> Color {
        if item.isOverdue { return .red }
        if item.daysUntil <= 7 { return .orange }
        return .green
    }
}

// MARK: - Previews

#Preview(as: .systemMedium) {
    UpcomingVaccinesWidget()
} timeline: {
    UpcomingEntry(date: .now, items: [
        UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "Rabies", dueOn: .now.addingTimeInterval(86400 * 5)),
        UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "DHPP", dueOn: .now.addingTimeInterval(86400 * 18)),
        UpcomingItem(id: UUID(), petName: "Luna", vaccineName: "FVRCP", dueOn: .now.addingTimeInterval(86400 * 40)),
    ])
}

#Preview(as: .accessoryRectangular) {
    UpcomingVaccinesWidget()
} timeline: {
    UpcomingEntry(date: .now, items: [
        UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "Rabies", dueOn: .now.addingTimeInterval(86400 * 5)),
    ])
}

#Preview(as: .accessoryCircular) {
    UpcomingVaccinesWidget()
} timeline: {
    UpcomingEntry(date: .now, items: [
        UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "Rabies", dueOn: .now.addingTimeInterval(86400 * 3)),
    ])
}

#Preview(as: .accessoryInline) {
    UpcomingVaccinesWidget()
} timeline: {
    UpcomingEntry(date: .now, items: [
        UpcomingItem(id: UUID(), petName: "Mochi", vaccineName: "Rabies", dueOn: .now.addingTimeInterval(86400 * 5)),
    ])
}
