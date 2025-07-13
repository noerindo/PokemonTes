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

class HomeViewModel {
    private let apiService = GenerateApiExt.shared
    private let disposeBag = DisposeBag()
    
    private var isFirstLoad = true
    private var offset = 0
    private let limit = 20
    
    private var currentPokemons: [Pokemon] = []
    private let cacheKey = "Pokemons"
    
    private let pokemonsRelay = BehaviorRelay<[Pokemon]>(value: [])
    var pokemons: Observable<[Pokemon]> {
        return pokemonsRelay.asObservable()
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    var isLoading: Observable<Bool> {
        return loadingRelay.asObservable()
    }
    var isLoadingValue: Bool {
        return loadingRelay.value
    }
    
    let errorMessage = PublishRelay<String>()
    
    var onLoadingDetail: ((Bool) -> Void)?
    
    func fetchPokemon() {
        guard !loadingRelay.value else { return }
        loadingRelay.accept(true)
        
        if !NetworkUtils.isConnected {
            let cached = loadPokemonsFromCache()
            currentPokemons = cached
            pokemonsRelay.accept(cached)
            loadingRelay.accept(false)
            return
        }
        
        let fetch: Single<PokemonsModel> = isFirstLoad
        ? apiService.getPokemons()
        : apiService.getMorePokemon(offset: offset)
        
        fetch.observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] result in
                    guard let self = self else { return }
                    if self.isFirstLoad {
                        self.currentPokemons = result.pokemons
                        self.isFirstLoad = false
                    } else {
                        self.currentPokemons += result.pokemons
                    }
                    self.offset = self.currentPokemons.count
                    self.pokemonsRelay.accept(self.currentPokemons)
                    self.savePokemonsToCache(Array(self.currentPokemons.prefix(10)))
                    self.loadingRelay.accept(false)
                },
                onFailure: { [weak self] error in
                    self?.loadingRelay.accept(false)
                    self?.errorMessage.accept(error.localizedDescription.isEmpty ? "Unknown error" : error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    func loadCachedPokemonsIfAny() {
        let cached = loadPokemonsFromCache()
        guard !cached.isEmpty else { return }
        currentPokemons = cached
        pokemonsRelay.accept(currentPokemons)
    }
    
    // MARK: - Fetch Pokémons with Details (Reactive)
    func didSelectPokemon(_ pokemon: Pokemon, completion: @escaping (DetailPokemonModel?) -> Void) {
        guard let url = pokemon.urlPokemon else {
            completion(nil)
            return
        }
        onLoadingDetail?(true)
        
        apiService.getDetailPokemon(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] detail in
                    self?.onLoadingDetail?(false)
                    completion(detail)
                },
                onFailure: { [weak self] error in
                    self?.onLoadingDetail?(false)
                    self?.errorMessage.accept(error.localizedDescription.isEmpty ? "Unknown error" : error.localizedDescription)
                    completion(nil)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - save local pokemon
    private func savePokemonsToCache(_ pokemons: [Pokemon]) {
        let uniquePokemons = Array(
            Dictionary(grouping: pokemons, by: { $0.name ?? "" })
                .compactMap { $0.value.first }
        )
        let limitedPokemons = Array(uniquePokemons.prefix(10))
        do {
            let data = try JSONEncoder().encode(limitedPokemons)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("failed save: \(error)")
        }
    }
    
    private func loadPokemonsFromCache() -> [Pokemon] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return [] }
        do {
            let pokemons = try JSONDecoder().decode([Pokemon].self, from: data)
            let sortedPokemons = pokemons.sorted {
                let id1 = PokemonUtils.extractPokemonID(from: $0.urlPokemon ?? "") ?? 0
                let id2 = PokemonUtils.extractPokemonID(from: $1.urlPokemon ?? "") ?? 0
                return id1 < id2
            }
            
            return sortedPokemons
        } catch {
            print("failed load cached \(error)")
            return []
        }
    }
    
}
