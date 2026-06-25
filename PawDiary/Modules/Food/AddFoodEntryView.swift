import SwiftUI
import SwiftData

struct AddFoodEntryView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @Bindable var pet: Pet
    @State private var brand = ""
    @State private var grams: Double = 80
    @State private var meal: MealKind = .breakfast
    @State private var loggedAt: Date = .now
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Meal") {
                TextField("Brand or food name", text: $brand)
                Picker("Meal", selection: $meal) {
                    ForEach(MealKind.allCases) { Text($0.label).tag($0) }
                }
            }
            Section("Portion") {
                HStack {
                    Text("Grams")
                    Spacer()
                    TextField("0", value: $grams, format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            }
            Section("When") {
                DatePicker("Time", selection: $loggedAt)
            }
            Section("Notes") {
                TextField("Optional", text: $notes, axis: .vertical).lineLimit(2...4)
            }
        }
        .navigationTitle("Log Meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    ctx.insert(FoodEntry(brand: brand, portionGrams: grams, mealKind: meal, loggedAt: loggedAt, notes: notes, pet: pet))
                    try? ctx.save()
                    dismiss()
                }
                .disabled(brand.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
