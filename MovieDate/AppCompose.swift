//
//  AppCompose.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

@MainActor
struct AppCompose {
    static let movieSvc = MovieService()
    static let userLikesSvc = UserLikesService()
    static let userPartnerSvc = UserPartnerService(changeListeners: [userLikesSvc])
    static let userSvc = UserService(changeListeners: [userPartnerSvc, userLikesSvc])
    static let authSvc = AuthService(changeListeners: [userSvc])
    static let recommendSvc = RecommendationEngine(userSvc: userSvc, userLikesSvc: userLikesSvc, movieSvc: movieSvc)
}

@MainActor
struct PreviewCompose {
    private static let u1 = User(uid: "1", email: "joe@e.com", name: "Joe", partner: "2")
    private static let u2 = User(uid: "2", email: "max@e.com", name: "Max", partner: "1")

    static let userLikesSvc = UserLikesService(userLikes: [], partnerLikes: [], userMatches: [])
    static let userPartnerSvc = UserPartnerService(user: u1, partner: u2)
    static let userSvc = UserService(user: u1)
    static let authSvc = AuthService(uid: u1.uid)
    static let recommendSvc = RecommendationEngine(userSvc: userSvc, userLikesSvc: userLikesSvc, movieSvc: AppCompose.movieSvc)
}
