import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct FalconApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isAuthenticated = false   // ← always start false

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    DashboardView()
                } else {
                    ContentView {
                        isAuthenticated = true
                    }
                }
            }
        }
    }
}
