//
//  FirebaseAuth.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User? = nil
    @Published private(set) var pendingPartners: [User] = []
    @Published private(set) var mutualPartner: User? = nil

    private var authListener: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    private var partnersListener: ListenerRegistration?

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

    static let shared = AuthService()

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

    func trySetPartner(name: String) {
        Task {
            let snapshot = try? await usersCollection().whereField(User.CodingKeys.name.stringValue, isEqualTo: name).getDocuments()
            let document = snapshot?.documents.first
            let match = try? document?.data(as: User.self)
            if let match = match {
                setPartner(uid: match.uid)
            }
        }
    }


    private func usersCollection() -> CollectionReference {
        return Firestore.firestore().collection("users")
    }

    private func userDocument(_ uid: String) -> DocumentReference {
        return usersCollection().document(uid)
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
                setMutualPartner()
            } else {
                self.user = nil
            }
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
                setMutualPartner()
        }
    }

    private func setMutualPartner() {
        self.mutualPartner = self.pendingPartners.first(where: { self.user?.partner == $0.uid })
    }

    private func onUserNil() {
        self.user = nil

        self.userListener?.remove()
        self.userListener = nil

        self.partnersListener?.remove()
        self.partnersListener = nil
    }
}
