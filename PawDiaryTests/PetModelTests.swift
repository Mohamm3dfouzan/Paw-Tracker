import XCTest
import SwiftData
@testable import PawDiary

@MainActor
final class PetModelTests: XCTestCase {
    func makeContext() throws -> ModelContext {
        let schema = Schema([Pet.self, WeightEntry.self, Vaccination.self, FoodEntry.self, PetPhoto.self, MedicalDocument.self, Reminder.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return container.mainContext
    }

    func testCurrentWeightReturnsMostRecent() throws {
        let ctx = try makeContext()
        let pet = Pet(name: "Mochi")
        ctx.insert(pet)
        ctx.insert(WeightEntry(kilograms: 9.0, recordedOn: .now.addingTimeInterval(-86400), pet: pet))
        ctx.insert(WeightEntry(kilograms: 9.5, recordedOn: .now, pet: pet))
        XCTAssertEqual(pet.currentWeightKg, 9.5)
    }

    func testVaccinationIsDueWhenPastDate() {
        let v = Vaccination(name: "Rabies", administeredOn: .now.addingTimeInterval(-31_000_000), dueOn: .now.addingTimeInterval(-1000))
        XCTAssertTrue(v.isDue)
    }

    func testVaccinationNotDueWhenFuture() {
        let v = Vaccination(name: "Rabies", administeredOn: .now, dueOn: .now.addingTimeInterval(86400 * 30))
        XCTAssertFalse(v.isDue)
    }
}
