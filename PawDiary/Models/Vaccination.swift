import Foundation
import SwiftData

@Model
final class Vaccination {
    var id: UUID
    var name: String
    var administeredOn: Date
    var dueOn: Date?
    var vet: String
    var batchNumber: String
    var notes: String
    var pet: Pet?

    init(
        id: UUID = UUID(),
        name: String,
        administeredOn: Date,
        dueOn: Date? = nil,
        vet: String = "",
        batchNumber: String = "",
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = id
        self.name = name
        self.administeredOn = administeredOn
        self.dueOn = dueOn
        self.vet = vet
        self.batchNumber = batchNumber
        self.notes = notes
        self.pet = pet
    }

    var isDue: Bool {
        guard let dueOn else { return false }
        return dueOn <= .now
    }

    var daysUntilDue: Int? {
        guard let dueOn else { return nil }
        return Calendar.current.dateComponents([.day], from: .now, to: dueOn).day
    }
}

struct VaccineCatalog {
    static let commonDog = [
        "Rabies", "DHPP", "Bordetella", "Leptospirosis", "Lyme", "Canine Influenza",
    ]
    static let commonCat = [
        "Rabies", "FVRCP", "FeLV", "FIV",
    ]
    static func suggestions(for species: PetSpecies) -> [String] {
        switch species {
        case .dog: commonDog
        case .cat: commonCat
        default: ["Rabies", "Distemper", "Other"]
        }
    }
}
