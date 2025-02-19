import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    @StateObject var userPartnerSvc = UserPartnerService.shared
    @StateObject var userSvc = UserService.shared
    @StateObject var engine = RecommendationEngine(userSvc: UserService.shared, userPartnerSvc: UserPartnerService.shared, movieSvc: MovieService())

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(userSvc)
                .environmentObject(userPartnerSvc)
                .environmentObject(engine)
        }
    }
}
