//
//  PokemonModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation

protocol ObjectData: Decodable {
    init(_ dict: [String: Any])
}

struct PokemonsModel: Codable, ObjectData {
    let pokemons: [Pokemon]
    
    enum CodingKeys: String, CodingKey {
        case pokemons = "results"
    }
    
    init(_ dict: [String : Any]) {
        self.pokemons = (dict["results"] as? [[String : Any]] ?? []).map {
            Pokemon($0)
        }
    }
}

struct Pokemon: Codable {
    let name: String?
    let urlPokemon: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case urlPokemon = "url"
    }
    
    init(_ dict:  [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.urlPokemon = dict["url"] as? String ?? ""
    }
}

struct DetailPokemonModel: Codable, ObjectData {
    let id: Int?
    let name: String?
    let abilities: [Abilitys]
    let types: [Types]
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case abilities = "abilities"
        case types = "types"
    }
    
    init(_ dict:  [String: Any]) {
        self.id = dict["id"] as? Int ?? 0
        self.name = dict["name"] as? String ?? ""
        self.abilities = (dict["abilities"] as? [[String : Any]] ?? []).map {
            Abilitys($0)
        }
        self.types = (dict["types"] as? [[String : Any]] ?? []).map {
            Types($0)
        }
        
    }
    
}

struct Abilitys: Codable {
    let ability: Pokemon
    let ishidden: Bool
    let slot: Int
    
    init(_ dict:  [String: Any]) {
        self.ability = Pokemon(dict["ability"] as? [String: Any] ?? [:])
        self.ishidden = dict["is_hidden"] as? Bool ?? false
        self.slot = dict["slot"] as? Int ?? 0
        
    }
}

struct Types: Codable {
    let type: Pokemon
    
    init(_ dict:  [String: Any]) {
        self.type = Pokemon(dict["type"] as? [String: Any] ?? [:])
    }
    
}
