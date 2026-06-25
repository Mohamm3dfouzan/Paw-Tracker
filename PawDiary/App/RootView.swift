import SwiftUI

struct RootView: View {
    @Environment(Bagheera.self) private var bagheera
    @State private var showGreeting = false
    @State private var greetingMessage = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            MainTabView()
                .tint(AppTheme.accent)

            if showGreeting {
                BagheeraGreetingView(message: greetingMessage) {
                    showGreeting = false
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            guard bagheera.shouldGreetOnLaunch else { return }
            greetingMessage = bagheera.greeting()
            withAnimation { showGreeting = true }
            bagheera.markGreetingShown()
        }
    }
}

#Preview {
    RootView()
        .environment(Bagheera())
        .modelContainer(PreviewSeed.container)
}
