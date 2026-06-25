import Foundation
import SwiftData

enum DocumentKind: String, Codable, CaseIterable, Identifiable {
    case prescription, labResult, xRay, vaccineCert, insurance, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .prescription: "Prescription"
        case .labResult: "Lab Result"
        case .xRay: "X-Ray"
        case .vaccineCert: "Vaccine Certificate"
        case .insurance: "Insurance"
        case .other: "Other"
        }
    }
    var symbol: String {
        switch self {
        case .prescription: "pills"
        case .labResult: "testtube.2"
        case .xRay: "rays"
        case .vaccineCert: "syringe"
        case .insurance: "shield.lefthalf.filled"
        case .other: "doc"
        }
    }
}

@Model
final class MedicalDocument {
    var id: UUID
    var filename: String
    @Attribute(.externalStorage) var fileData: Data
    var kindRaw: String
    var addedOn: Date
    var notes: String
    var pet: Pet?

    init(
        id: UUID = UUID(),
        filename: String,
        fileData: Data,
        kind: DocumentKind = .other,
        addedOn: Date = .now,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = id
        self.filename = filename
        self.fileData = fileData
        self.kindRaw = kind.rawValue
        self.addedOn = addedOn
        self.notes = notes
        self.pet = pet
    }

    var kind: DocumentKind {
        get { DocumentKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }
}
