//
//  AppFirestore.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

import FirebaseFirestore

class AppFirestore {
    static func db() -> Firestore {
        return Firestore.firestore()
    }

    static func matchesCollection() -> CollectionReference {
        return db().collection("matches")
    }

    static func usersCollection() -> CollectionReference {
        return db().collection("users")
    }

    static func userDocument(_ uid: String) -> DocumentReference {
        return usersCollection().document(uid)
    }

    static func userLikesCollection(_ uid: String) -> CollectionReference {
        return userDocument(uid).collection("likes")
    }
}
