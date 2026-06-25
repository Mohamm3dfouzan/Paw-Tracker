import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(ReminderNotificationService.self) private var notify
    @Bindable var pet: Pet
    @State private var showingAdd = false

    private var sorted: [Reminder] {
        pet.reminders.sorted { $0.fireDate < $1.fireDate }
    }

    var body: some View {
        Group {
            if sorted.isEmpty {
                EmptyStateView(symbol: "bell", title: "No reminders", message: "Get notified about vaccines, vet visits, medications, and grooming.", actionTitle: "Add Reminder") { showingAdd = true }
            } else {
                List {
                    ForEach(sorted) { r in
                        HStack {
                            Image(systemName: r.kind.symbol).foregroundStyle(r.isCompleted ? .secondary : AppTheme.accent)
                            VStack(alignment: .leading) {
                                Text(r.title).strikethrough(r.isCompleted)
                                Text(r.fireDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                r.isCompleted.toggle()
                                if r.isCompleted { notify.cancel(identifier: r.notifID) }
                                try? ctx.save()
                            } label: {
                                Image(systemName: r.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(r.isCompleted ? AppTheme.success : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { idx in
                        for i in idx {
                            notify.cancel(identifier: sorted[i].notifID)
                            ctx.delete(sorted[i])
                        }
                        try? ctx.save()
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) {
            NavigationStack { AddReminderView(pet: pet) }
        }
    }
}
