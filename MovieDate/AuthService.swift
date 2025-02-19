//
//  AuthService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthChangeListener {
    @MainActor
    func onAuthChange(uid: String?)
}

@MainActor
class AuthService: ObservableObject {
    @Published var uid: String?
    
    init(uid: String?) {
        self.uid = uid
    }

    init(changeListeners: [AuthChangeListener]) {
        self.uid = nil
        _ = Auth.auth().addStateDidChangeListener{ _, user in
            changeListeners.forEach{ $0.onAuthChange(uid: user?.uid) }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(name: String, email: String, password: String) async throws {
        let res = try await Auth.auth().createUser(withEmail: email, password: password)
        try AppFirestore.userDocument(res.user.uid)
            .setData(from: User(uid: res.user.uid, email: res.user.email!, name: name))
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
