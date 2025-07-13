//
//  SessionManager.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import Foundation
import RealmSwift

class SessionManager {
    
    static let shared = SessionManager()
    private let userDefaults = UserDefaults.standard
    private let realm = try! Realm()
    
    private init() {}
    
    private let keyIsLoggedIn = "isLoggedIn"
    private let keyLoggedInUserId = "userId"
    
    func loginUser(_ user: UserModel) {
        userDefaults.set(true, forKey: keyIsLoggedIn)
        userDefaults.set(user.id.stringValue, forKey: keyLoggedInUserId)
    }
    
    func logoutUser() {
        userDefaults.set(false, forKey: keyIsLoggedIn)
        userDefaults.removeObject(forKey: keyLoggedInUserId)
    }
    
    var isLoggedIn: Bool {
        return userDefaults.bool(forKey: keyIsLoggedIn)
    }
    
    var loggedInUserId: ObjectId? {
        guard let idString = userDefaults.string(forKey: keyLoggedInUserId) else {
            return nil
        }
        return try? ObjectId(string: idString)
    }
    
    var currentUser: UserModel? {
        guard let userId = loggedInUserId else { return nil }
        return realm.object(ofType: UserModel.self, forPrimaryKey: userId)
    }
}
