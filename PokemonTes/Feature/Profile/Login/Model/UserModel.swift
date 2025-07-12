//
//  UserModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import RealmSwift

class UserModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var email: String = ""
    @Persisted var password: String = ""
}
