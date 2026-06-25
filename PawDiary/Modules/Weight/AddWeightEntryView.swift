import SwiftUI
import SwiftData

struct AddWeightEntryView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @Bindable var pet: Pet
    @State private var kg: Double = 5.0
    @State private var recordedOn: Date = .now
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Weight") {
                HStack {
                    Text("kg")
                    Spacer()
                    TextField("0.0", value: $kg, format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                Stepper(value: $kg, in: 0.1...200, step: 0.1) {
                    Text(String(format: "%.1f kg", kg))
                }
            }
            Section("Date") {
                DatePicker("Recorded on", selection: $recordedOn, displayedComponents: .date)
            }
            Section("Notes") {
                TextField("Optional", text: $notes, axis: .vertical).lineLimit(3...5)
            }
        }
        .navigationTitle("Add Weight")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    ctx.insert(WeightEntry(kilograms: kg, recordedOn: recordedOn, notes: notes, pet: pet))
                    try? ctx.save()
                    dismiss()
                }
            }
        }
    }
}
