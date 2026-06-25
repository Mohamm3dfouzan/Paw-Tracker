import SwiftUI
import SwiftData

@main
struct PawDiaryApp: App {
    @State private var notificationService = ReminderNotificationService()
    @State private var bagheera = Bagheera()
    private let container: ModelContainer = SharedContainer.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(notificationService)
                .environment(bagheera)
                .task { await notificationService.requestAuthorizationIfNeeded() }
        }
        .modelContainer(container)
    }
}
