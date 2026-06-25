import Foundation
import SwiftData

enum MealKind: String, Codable, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack, treat
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        case .snack: "leaf"
        case .treat: "gift"
        }
    }
}

@Model
final class FoodEntry {
    var id: UUID
    var brand: String
    var portionGrams: Double
    var mealKindRaw: String
    var loggedAt: Date
    var notes: String
    var pet: Pet?

    init(
        id: UUID = UUID(),
        brand: String,
        portionGrams: Double,
        mealKind: MealKind = .breakfast,
        loggedAt: Date = .now,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = id
        self.brand = brand
        self.portionGrams = portionGrams
        self.mealKindRaw = mealKind.rawValue
        self.loggedAt = loggedAt
        self.notes = notes
        self.pet = pet
    }

    var mealKind: MealKind {
        get { MealKind(rawValue: mealKindRaw) ?? .snack }
        set { mealKindRaw = newValue.rawValue }
    }
}
