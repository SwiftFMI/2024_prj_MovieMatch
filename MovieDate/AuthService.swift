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
    let selectedGenres: [Int]

    enum CodingKeys: CodingKey {
        case uid
        case email
        case name
        case setupDone
        case selectedGenres
    }

    init(uid: String, email: String, name: String, setupDone: Bool = false, selectedGenres: [Int] = []) {
        self.uid = uid
        self.email = email
        self.name = name
        self.setupDone = setupDone
        self.selectedGenres = selectedGenres
    }
}

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?

    private var authListener: AuthStateDidChangeListenerHandle?
    private var dbListener: ListenerRegistration?
    
    static let preview = AuthService(user: User(uid: "1", email: "joe@example.com", name: "Joe"))

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
        try userDocument(res.user.uid)
            .setData(from: User(uid: res.user.uid, email: res.user.email!, name: name))
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func updateUserGenre(uid: String, genre: Int, isSelected: Bool) {
        let val = isSelected
            ? FieldValue.arrayUnion([genre])
            : FieldValue.arrayRemove([genre])
        userDocument(uid)
            .updateData([User.CodingKeys.selectedGenres.stringValue: val])
    }

    private func userDocument(_ uid: String) -> DocumentReference {
        return Firestore.firestore()
            .collection("users")
            .document(uid)
    }

    private func listenDbUser(uid: String) {
        dbListener?.remove()
        dbListener = userDocument(uid)
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
