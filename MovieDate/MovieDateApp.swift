import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
