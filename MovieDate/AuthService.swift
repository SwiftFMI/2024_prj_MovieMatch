//
//  FirebaseAuth.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct User: Codable {
    let uid: String
    let email: String
    let name: String
    let setupDone: Bool
}

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?

    private var authListener: AuthStateDidChangeListenerHandle?
    private var dbListener: ListenerRegistration?
    
    static let preview = AuthService(user: nil)

    private init(user: User?) {
        self.user = user
    }

    init() {
        authListener = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self else { return }
            if let user = user {
                listenDbUser(uid: user.uid)
            } else {
                unlistenDbUser()
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(name: String, email: String, password: String) async throws {
        let res = try await Auth.auth().createUser(withEmail: email, password: password)
        try Firestore.firestore()
            .collection("users")
            .document(res.user.uid)
            .setData(from: User(uid: res.user.uid, email: res.user.email!, name: name, setupDone: false))
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func listenDbUser(uid: String) {
        dbListener?.remove()
        dbListener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let snapshot = snapshot, snapshot.exists, let data = try? snapshot.data(as: User.self) {
                self.user = data
            } else {
                self.user = nil
            }
        }
    }
    
    private func unlistenDbUser() {
        self.user = nil
        self.dbListener?.remove()
        self.dbListener = nil
    }
}
