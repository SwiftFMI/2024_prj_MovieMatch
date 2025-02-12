import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    @StateObject var auth = AuthService()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
        .environmentObject(auth)
    }
}
