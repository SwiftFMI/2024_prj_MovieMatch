import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    @StateObject var auth = AuthService.shared
    @StateObject var engine = RecommendationEngine(auth: AuthService.shared, movieSvc: MovieService())

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(auth)
                .environmentObject(engine)
        }
    }
}
