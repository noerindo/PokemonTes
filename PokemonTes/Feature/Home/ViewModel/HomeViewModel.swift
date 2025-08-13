//
//  HomeViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import UIKit
import Combine

protocol HomeViewModelProtocol {
    var pokemons: AnyPublisher<[Pokemon], Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var isLoadingValue: Bool { get }
    var errorMessage: AnyPublisher<String, Never> { get }
    
    func fetchPokemon()
    func loadCachedPokemonsIfAny()
    func didSelectPokemon(_ pokemon: Pokemon, completion: @escaping (DetailPokemonModel?) -> Void)
}

final class HomeViewModel: HomeViewModelProtocol {
    
    private let apiService: GenerateApiProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var offset = 0
    private let limit = 20
    private var isFirstLoad = true
    var onLoadingDetail: ((Bool) -> Void)?
    
    private var currentPokemons: [Pokemon] = []
    private let cacheKey = "Pokemons"
    
    private let pokemonsSubject = CurrentValueSubject<[Pokemon], Never>([])
    var pokemons: AnyPublisher<[Pokemon], Never> { pokemonsSubject.eraseToAnyPublisher() }
    
    private let loadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoading: AnyPublisher<Bool, Never> { loadingSubject.eraseToAnyPublisher() }
    var isLoadingValue: Bool { loadingSubject.value }
    
    private let errorSubject = PassthroughSubject<String, Never>()
    var errorMessage: AnyPublisher<String, Never> { errorSubject.eraseToAnyPublisher() }
    
    init(apiService: GenerateApiProtocol = GenerateApiExt.shared) {
        self.apiService = apiService
        fetchPokemon()
    }
    
    func fetchPokemon() {
        guard !isLoadingValue else { return }
        setLoading(true)
        
        guard NetworkUtils.isConnected else {
            useCachedData()
            return
        }
        
        let request: AnyPublisher<PokemonsModel, Error> = isFirstLoad
        ? apiService.getPokemons() : apiService.getMorePokemon(offset: offset)
        request
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] result in
                self?.handleSuccess(result.pokemons)
            })
            .store(in: &cancellables)
    }
    
    func didSelectPokemon(_ pokemon: Pokemon, completion: @escaping (DetailPokemonModel?) -> Void) {
        guard let url = pokemon.urlPokemon else {
            completion(nil)
            return
        }
        
        apiService.getDetailPokemon(url: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completionSink in
                if case .failure(let error) = completionSink {
                    self?.errorSubject.send(error.localizedDescription)
                    completion(nil)
                }
            }, receiveValue: { detail in
                completion(detail)
            })
            .store(in: &cancellables)
    }
    
    func loadCachedPokemonsIfAny() {
        let cached = loadPokemonsFromCache()
        guard !cached.isEmpty else { return }
        currentPokemons = cached
        pokemonsSubject.send(cached)
    }
    
    private func useCachedData() {
        currentPokemons = loadPokemonsFromCache()
        pokemonsSubject.send(currentPokemons)
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
        pokemonsSubject.send(currentPokemons)
        savePokemonsToCache(Array(currentPokemons.prefix(10)))
        setLoading(false)
    }
    
    private func handleError(_ error: Error) {
        setLoading(false)
        let message = error.localizedDescription.isEmpty ? "Unknown error" : error.localizedDescription
        errorSubject.send(message)
    }
    
    private func setLoading(_ value: Bool) {
        loadingSubject.send(value)
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
