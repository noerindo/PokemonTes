//
//  GenerateApiExt.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import Alamofire
import RxSwift

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

public class GenerateApiExt {
    public static let shared = GenerateApiExt()
    
    private init() {}
    
    // MARK: - Get Pokémons List
    func getPokemons() -> Single<PokemonsModel> {
        return Single.create { single in
            let endpoint = endPointAPI.getFullURL(for: .pokemons)
            
            let request = AF.request(endpoint, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode(PokemonsModel.self, from: data)
                            single(.success(decoded))
                        } catch {
                            single(.failure(error))
                        }
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Get more Pokémons List
    func getMorePokemon(offset: Int) -> Single<PokemonsModel> {
        return Single.create { single in
            let endpoint = endPointAPI.getFullURL(for: .morePoke(offset: offset, limit: 10))
            let request = AF.request(endpoint, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode(PokemonsModel.self, from: data)
                            single(.success(decoded))
                        } catch {
                            single(.failure(error))
                        }
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create { request.cancel() }
            
        }
    }
    
    // MARK: - Get Pokémon Detail
    func getDetailPokemon(url: String) -> Single<DetailPokemonModel> {
        return Single.create { single in
            let request = AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode(DetailPokemonModel.self, from: data)
                            single(.success(decoded))
                        } catch {
                            single(.failure(error))
                        }
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
}
