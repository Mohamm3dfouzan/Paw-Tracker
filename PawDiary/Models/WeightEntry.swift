import Foundation
import SwiftData

@Model
final class WeightEntry {
    var id: UUID
    var kilograms: Double
    var recordedOn: Date
    var notes: String
    var pet: Pet?

    init(
        id: UUID = UUID(),
        kilograms: Double,
        recordedOn: Date = .now,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = id
        self.kilograms = kilograms
        self.recordedOn = recordedOn
        self.notes = notes
        self.pet = pet
    }
}
