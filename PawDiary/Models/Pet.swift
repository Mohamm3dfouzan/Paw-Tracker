import Foundation
import SwiftData

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case dog, cat, bird, rabbit, reptile, fish, other
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .dog: "dog"
        case .cat: "cat"
        case .bird: "bird"
        case .rabbit: "hare"
        case .reptile: "lizard"
        case .fish: "fish"
        case .other: "pawprint"
        }
    }
}

enum PetSex: String, Codable, CaseIterable, Identifiable {
    case male, female, unknown
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

@Model
final class Pet {
    var id: UUID
    var name: String
    var speciesRaw: String
    var breed: String
    var dob: Date?
    var sexRaw: String
    var microchipID: String
    var avatarData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Vaccination.pet)
    var vaccinations: [Vaccination] = []

    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.pet)
    var foodEntries: [FoodEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \WeightEntry.pet)
    var weightEntries: [WeightEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \PetPhoto.pet)
    var photos: [PetPhoto] = []

    @Relationship(deleteRule: .cascade, inverse: \MedicalDocument.pet)
    var documents: [MedicalDocument] = []

    @Relationship(deleteRule: .cascade, inverse: \Reminder.pet)
    var reminders: [Reminder] = []

    init(
        id: UUID = UUID(),
        name: String,
        species: PetSpecies = .dog,
        breed: String = "",
        dob: Date? = nil,
        sex: PetSex = .unknown,
        microchipID: String = "",
        avatarData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.speciesRaw = species.rawValue
        self.breed = breed
        self.dob = dob
        self.sexRaw = sex.rawValue
        self.microchipID = microchipID
        self.avatarData = avatarData
        self.createdAt = .now
    }

    var species: PetSpecies {
        get { PetSpecies(rawValue: speciesRaw) ?? .other }
        set { speciesRaw = newValue.rawValue }
    }

    var sex: PetSex {
        get { PetSex(rawValue: sexRaw) ?? .unknown }
        set { sexRaw = newValue.rawValue }
    }

    var ageInYears: Int? {
        guard let dob else { return nil }
        return Calendar.current.dateComponents([.year], from: dob, to: .now).year
    }

    var currentWeightKg: Double? {
        weightEntries.sorted(by: { $0.recordedOn > $1.recordedOn }).first?.kilograms
    }
}
