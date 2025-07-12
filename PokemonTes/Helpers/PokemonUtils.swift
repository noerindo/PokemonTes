//
//  PokemonUtils.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import UIKit

struct PokemonUtils {
    static func extractPokemonID(from url: String) -> String? {
        let trimmedURL = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmedURL.components(separatedBy: "/").last
    }
    
    static func getPokemonImageURL(from id: Int) -> URL? {
       
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
        
    }
}
