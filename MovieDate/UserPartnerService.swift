//
//  UserPartnerService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

import Foundation
import FirebaseFirestore

@MainActor
class UserPartnerService: ObservableObject, UserChangeListener {
    private var listener: ListenerRegistration? = nil

    @Published private(set) var loaded: Bool = false
    @Published private(set) var user: User? = nil
    @Published private(set) var pendingPartners: [User] = []
    var mutualPartner: User? { self.pendingPartners.first(where: { user?.partner == $0.uid }) }

    static let shared: UserPartnerService = UserPartnerService()
    static let preview: UserPartnerService = UserPartnerService(
        user: User(uid: "1", email: "joe@e.com", name: "Joe", partner: "2"),
        partner: User(uid: "2", email: "max@e.com", name: "Max", partner: "1"))

    private init() {
    }

    private init(user: User, partner: User) {
        self.user = user
        self.pendingPartners = [partner]
    }

    func onUserChange(user: User?) {
        self.user = user
        self.listener?.remove()
        if let user = user {
            self.listener = partnersListen(uid: user.uid)
        } else {
            self.listener = nil
            self.pendingPartners = []
            self.loaded = true
        }
    }

    func setPartner(uid: String) {
        guard let user = user else { return }
        AppFirestore.userDocument(user.uid)
            .updateData([User.CodingKeys.partner.stringValue: uid])
    }

    func trySetPartner(name: String) async {
        let snapshot = try? await AppFirestore.usersCollection().whereField(User.CodingKeys.name.stringValue, isEqualTo: name).getDocuments()
        let document = snapshot?.documents.first
        let match = try? document?.data(as: User.self)
        if let match = match {
            setPartner(uid: match.uid)
        }
    }

    func storeLike(movieId: Int) async throws {
        guard let user = self.user, let partner = self.mutualPartner else { return }
        let userLikeRef = AppFirestore.userLikesCollection(user.uid).document(String(movieId))
        let partnerLikeRef = AppFirestore.userLikesCollection(partner.uid).document(String(movieId))

        try userLikeRef.setData(from: UserLike(userId: user.uid, movieId: movieId))
        if try await partnerLikeRef.getDocument().exists {
            // Ensure consistent match id
            let userIds = [user.uid, partner.uid].sorted()
            let matchId = (userIds + [String(movieId)]).joined(separator: "-")
            try AppFirestore.matchesCollection()
                .document(matchId)
                .setData(from: UserMatch(userIds: userIds, movieId: movieId))
        }
    }

    private func partnersListen(uid: String) -> ListenerRegistration {
        return AppFirestore.usersCollection()
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
                self.loaded = true
        }
    }
}
