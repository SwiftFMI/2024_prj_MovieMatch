//
//  FirebaseAuth.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
}

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?
    private var authStateListener: AuthStateDidChangeListenerHandle?

    private init(user: User?) {
        self.user = user;
    }

    init() {
        authStateListener = Auth.auth().addStateDidChangeListener{ _, user in
            if let user = user {
                self.user = User(uid: user.uid, email: user.email!)
            } else {
                self.user = nil
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    static let preview = AuthService(user: User(uid: "1", email: "test@example.com"))
}
