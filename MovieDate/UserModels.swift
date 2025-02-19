//
//  UserModels.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

struct User: Codable, Identifiable {
    var id: String { uid }
    let uid: String
    let email: String
    let name: String
    let personalizeDone: Bool
    let selectedGenres: [Int]
    let selectedProviders: [Int]
    let selectedActors: [Int]
    let partner: String?

    enum CodingKeys: CodingKey {
        case uid
        case email
        case name
        case personalizeDone
        case selectedGenres
        case selectedProviders
        case selectedActors
        case partner
    }

    init(uid: String, email: String, name: String,
         setupDone: Bool = false,
         selectedGenres: [Int] = [],
         selectedProviders: [Int] = [],
         selectedActors: [Int] = [],
         partner: String? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        self.personalizeDone = setupDone
        self.selectedGenres = selectedGenres
        self.selectedProviders = selectedProviders
        self.selectedActors = selectedActors
        self.partner = partner
    }
}

struct UserLike: Codable {
    let userId: String
    let movieId: Int
    
    enum CodingKeys: CodingKey {
        case userId
        case movieId
    }
}

struct UserMatch: Codable {
    let userIds: [String]
    let movieId: Int
    
    enum CodingKeys: CodingKey {
        case userIds
        case movieId
    }
}
