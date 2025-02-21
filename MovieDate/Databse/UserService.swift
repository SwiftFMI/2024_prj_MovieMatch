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
class UserService: ObservableObject, AuthChangeListener {
    private let changeListeners: [UserChangeListener]

    @Published private(set) var loaded: Bool = false
    @Published private(set) var user: User? = nil

    private var authListener: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    init(user: User?) {
        self.user = user
        self.changeListeners = []
    }

    init(changeListeners: [UserChangeListener]) {
        self.changeListeners = changeListeners
    }

    func onAuthChange(uid: String?) {
        self.userListener?.remove()
        if let uid {
            if self.user == nil {
                self.loaded = false
            }
            self.userListener = userListen(uid: uid)
        } else {
            self.user = nil
            self.userListener = nil
            self.notifyListeners()
            self.loaded = true
        }
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
            guard error == nil else { return }
            guard let self else { return }
            
            if let snapshot, snapshot.exists, let user = try? snapshot.data(as: User.self) {
                self.user = user
            } else {
                self.user = nil
            }
            notifyListeners()
            loaded = true
        }
    }
    
    func notifyListeners() {
        changeListeners.forEach{ $0.onUserChange(user: user) }
    }
}
