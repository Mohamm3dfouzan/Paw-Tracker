import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Environment(ReminderNotificationService.self) private var notify

    @Bindable var pet: Pet
    @State private var title = ""
    @State private var fireDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    @State private var kind: ReminderKind = .vetVisit
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Reminder") {
                TextField("Title", text: $title)
                Picker("Kind", selection: $kind) {
                    ForEach(ReminderKind.allCases) { Text($0.label).tag($0) }
                }
            }
            Section("When") {
                DatePicker("Date", selection: $fireDate, in: Date.now...)
            }
            Section("Notes") {
                TextField("Optional", text: $notes, axis: .vertical).lineLimit(2...5)
            }
        }
        .navigationTitle("Add Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { Task { await save() } }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() async {
        let id = await notify.schedule(title: title, body: "Reminder for \(pet.name)", fireDate: fireDate, kind: kind) ?? UUID().uuidString
        let r = Reminder(title: title, fireDate: fireDate, kind: kind, notifID: id, notes: notes, pet: pet)
        ctx.insert(r)
        try? ctx.save()
        dismiss()
    }
}
