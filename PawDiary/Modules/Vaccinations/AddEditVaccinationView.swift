import SwiftUI
import SwiftData

struct AddEditVaccinationView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Environment(ReminderNotificationService.self) private var notify

    @Bindable var pet: Pet
    var vaccination: Vaccination?

    @State private var name = ""
    @State private var administeredOn: Date = .now
    @State private var hasDueDate = true
    @State private var dueOn: Date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    @State private var vet = ""
    @State private var batch = ""
    @State private var notes = ""
    @State private var scheduleReminder = true

    var body: some View {
        Form {
            Section("Vaccine") {
                if vaccination == nil {
                    Picker("Type", selection: $name) {
                        Text("Custom…").tag("")
                        ForEach(VaccineCatalog.suggestions(for: pet.species), id: \.self) { Text($0).tag($0) }
                    }
                }
                TextField("Name", text: $name)
            }
            Section("Dates") {
                DatePicker("Given on", selection: $administeredOn, displayedComponents: .date)
                Toggle("Has due date", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Due on", selection: $dueOn, displayedComponents: .date)
                    Toggle("Remind me", isOn: $scheduleReminder)
                }
            }
            Section("Details") {
                TextField("Vet name", text: $vet)
                TextField("Batch number", text: $batch)
                TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
            }
        }
        .navigationTitle(vaccination == nil ? "Add Vaccination" : "Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { Task { await save() } }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let v = vaccination else { return }
        name = v.name
        administeredOn = v.administeredOn
        if let d = v.dueOn { dueOn = d; hasDueDate = true } else { hasDueDate = false }
        vet = v.vet; batch = v.batchNumber; notes = v.notes
        scheduleReminder = false
    }

    private func save() async {
        let due = hasDueDate ? dueOn : nil
        let vax: Vaccination
        if let v = vaccination {
            v.name = name; v.administeredOn = administeredOn; v.dueOn = due
            v.vet = vet; v.batchNumber = batch; v.notes = notes
            vax = v
        } else {
            let new = Vaccination(name: name, administeredOn: administeredOn, dueOn: due, vet: vet, batchNumber: batch, notes: notes, pet: pet)
            ctx.insert(new)
            vax = new
        }
        try? ctx.save()

        if hasDueDate, scheduleReminder, let due {
            let reminderDate = Calendar.current.date(byAdding: .day, value: -7, to: due) ?? due
            if let id = await notify.schedule(
                title: "Vaccine due soon",
                body: "\(pet.name)'s \(name) is due on \(due.shortDate)",
                fireDate: reminderDate,
                kind: .vaccination
            ) {
                let r = Reminder(title: "\(vax.name) due", fireDate: reminderDate, kind: .vaccination, notifID: id, pet: pet)
                ctx.insert(r)
                try? ctx.save()
            }
        }
        dismiss()
    }
}
