//
//  UserService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserChangeListener {
    @MainActor
    func onUserChange(user: User?)
}

@MainActor
class UserService: ObservableObject {
    private let changeListeners: [UserChangeListener]

    @Published private(set) var loaded: Bool = false
    @Published private(set) var user: User? = nil

    private var authListener: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    static let shared = UserService(changeListeners: [UserPartnerService.shared])
    static let preview = UserService(user: User(uid: "1", email: "joe@e.com", name: "Joe"))

    private init(user: User?) {
        self.user = user
        self.changeListeners = []
    }

    private init(changeListeners: [UserChangeListener]) {
        self.changeListeners = changeListeners
        authListener = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self else { return }
            self.userListener?.remove()
            if let user = user {
                self.userListener = userListen(uid: user.uid)
            } else {
                self.user = nil
                self.userListener = nil
                notifyListeners(user: nil)
                loaded = true
            }
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

    func updateUserSelect(key: User.CodingKeys, id: Int, isSelected: Bool) {
        guard let user = self.user else { return }
        let val = isSelected
            ? FieldValue.arrayUnion([id])
            : FieldValue.arrayRemove([id])
        AppFirestore.userDocument(user.uid)
            .updateData([key.stringValue: val])
    }

    func setPersonalizeDone(value: Bool) {
        guard let user = self.user else { return }
        AppFirestore.userDocument(user.uid)
            .updateData([User.CodingKeys.personalizeDone.stringValue: value])
    }

    private func userListen(uid: String) -> ListenerRegistration {
         return AppFirestore.userDocument(uid)
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
            notifyListeners(user: self.user)
            loaded = true
        }
    }

    private func notifyListeners(user: User?) {
        for l in self.changeListeners {
            l.onUserChange(user: user)
        }
    }
}
