//
//  UserLikesService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

import Foundation
import FirebaseFirestore

@MainActor
class UserLikesService: ObservableObject, UserChangeListener, UserPartnerChangeListener {
    private var userLikesListener: ListenerRegistration? = nil
    private var partnerLikesListener: ListenerRegistration? = nil
    private var userMatchesListener: ListenerRegistration? = nil
    
    private var userId: String? = nil
    private var partnerId: String? = nil

    @Published private(set) var userLikes: [UserLike] = []
    @Published private(set) var partnerLikes: [UserLike] = []
    @Published private(set) var userMatches: [UserMatch] = []

    init(userLikes: [UserLike], partnerLikes: [UserLike], userMatches: [UserMatch]) {
        self.userLikes = userLikes
        self.partnerLikes = partnerLikes
        self.userMatches = userMatches
    }
    
    init() {
    }

    func onUserPartnerChange(partner: User?) {
        self.partnerId = partner?.uid
        self.partnerLikesListener?.remove()
        if let partnerId {
            self.partnerLikesListener = partnerLikesListen(uid: partnerId)
        } else {
            self.partnerLikesListener = nil
            self.partnerLikes = []
        }
    }

    func onUserChange(user: User?) {
        userId = user?.uid
        userLikesListener?.remove()
        userMatchesListener?.remove()
        if let userId {
            userLikesListener = userLikesListen(uid: userId)
            userMatchesListener = userMatchesListen(uid: userId)
        } else {
            userLikesListener = nil
            userMatchesListener = nil
            userLikes = []
            userMatches = []
        }
    }
    
    func likeAndMatch(movieId: Int) async throws {
        guard let userId, let partnerId else { return }
        let userLikeRef = AppFirestore.userLikesCollection(userId).document(String(movieId))
        let partnerLikeRef = AppFirestore.userLikesCollection(partnerId).document(String(movieId))

        try userLikeRef.setData(from: UserLike(userId: userId, movieId: movieId))
        if try await partnerLikeRef.getDocument().exists {
            // Ensure consistent match id
            let userIds = [userId, partnerId].sorted()
            let matchId = (userIds + [String(movieId)]).joined(separator: "-")
            try AppFirestore.matchesCollection()
                .document(matchId)
                .setData(from: UserMatch(userIds: userIds, movieId: movieId))
        }
    }

    private func userLikesListen(uid: String) -> ListenerRegistration {
        return AppFirestore.userLikesCollection(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil else { return }
                guard let self else { return }
                self.userLikes = snapshot?.documents.compactMap{ try? $0.data(as: UserLike.self) } ?? []
        }
    }

    private func partnerLikesListen(uid: String) -> ListenerRegistration {
        return AppFirestore.userLikesCollection(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil else { return }
                guard let self else { return }
                self.partnerLikes = snapshot?.documents.compactMap{ try? $0.data(as: UserLike.self) } ?? []
        }
    }

    private func userMatchesListen(uid: String) -> ListenerRegistration {
        return AppFirestore.matchesCollection()
            .whereField(UserMatch.CodingKeys.userIds.stringValue, arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil else { return }
                guard let self else { return }
                self.userMatches = snapshot?.documents.compactMap{ try? $0.data(as: UserMatch.self) } ?? []
        }
    }
}
