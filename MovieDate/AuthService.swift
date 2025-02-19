//
//  FirebaseAuth.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    private struct LoadStatus {
        var user: Bool = false
        var partners: Bool = false
    }
    @Published private var loadStatus = LoadStatus()
    var loaded: Bool { loadStatus.user && loadStatus.partners }

    @Published private(set) var user: User? = nil
    @Published private(set) var pendingPartners: [User] = []
    var mutualPartner: User? { self.pendingPartners.first(where: { self.user?.partner == $0.uid }) }

    private var authListener: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    private var partnersListener: ListenerRegistration?

    static let shared = AuthService()
    static let preview = AuthService(user: User(uid: "1", email: "joe@example.com", name: "Joe"))

    private init(user: User?) {
        self.user = user
    }

    private init() {
        authListener = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self else { return }
            if let user = user {
                userListen(uid: user.uid)
                partnersListen(uid: user.uid)
            } else {
                onUserNil()
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

    func updateUserSelect(key: User.CodingKeys, id: Int, isSelected: Bool) {
        guard let user = self.user else { return }
        let val = isSelected
            ? FieldValue.arrayUnion([id])
            : FieldValue.arrayRemove([id])
        userDocument(user.uid)
            .updateData([key.stringValue: val])
    }

    func setPersonalizeDone(value: Bool) {
        guard let user = self.user else { return }
        userDocument(user.uid)
            .updateData([User.CodingKeys.personalizeDone.stringValue: value])
    }

    func setPartner(uid: String) {
        guard let user = self.user else { return }
        userDocument(user.uid)
            .updateData([User.CodingKeys.partner.stringValue: uid])
    }

    func trySetPartner(name: String) async {
        let snapshot = try? await usersCollection().whereField(User.CodingKeys.name.stringValue, isEqualTo: name).getDocuments()
        let document = snapshot?.documents.first
        let match = try? document?.data(as: User.self)
        if let match = match {
            setPartner(uid: match.uid)
        }
    }

    func storeLike(movieId: Int) async throws {
        guard let user = self.user, let partner = self.mutualPartner else { return }
        let userLikeRef = userLikesCollection(user.uid).document(String(movieId))
        let partnerLikeRef = userLikesCollection(partner.uid).document(String(movieId))

        try userLikeRef.setData(from: UserLike(userId: user.uid, movieId: movieId))
        if try await partnerLikeRef.getDocument().exists {
            // Ensure consistent match id
            let userIds = [user.uid, partner.uid].sorted()
            let matchId = (userIds + [String(movieId)]).joined(separator: "-")
            try matchesCollection()
                .document(matchId)
                .setData(from: UserMatch(userIds: userIds, movieId: movieId))
        }
    }

    private func db() -> Firestore {
        return Firestore.firestore()
    }

    private func matchesCollection() -> CollectionReference {
        return db().collection("matches")
    }

    private func usersCollection() -> CollectionReference {
        return db().collection("users")
    }

    private func userDocument(_ uid: String) -> DocumentReference {
        return usersCollection().document(uid)
    }

    private func userLikesCollection(_ uid: String) -> CollectionReference {
        return userDocument(uid).collection("likes")
    }

    private func userListen(uid: String) {
        self.userListener?.remove()
        self.userListener = userDocument(uid)
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
            self.loadStatus.user = true
        }
    }

    private func partnersListen(uid: String) {
        self.partnersListener?.remove()
        self.partnersListener = usersCollection()
            .whereField(User.CodingKeys.partner.stringValue, isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let self else { return }
                self.pendingPartners = snapshot?.documents.compactMap({
                    try? $0.data(as: User.self)
                }) ?? []
                self.loadStatus.partners = true
        }
    }

    private func onUserNil() {
        self.user = nil
        self.pendingPartners = []

        self.userListener?.remove()
        self.userListener = nil

        self.partnersListener?.remove()
        self.partnersListener = nil

        self.loadStatus = LoadStatus(user: true, partners: true)
    }
}
