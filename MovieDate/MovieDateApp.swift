import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    @StateObject var userPartnerSvc = AppCompose.userPartnerSvc
    @StateObject var userSvc = AppCompose.userSvc
    @StateObject var authSvc = AppCompose.authSvc
    @StateObject var recommendSvc = AppCompose.recommendSvc

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authSvc)
                .environmentObject(userSvc)
                .environmentObject(userPartnerSvc)
                .environmentObject(recommendSvc)
        }
    }
}
