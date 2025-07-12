//
//  CheckInput.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation

final class CheckInput {
    
    static func validEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    static func validPassword(_ pass: String) -> Bool {
        let regex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: pass)
    }
    
    static func validUsername(_ username: String) -> Bool {
        let regex = #"^[A-Za-z0-9 ]{7,18}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }
}
