import Foundation
import SwiftData

@Model
final class PetPhoto {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var caption: String
    var takenOn: Date
    var pet: Pet?

    init(
        id: UUID = UUID(),
        imageData: Data,
        caption: String = "",
        takenOn: Date = .now,
        pet: Pet? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.caption = caption
        self.takenOn = takenOn
        self.pet = pet
    }
}
