import Foundation
import SwiftData

enum SharedContainer {
    static let appGroupID = "group.com.fouzan.PawDiary"

    /// URL inside the App Group container where the SwiftData store lives.
    /// Falls back to the app's own Application Support if the App Group is
    /// unavailable (e.g. running without proper entitlements in a dev build).
    static var storeURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return url.appending(path: "PawDiary.sqlite")
        }
        let support = URL.applicationSupportDirectory
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        return support.appending(path: "PawDiary.sqlite")
    }

    /// Returns a configured `ModelContainer`. Toggles iCloud sync if the
    /// `ICLOUD_SYNC` compilation flag is set in the build settings.
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            Pet.self, Vaccination.self, FoodEntry.self, WeightEntry.self,
            PetPhoto.self, MedicalDocument.self, Reminder.self,
        ])
        #if ICLOUD_SYNC
        let config = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .automatic
        )
        #else
        let config = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        #endif

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // CloudKit can fail in builds without a paid team / valid container.
            // Fall back to a local-only store so the app still launches.
            let fallback = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
            return try! ModelContainer(for: schema, configurations: fallback)
        }
    }
}
