//
//  GenerateApiExt.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import Alamofire
import Combine

protocol GenerateApiProtocol {
    func getPokemons() -> AnyPublisher<PokemonsModel, Error>
    func getMorePokemon(offset: Int) -> AnyPublisher<PokemonsModel, Error>
    func getDetailPokemon(url: String) -> AnyPublisher<DetailPokemonModel, Error>
}

struct ConfigAPI {
    static var hosts : String = "https://pokeapi.co/api/v2/pokemon?"
}

class endPointAPI {
    
    enum KeyAPI {
        case pokemons
        case morePoke(offset: Int, limit:Int)
        
        func path() -> String {
            switch self {
            case .pokemons:
                return "limit=10&offset=0"
            case .morePoke(let offsetPoke, let limit):
                return "offset=\(offsetPoke)&limit=\(limit)"
            }
        }
        
        var url: String {
            return ConfigAPI.hosts + path()
        }
        
    }
    static func getFullURL(for key: KeyAPI) -> String {
        return key.url
    }
    
}

public class GenerateApiExt: GenerateApiProtocol {
    public static let shared = GenerateApiExt()
    
    private init() {}
    
    // MARK: - Get Pokémons List
    func getPokemons() -> AnyPublisher<PokemonsModel, Error> {
        let endpoint = endPointAPI.getFullURL(for: .pokemons)
        return AF.request(endpoint)
            .publishData()
            .tryMap { output in
                guard let data = output.data else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(PokemonsModel.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get more Pokémons List
    func getMorePokemon(offset: Int) -> AnyPublisher<PokemonsModel, Error> {
        let endpoint = endPointAPI.getFullURL(for: .morePoke(offset: offset, limit: 10))
        return AF.request(endpoint)
            .publishData()
            .tryMap { output in
                guard let data = output.data else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(PokemonsModel.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Pokémon Detail
    func getDetailPokemon(url: String) -> AnyPublisher<DetailPokemonModel, Error> {
        return AF.request(url)
            .publishData()
            .tryMap { output in
                guard let data = output.data else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(DetailPokemonModel.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
}
