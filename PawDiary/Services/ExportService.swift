import Foundation

struct ExportService {
    struct ExportedPet: Codable {
        let name: String
        let species: String
        let breed: String
        let dob: Date?
        let weightHistory: [WeightPoint]
        let vaccinations: [VaccineRecord]
        struct WeightPoint: Codable { let date: Date; let kg: Double }
        struct VaccineRecord: Codable { let name: String; let administered: Date; let due: Date? }
    }

    func exportAll(_ pets: [Pet]) throws -> Data {
        let payload = pets.map { p in
            ExportedPet(
                name: p.name,
                species: p.species.rawValue,
                breed: p.breed,
                dob: p.dob,
                weightHistory: p.weightEntries.map { .init(date: $0.recordedOn, kg: $0.kilograms) },
                vaccinations: p.vaccinations.map { .init(name: $0.name, administered: $0.administeredOn, due: $0.dueOn) }
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }
}
