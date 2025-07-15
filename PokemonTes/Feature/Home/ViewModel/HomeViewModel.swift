//
//  HomeViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol HomeViewModelProtocol {
    var pokemons: Observable<[Pokemon]> { get }
    var isLoading: Observable<Bool> { get }
    var isLoadingValue: Bool { get }
    var errorMessage: Observable<String> { get }
    
    func fetchPokemon()
    func loadCachedPokemonsIfAny()
    func didSelectPokemon(_ pokemon: Pokemon, completion: @escaping (DetailPokemonModel?) -> Void)
}

final class HomeViewModel: HomeViewModelProtocol {
    
    private let apiService: GenerateApiProtocol
    private let disposeBag = DisposeBag()
    
    private var offset = 0
    private let limit = 20
    private var isFirstLoad = true
    var onLoadingDetail: ((Bool) -> Void)?
    
    private var currentPokemons: [Pokemon] = []
    private let cacheKey = "Pokemons"
    
    private let pokemonsRelay = BehaviorRelay<[Pokemon]>(value: [])
    var pokemons: Observable<[Pokemon]> { pokemonsRelay.asObservable() }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    var isLoading: Observable<Bool> { loadingRelay.asObservable() }
    var isLoadingValue: Bool { loadingRelay.value }
    
    private let errorRelay = PublishRelay<String>()
    var errorMessage: Observable<String> { errorRelay.asObservable() }
    
    init(apiService: GenerateApiProtocol = GenerateApiExt.shared) {
        self.apiService = apiService
    }
    
    func fetchPokemon() {
        guard !isLoadingValue else { return }
        
        setLoading(true)
        
        guard NetworkUtils.isConnected else {
            useCachedData()
            return
        }
        
        let request: Single<PokemonsModel> = isFirstLoad
        ? apiService.getPokemons()
        : apiService.getMorePokemon(offset: offset)
        
        request
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] result in
                    self?.handleSuccess(result.pokemons)
                },
                onFailure: { [weak self] error in
                    self?.handleError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func didSelectPokemon(_ pokemon: Pokemon, completion: @escaping (DetailPokemonModel?) -> Void) {
        guard let url = pokemon.urlPokemon else {
            completion(nil)
            return
        }
        
        apiService.getDetailPokemon(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { detail in
                completion(detail)
            }, onFailure: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
                completion(nil)
            })
            .disposed(by: disposeBag)
    }
    
    func loadCachedPokemonsIfAny() {
        let cached = loadPokemonsFromCache()
        guard !cached.isEmpty else { return }
        currentPokemons = cached
        pokemonsRelay.accept(cached)
    }
    
    private func useCachedData() {
        currentPokemons = loadPokemonsFromCache()
        pokemonsRelay.accept(currentPokemons)
        setLoading(false)
    }
    
    private func handleSuccess(_ newPokemons: [Pokemon]) {
        if isFirstLoad {
            currentPokemons = newPokemons
            isFirstLoad = false
        } else {
            currentPokemons += newPokemons
        }
        
        offset = currentPokemons.count
        pokemonsRelay.accept(currentPokemons)
        savePokemonsToCache(Array(currentPokemons.prefix(10)))
        setLoading(false)
    }
    
    private func handleError(_ error: Error) {
        setLoading(false)
        let message = error.localizedDescription.isEmpty ? "Unknown error" : error.localizedDescription
        errorRelay.accept(message)
    }
    
    private func setLoading(_ value: Bool) {
        loadingRelay.accept(value)
    }
    
    private func savePokemonsToCache(_ pokemons: [Pokemon]) {
        let unique = Array(
            Dictionary(grouping: pokemons, by: { $0.name ?? "" }).compactMap { $0.value.first }
        )
        do {
            let data = try JSONEncoder().encode(unique)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("failed save: \(error)")
        }
    }
    
    private func loadPokemonsFromCache() -> [Pokemon] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return [] }
        do {
            let pokemons = try JSONDecoder().decode([Pokemon].self, from: data)
            return pokemons.sorted {
                let id1 = PokemonUtils.extractPokemonID(from: $0.urlPokemon ?? "") ?? 0
                let id2 = PokemonUtils.extractPokemonID(from: $1.urlPokemon ?? "") ?? 0
                return id1 < id2
            }
        } catch {
            print("failed load cached \(error)")
            return []
        }
    }
}
