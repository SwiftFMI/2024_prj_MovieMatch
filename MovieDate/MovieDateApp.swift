import SwiftUI
import FirebaseCore

@main
struct MovieDateApp: App {
    @StateObject var userLikesSvc = AppCompose.userLikesSvc
    @StateObject var userPartnerSvc = AppCompose.userPartnerSvc
    @StateObject var userSvc = AppCompose.userSvc
    @StateObject var authSvc = AppCompose.authSvc

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authSvc)
                .environmentObject(userSvc)
                .environmentObject(userPartnerSvc)
                .environmentObject(userLikesSvc)
        }
    }
}
