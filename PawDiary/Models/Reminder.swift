import Foundation
import SwiftData

enum ReminderKind: String, Codable, CaseIterable, Identifiable {
    case vaccination, vetVisit, medication, grooming, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .vaccination: "Vaccination"
        case .vetVisit: "Vet Visit"
        case .medication: "Medication"
        case .grooming: "Grooming"
        case .other: "Other"
        }
    }
    var symbol: String {
        switch self {
        case .vaccination: "syringe"
        case .vetVisit: "stethoscope"
        case .medication: "pills"
        case .grooming: "scissors"
        case .other: "bell"
        }
    }
}

@Model
final class Reminder {
    var id: UUID
    var title: String
    var fireDate: Date
    var kindRaw: String
    var notifID: String
    var isCompleted: Bool
    var notes: String
    var pet: Pet?

    init(
        id: UUID = UUID(),
        title: String,
        fireDate: Date,
        kind: ReminderKind = .other,
        notifID: String = UUID().uuidString,
        isCompleted: Bool = false,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = id
        self.title = title
        self.fireDate = fireDate
        self.kindRaw = kind.rawValue
        self.notifID = notifID
        self.isCompleted = isCompleted
        self.notes = notes
        self.pet = pet
    }

    var kind: ReminderKind {
        get { ReminderKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }
}
