//
//  UserPartnerService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

import Foundation
import FirebaseFirestore

protocol UserPartnerChangeListener {
    @MainActor
    func onUserPartnerChange(partner: User?)
}

@MainActor
class UserPartnerService: ObservableObject, UserChangeListener {
    private let changeListeners: [UserPartnerChangeListener]
    private var listener: ListenerRegistration? = nil

    @Published private(set) var loaded: Bool = false
    @Published private(set) var pendingPartners: [User] = []
    private var user: User? = nil
    var mutualPartner: User? { self.pendingPartners.first(where: { user?.partner == $0.uid }) }

    init(changeListeners: [UserPartnerChangeListener]) {
        self.changeListeners = changeListeners
    }

    init(user: User, partner: User) {
        self.changeListeners = []
        self.user = user
        self.pendingPartners = [partner]
    }

    func onUserChange(user: User?) {
        if let user {
            if self.user == nil {
                self.loaded = false
                self.listener?.remove()
                self.listener = partnersListen(uid: user.uid)
            }
            self.user = user
        } else {
            self.listener?.remove()
            self.listener = nil

            self.user = nil
            self.pendingPartners = []

            self.notifyListeners()
            self.loaded = true
        }
    }

    func setPartner(uid: String?) {
        guard let user else { return }
        AppFirestore.userDocument(user.uid)
            .updateData([User.CodingKeys.partner.stringValue: uid ?? FieldValue.delete()])
    }

    func trySetPartner(name: String) async {
        let snapshot = try? await AppFirestore
            .usersCollection()
            .whereField(User.CodingKeys.name.stringValue, isEqualTo: name).getDocuments()
        let document = snapshot?.documents.first
        let match = try? document?.data(as: User.self)
        if let match {
            setPartner(uid: match.uid)
        }
    }

    private func partnersListen(uid: String) -> ListenerRegistration {
        return AppFirestore.usersCollection()
            .whereField(User.CodingKeys.partner.stringValue, isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil else { return }
                guard let self else { return }
                self.pendingPartners = snapshot?.documents
                    .compactMap{ try? $0.data(as: User.self) } ?? []
                notifyListeners()
                self.loaded = true
        }
    }

    private func notifyListeners() {
        self.changeListeners.forEach{ $0.onUserPartnerChange(partner: mutualPartner) }
    }
}
