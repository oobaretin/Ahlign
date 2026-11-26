import SwiftUI

@main
struct AffirmAppApp: App {
    @StateObject private var subscriptions = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(subscriptions)
        }
    }
}