import Foundation
import SwiftData

enum PreviewSeed {
    @MainActor static let container: ModelContainer = {
        let schema = Schema([
            Pet.self, Vaccination.self, FoodEntry.self, WeightEntry.self,
            PetPhoto.self, MedicalDocument.self, Reminder.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        seed(container.mainContext)
        return container
    }()

    @MainActor private static func seed(_ ctx: ModelContext) {
        let pet = Pet(name: "Mochi", species: .dog, breed: "Shiba Inu", dob: Calendar.current.date(byAdding: .year, value: -3, to: .now), sex: .female)
        ctx.insert(pet)
        ctx.insert(Vaccination(name: "Rabies", administeredOn: .now.addingTimeInterval(-60*60*24*30), dueOn: .now.addingTimeInterval(60*60*24*60), vet: "Dr. Lee", pet: pet))
        ctx.insert(WeightEntry(kilograms: 9.4, recordedOn: .now.addingTimeInterval(-60*60*24*7), pet: pet))
        ctx.insert(WeightEntry(kilograms: 9.6, recordedOn: .now, pet: pet))
        ctx.insert(FoodEntry(brand: "Acana", portionGrams: 80, mealKind: .breakfast, pet: pet))
    }
}
